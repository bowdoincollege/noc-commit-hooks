# commit hook to verify that CNAME RR canonical name is not an IP address
import argparse
import ipaddress
import re
import sys
from typing import List
from typing import Optional
from typing import Sequence

import termcolor

CNAME_RE = re.compile(r"\S+\s+(?:IN\s+)?CNAME\s+(\S+).*")


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("filenames", nargs="*")
    args = parser.parse_args(argv)

    errs = []
    for filename in args.filenames:
        with open(filename) as inputfile:
            for i, line in enumerate(inputfile):
                line = line.rstrip()
                if line.lstrip().startswith(";"):
                    continue

                match = re.fullmatch(CNAME_RE, line.rstrip())
                if match and is_ip(match[1]):
                    line = line.replace(match[1], colored(match[1], "red"), 1)
                    errs.append(colored(f"{filename} line {i+1}:") + line)

    if len(errs):
        plural = " appears" if len(errs) == 1 else "s appear"
        print(colored(f"CNAME{plural} to point to IP (not name):", "red"))
        for err in errs:
            print(err)
        return 1
    else:
        return 0


def is_ip(ip: str) -> bool:
    try:
        ipaddress.ip_address(ip)
    except:
        return False
    return True


def colored(string: str, color: str = "green", attrs=None) -> str:
    # disable colors if not connected to a terminal
    if sys.stderr.isatty():
        return termcolor.colored(string, color, attrs=attrs)
    else:
        return string
