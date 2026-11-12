"""Example custom filter: useful when developing Ansible plugins in Python."""

import re


def normalize_identifier(value: str) -> str:
    """Return a simple lowercase, underscore-separated identifier."""
    if not isinstance(value, str):
        raise TypeError("normalize_identifier expects a string")
    return re.sub(r"\s+", "_", value.strip().lower())


class FilterModule:
    """Register filters with Ansible."""

    def filters(self) -> dict[str, object]:
        return {"normalize_identifier": normalize_identifier}
