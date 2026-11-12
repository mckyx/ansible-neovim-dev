"""Example pytest tests for an Ansible filter plugin."""

import pytest

from filter_plugins.custom_filters import FilterModule, normalize_identifier


def test_normalize_identifier() -> None:
    assert normalize_identifier("  Hello Ansible  ") == "hello_ansible"


def test_ansible_filter_registration() -> None:
    assert "normalize_identifier" in FilterModule().filters()


def test_invalid_filter_input() -> None:
    with pytest.raises(TypeError):
        normalize_identifier(42)  # type: ignore[arg-type]
