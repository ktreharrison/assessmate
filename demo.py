
def print_str(string: str, times: int) -> str:
    """

    :param string: param times:
    :param string: str:
    :param times: int:

    """
    result: str = "".join(string[i] for i in range(times))
    return " ".join(result)


print_str("Hello Ken", 1)
