import inspect
import re
import sys

import pytest
from util_test import check_hostentry
from util_test import get_input_from_file
from util_test import mock_run_from_terminal

from hooks.check_dhcphost_format import main

valid_input = get_input_from_file("valid")
invalid_input = get_input_from_file("invalid")
ansi_escape = re.compile(r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])")


@pytest.mark.parametrize("input", valid_input)
def test_valid_hostentry(input, tmpdir, capsys):
    assert check_hostentry(input, main, tmpdir) == 0
    assert ansi_escape.search(capsys.readouterr().out) == None


@pytest.mark.parametrize("input", valid_input)
def test_valid_hostentry_with_terminal(mocker, tmpdir, capsys, input):
    mock_run_from_terminal(mocker)
    assert sys.stderr.isatty()
    assert check_hostentry(input, main, tmpdir) == 0
    assert ansi_escape.search(capsys.readouterr().out) == None


@pytest.mark.parametrize("input", invalid_input)
def test_invalid_hostentry(input, tmpdir, capsys):
    assert check_hostentry(input, main, tmpdir) == 1
    assert ansi_escape.search(capsys.readouterr().out) == None


@pytest.mark.parametrize("input", invalid_input)
def test_invalid_hostentry_with_terminal(mocker, tmpdir, capsys, input):
    mock_run_from_terminal(mocker)
    assert sys.stderr.isatty()
    assert check_hostentry(input, main, tmpdir) == 1
    assert ansi_escape.search(capsys.readouterr().out) == None
