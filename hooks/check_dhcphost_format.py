# commit hook to check if DHCP host entries are formatted in our standard way
import argparse
import sys
from typing import List
from typing import Optional
from typing import Sequence

import regex
import termcolor

# list valid regexes, more common ones first
PATTERNS = [
    r"^host \S+ { hardware ethernet \S+; fixed-address \S+;\s*}( # .*)?$",
    r"^host \S+ { hardware ethernet \S+; option tftpserver \S+, \S+;\s*}( # .*)?$",
]
STRICT = [regex.compile(p) for p in PATTERNS]
FUZZY = [regex.compile("(?b)(?:" + p + "){e<=5}") for p in PATTERNS]


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("filenames", nargs="*")
    args = parser.parse_args(argv)

    errs = []
    for filename in args.filenames:
        with open(filename, "r") as inputfile:
            for i, line in enumerate(inputfile):
                if line.startswith("host ") and not any(p.match(line) for p in STRICT):
                    for fuzzy in FUZZY:
                        match = fuzzy.search(line)
                        if match:
                            line = colorize(line, sum(match.fuzzy_changes, []))
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


def colorize(string: str, indexes: List[int]) -> str:
    mark = dict.fromkeys(indexes, True)
    newstring = ""
    for m in range(0, len(string)):
        if m in mark:
            newstring += colored(string[m], "red", attrs=["reverse"])
        else:
            newstring += string[m]
    return newstring


def colored(string: str, color: str = "green", attrs=None) -> str:
    # disable colors if not connected to a terminal
    if sys.stderr.isatty():
        return termcolor.colored(string, color, attrs=attrs)
    else:
        return string
