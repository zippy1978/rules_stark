# This template is used by stark_download to generate a build file for
# a downloaded Stark distribution.

load("@rules_stark//stark:defs.bzl", "stark_toolchain")

# tools contains executable files that are part of the toolchain.
filegroup(
    name = "tools",
    srcs = glob(["bin/*"]),
    visibility = ["//visibility:public"],
)

# runtimes contains runtime libraries.
filegroup(
    name = "runtimes",
    srcs = glob(["lib/*"]),
    visibility = ["//visibility:public"],
)

# toolchain_impl gathers information about the Stark toolchain.
# See the StarkToolchain provider.
stark_toolchain(
    name = "toolchain_impl",
    runtimes = [":runtimes"],
    tools = [":tools"],
)

# toolchain is a Bazel toolchain that expresses execution and target
# constraints for toolchain_impl. This target should be registered by
# calling register_toolchains in a WORKSPACE file.
toolchain(
    name = "toolchain",
    exec_compatible_with = [
        {exec_constraints},
    ],
    target_compatible_with = [
        {target_constraints},
    ],
    toolchain = ":toolchain_impl",
    toolchain_type = "@rules_stark//stark:toolchain_type",
)