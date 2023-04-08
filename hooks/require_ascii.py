# require_ascii.py
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
                try:
                    # @todo This can probably be enhanced to read byte-by-byte
                    # to report the offending column.
                    line = fh.readline()
                except UnicodeDecodeError as e:
                    print(
                        termcolor.colored(
                            f"{filename}: line {line_num} " + str(e), "red"
                        )
                    )
                    status = 1

                if not line:
                    break

                col_num = 0
                for char in line:
                    col_num += 1
                    if ord(char) > MAX_ASCII_CODE:
                        print(
                            termcolor.colored(
                                f"{filename}: line {line_num} column {col_num} "
                                + f'character "{char}" (decimal {ord(char)})',
                                "red",
                            )
                        )
                        status = 1

    return status
