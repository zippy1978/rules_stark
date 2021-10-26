load(":providers.bzl", "StarkModuleInfo")

# stark_clang_module

def _stark_clang_module_impl(ctx):
    # Modules are compiled to <target>.modules directory
    dir_name = ".".join([ctx.label.name, "modules"])
    dir = ctx.actions.declare_directory(dir_name)

    srcs = ctx.files.srcs
    hdr = ctx.file.hdr
    opts = ctx.attr.opts

    module_dir_name = "/".join([dir_name, ctx.label.name])
    bc_file_name = "/".join([module_dir_name, ".".join([ctx.label.name, "bc"])])
    bc_file = ctx.actions.declare_file(bc_file_name)
    sth_file_name = "/".join([module_dir_name, ".".join([ctx.label.name, "sth"])])
    sth_file = ctx.actions.declare_file(sth_file_name)

    # mkdir command
    mkdir_cmd = "mkdir -p {path}".format(path = module_dir_name)

    # clang command
    clang_cmd = "/usr/bin/clang -O3 -emit-llvm -c {opts} -o {bc_file_name} {srcs}".format(opts = " ".join([o for o in opts]), bc_file_name = bc_file.path, srcs = " ".join([src.path for src in srcs]))
    
    # copy header command
    copy_hdr_cmd = "cp {source_hrd_file_name} {sth_file_name}".format(source_hrd_file_name = hdr.path, sth_file_name = sth_file.path)

    ctx.actions.run_shell(
        command = "{mkdir_cmd} && {clang_cmd} && {copy_hdr_cmd}".format(mkdir_cmd = mkdir_cmd, clang_cmd = clang_cmd, copy_hdr_cmd = copy_hdr_cmd),
        inputs = srcs + [hdr],
        outputs = [dir, bc_file, sth_file],
    )

    runfiles = ctx.runfiles(files = [dir])
    return [
        DefaultInfo(files = depset([dir]), runfiles = runfiles),
        StarkModuleInfo(
            dir = dir,
            deps = depset(
                direct = [],
                transitive = [],
            ),
        ),
    ]

stark_clang_module = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".c", ".cpp", ".cc", ".h", ".hpp"],
            doc = "Source files to compile",
        ),
        "hdr": attr.label(
            allow_single_file = [".sth"],
            doc = "Header for the module",
        ),
        "opts": attr.string_list(
            doc = "Additional compiler options",
        ),
    },
    implementation = _stark_clang_module_impl,
    toolchains = ["@rules_stark//stark:toolchain_type"],
)

# stark_module

def _stark_module_impl(ctx):
    # Load the toolchain.
    stark_toolchain = ctx.toolchains["@rules_stark//stark:toolchain_type"]

    # Modules are compiled to <target>.modules directory
    dir_name = ".".join([ctx.label.name, "modules"])
    dir = ctx.actions.declare_directory(dir_name)

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
    toolchains = ["@rules_stark//stark:toolchain_type"],
)

# stark_binary

def _stark_binary_impl(ctx):
    # Load the toolchain.
    stark_toolchain = ctx.toolchains["@rules_stark//stark:toolchain_type"]

    deps = ctx.attr.deps

    executable_path = "{name}%/{name}".format(name = ctx.label.name)
    executable = ctx.actions.declare_file(executable_path)

    stark_toolchain.compile(
        ctx,
        srcs = ctx.files.srcs,
        out = executable,
        deps = [dep[StarkModuleInfo] for dep in deps],
        linkopts = ctx.attr.linkopts,
    )

    runfiles = ctx.runfiles(files = [stark_toolchain.internal.static_runtime])
    return [DefaultInfo(files = depset([executable]), executable = executable, runfiles = runfiles)]

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
        "linkopts": attr.string_list(
            doc = "Additional linker options",
        ),
    },
    implementation = _stark_binary_impl,
    toolchains = ["@rules_stark//stark:toolchain_type"],
)

# stark_test

def _stark_test_impl(ctx):
    # Load the toolchain.
    stark_toolchain = ctx.toolchains["@rules_stark//stark:toolchain_type"]

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
    toolchains = ["@rules_stark//stark:toolchain_type"],
    test = True,
)
