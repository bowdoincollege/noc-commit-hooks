# check ascii printable chars only
import argparse
import sys
from typing import List
from typing import Optional
from typing import Sequence

import termcolor


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("filenames", nargs="*")
    args = parser.parse_args(argv)
    status = 0
    MAX_ASCII_CODE = 127

    for filename in args.filenames:
        line_num = 0
        with open(filename, encoding="UTF-8") as fh:
            while True:
                line_num += 1
                line = fh.readline()
                if not line:
                    break

                col_num = 0
                for char in line:
                    col_num += 1
                    if ord(char) > MAX_ASCII_CODE:
                        print(
                            colored(
                                f"{filename}: line {line_num} column {col_num} "
                                + f'character "{char}" (decimal {ord(char)})',
                                "red",
                            )
                        )
                        status = 1
    return status


def colored(string: str, color: str = "green", attrs=None) -> str:
    # disable colors if not connected to a terminal
    if sys.stderr.isatty():
        return termcolor.colored(string, color, attrs=attrs)
    else:
        return string
