# commit hook to check if DHCP host entries are formatted in our standard way
import argparse
import sys
from typing import List
from typing import Optional
from typing import Sequence
from typing import Tuple

import regex
import termcolor

# list valid regexes, more common ones first
PATTERNS = [
    r"host \S+ { hardware ethernet \S+; fixed-address \S+;\s*}( # .*)?",
    r"host \S+ { hardware ethernet \S+; option tftpserver \S+, \S+;\s*}( # .*)?",
]
STRICT = [regex.compile(p) for p in PATTERNS]
FUZZY = [regex.compile("(?b)(?:" + p + "){e<=8}") for p in PATTERNS]


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("filenames", nargs="*")
    args = parser.parse_args(argv)

    errs = []
    for filename in args.filenames:
        with open(filename, "r") as inputfile:
            for i, line in enumerate(inputfile):
                line = line.rstrip()
                if line.startswith("host ") and not any(
                    p.fullmatch(line) for p in STRICT
                ):
                    for fuzzy in FUZZY:
                        match = fuzzy.fullmatch(line)
                        if match:
                            line = colorize(line, match.fuzzy_changes)
                            break
                    errs.append(colored(f"{filename} line {i+1}:") + line)

    if len(errs):
        plural = "entry does" if len(errs) == 1 else "entries do"
        print(colored(f"DHCP host {plural} not match standard format:", "red"))
        for err in errs:
            print(err)
        return 1
    else:
        return 0


def colorize(string: str, indexes: Tuple[List[int], List[int], List[int]]) -> str:
    stubstitutions, insertions, deletions = indexes
    changes = stubstitutions + insertions
    newstring = ""
    d = i = 0
    while i < len(string):
        if i + d in deletions:
            newstring += colored(" ", "red", attrs=["underline"])
            d += 1
            continue
        if i in changes:
            start = i
            while i + 1 in changes:
                i += 1
            newstring += colored(string[start : i + 1], "red", attrs=["reverse"])
        else:
            newstring += string[i]
        i += 1
    return newstring


def colored(string: str, color: str = "green", attrs=None) -> str:
    # disable colors if not connected to a terminal
    if sys.stderr.isatty():
        return termcolor.colored(string, color, attrs=attrs)
    else:
        return string
