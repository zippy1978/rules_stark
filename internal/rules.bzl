load(":providers.bzl", "StarkModuleInfo")

# stark_module

def _stark_module_impl(ctx):
    # Load the toolchain.
    stark_toolchain = ctx.toolchains["@rules_stark//:toolchain_type"]

    dir = ctx.actions.declare_directory(ctx.label.name)

    deps = ctx.attr.deps

    stark_toolchain.compile(
        ctx,
        srcs = ctx.files.srcs,
        out = dir,
        deps = [dep[StarkModuleInfo] for dep in deps],
    )

    runfiles = ctx.runfiles(files = [dir])
    for dep in deps:
        runfiles = runfiles.merge(dep[DefaultInfo].data_runfiles)
    return [
        DefaultInfo(files = depset([dir]), runfiles = runfiles),
        StarkModuleInfo(
            dir = dir,
            deps = depset(
                direct = [dep[StarkModuleInfo].dir for dep in deps],
                transitive = [dep[StarkModuleInfo].deps for dep in deps],
            ),
        ),
    ]

stark_module = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".st"],
            doc = "Source files to compile",
        ),
        "deps": attr.label_list(
            providers = [StarkModuleInfo],
            doc = "Direct dependencies of the module",
        ),
    },
    implementation = _stark_module_impl,
    toolchains = ["@rules_stark//:toolchain_type"],
)

# stark_binary

def _stark_binary_impl(ctx):
    # Load the toolchain.
    stark_toolchain = ctx.toolchains["@rules_stark//:toolchain_type"]

    deps = ctx.attr.deps

    executable_path = "{name}%/{name}".format(name = ctx.label.name)
    executable = ctx.actions.declare_file(executable_path)

    stark_toolchain.compile(
        ctx,
        srcs = ctx.files.srcs,
        out = executable,
        deps = [dep[StarkModuleInfo] for dep in deps],
    )

    return [DefaultInfo(files = depset([executable]), executable = executable)]

stark_binary = rule(
    doc = "Builds an executable program from Stark source code",
    executable = True,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".st"],
            doc = "Source files to compile",
        ),
        "deps": attr.label_list(
            providers = [StarkModuleInfo],
            doc = "Direct dependencies of the binary",
        ),
    },
    implementation = _stark_binary_impl,
    toolchains = ["@rules_stark//:toolchain_type"],
)

# stark_test

def _stark_test_impl(ctx):
    # Load the toolchain.
    stark_toolchain = ctx.toolchains["@rules_stark//:toolchain_type"]

    deps = ctx.attr.deps

    stark_toolchain.test(
        ctx,
        srcs = ctx.files.srcs,
        out = ctx.outputs.executable,
        deps = [dep[StarkModuleInfo] for dep in deps],
    )

    runfiles = ctx.runfiles(files = ctx.files.srcs + [stark_toolchain.internal.test_runner, stark_toolchain.internal.interpreter])
    for dep in deps:
        runfiles = runfiles.merge(dep[DefaultInfo].data_runfiles)
    return [DefaultInfo(runfiles = runfiles)]

stark_test = rule(
    doc = "Runs test functions from Stark source code",
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".st"],
            doc = "Test source files to run",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Data files available to those tests",
        ),
        "deps": attr.label_list(
            providers = [StarkModuleInfo],
            doc = "Direct dependencies of the binary",
        ),
    },
    implementation = _stark_test_impl,
    toolchains = ["@rules_stark//:toolchain_type"],
    test = True,
)
