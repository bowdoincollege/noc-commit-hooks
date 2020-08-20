import inspect
import os
import re
import sys

import pytest

from hooks.check_dhcphost_format import main


def get_input_from_file(type: str):
    file = inspect.getfile(inspect.currentframe()).rsplit(".", 1)[0]  # type: ignore
    with open(f"{file}.{type}.txt", encoding="UTF-8") as f:
        return list(filter(lambda l: not l.lstrip().startswith("#") and l.rstrip(), f))


def mock_run_from_terminal(mocker):
    mock = mocker.patch("hooks.check_dhcphost_format.sys.stderr")
    mock.isatty.return_value = True


valid_input = get_input_from_file("valid")
invalid_input = get_input_from_file("invalid")
ansi_escape = re.compile(r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])")


def check_hostentry(text, tmpdir):
    path = tmpdir.join("file.txt")
    path.write(text)
    return main((str(path),))


@pytest.mark.parametrize("input", valid_input)
def test_valid_hostentry(input, tmpdir, capsys):
    assert check_hostentry(input, tmpdir) == 0
    assert ansi_escape.search(capsys.readouterr().out) == None


@pytest.mark.parametrize("input", valid_input)
def test_valid_hostentry_with_terminal(mocker, tmpdir, capsys, input):
    mock_run_from_terminal(mocker)
    assert sys.stderr.isatty()
    assert check_hostentry(input, tmpdir) == 0
    assert ansi_escape.search(capsys.readouterr().out) == None


@pytest.mark.parametrize("input", invalid_input)
def test_invalid_hostentry(input, tmpdir, capsys):
    assert check_hostentry(input, tmpdir) == 1
    assert ansi_escape.search(capsys.readouterr().out) == None


@pytest.mark.parametrize("input", invalid_input)
def test_invalid_hostentry_with_terminal(mocker, tmpdir, capsys, input):
    mock_run_from_terminal(mocker)
    assert sys.stderr.isatty()
    assert check_hostentry(input, tmpdir) == 1
    assert ansi_escape.search(capsys.readouterr().out)


def test_create_file(tmpdir):
    p = tmpdir.mkdir("sub").join("somefile.txt")
    p.write("content")
    assert p.read() == "content"
