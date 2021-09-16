def starkc(ctx, srcs, out, deps = [], linkopts = []):
    """starkc compilation from sources.

    Args:
        ctx: analysis context.
        srcs: list of source Files to be compiled.
        out: output file (for main module) or directory (if module),
        deps: list of StarkModuleInfo objects for direct dependencies.
    """

    stark_toolchain = ctx.toolchains["@rules_stark//stark:toolchain_type"]

    modules = []
    module_dirs = []
    for dep in deps:
        modules.append(dep.dir.path)
        module_dirs.append(dep.dir)

    args = ctx.actions.args()
    args.add("-r", stark_toolchain.internal.static_runtime)
    if len(deps) > 0:
        args.add_joined("-m", modules, join_with = ":")
    if len(linkopts) > 0:
        linker = "cc:-lpthread " + " ".join([lo for lo in linkopts])
        args.add("-l", linker)
    args.add("-o", out.path)
    args.add_all(srcs)

    ctx.actions.run(
        executable = stark_toolchain.internal.compiler,
        inputs = srcs + module_dirs + [stark_toolchain.internal.static_runtime],
        outputs = [out],
        arguments = [args],
        mnemonic = "StarkC",
    )

def starktest(ctx, srcs, out, deps = []):
    """starktest run tests from sources.

    Args:
        ctx: analysis context.
        srcs: list of source Files to be compiled.
        out: output file,
        deps: list of StarkModuleInfo objects for direct dependencies.
    """

    stark_toolchain = ctx.toolchains["@rules_stark//stark:toolchain_type"]

    modules = []
    for dep in deps:
        modules.append("{parent}/{name}".format(parent = ctx.build_file_path.split('/')[::-1][1], name = dep.dir.basename))
    module_path = ""
    if len(modules) > 0:
        module_path = "-m " + ":".join([m for m in modules])

    script = "{test_runner} -i {interpreter} {module_path} {srcs}".format(
        test_runner = stark_toolchain.internal.test_runner.path,
        interpreter = stark_toolchain.internal.interpreter.path,
        module_path = module_path,
        srcs = " ".join([src.path for src in srcs]),
    )
    
    ctx.actions.write(
        output = out,
        content = script,
        is_executable = True,
    )
