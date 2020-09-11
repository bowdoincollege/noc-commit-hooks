import inspect


def get_input_from_file(type: str):
    fname = inspect.getfile(inspect.currentframe().f_back).rsplit(".", 1)[0]  # type: ignore
    with open(f"{fname}.{type}.txt", encoding="UTF-8") as f:
        return list(filter(lambda l: not l.lstrip().startswith("#") and l.rstrip(), f))


def mock_run_from_terminal(mocker):
    caller = inspect.getmodule(inspect.currentframe().f_back)
    module_name = caller.__name__.replace("test", "check")
    mock = mocker.patch(f"hooks.{module_name}.sys.stderr")
    mock.isatty.return_value = True


def check_hostentry(text, func, tmpdir):
    path = tmpdir.join("file.txt")
    path.write(text)
    return func((str(path),))
