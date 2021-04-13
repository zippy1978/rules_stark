"""Macro for declaring repository dependencies."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

load(
    "//internal:repo.bzl",
    _stark_download = "stark_download",
)
stark_download = _stark_download

def stark_rules_dependencies():
    """Declares external repositories that rules_stark depends on.
    This function should be loaded and called from WORKSPACE of any project
    that uses rules_stark.
    """

    # bazel_skylib is a set of libraries that are useful for writing
    # Bazel rules. We use it to handle quoting arguments in shell commands.
    _maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
        ],
        sha256 = "97e70364e9249702246c0e9444bccdc4b847bed1eb03c5a3ece4f83dfe6abc44",
    )

def _maybe(rule, name, **kwargs):
    """Declares an external repository if it hasn't been declared already."""
    if name not in native.existing_rules():
        rule(name = name, **kwargs)
