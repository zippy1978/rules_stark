"""defs.bzl contains public definitions for rules_stark.
These definitions may be used by Bazel projects for building Stark programs.
These definitions should be loaded from here, not any internal directory.
Internal definitions may change without notice.
"""

load(
    "//stark/internal:rules.bzl",
    _stark_binary = "stark_binary",
    _stark_module = "stark_module",
    _stark_test = "stark_test",
)
load(
    "//stark/internal:providers.bzl",
    _StarkModuleInfo = "StarkModuleInfo",
)
load(
    "//stark/internal:toolchain.bzl",
    _stark_toolchain = "stark_toolchain",
)

stark_binary = _stark_binary
stark_module = _stark_module
StarkModuleInfo = _StarkModuleInfo
stark_toolchain = _stark_toolchain
stark_test = _stark_test
