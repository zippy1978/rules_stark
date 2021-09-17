load(
    ":actions.bzl",
    "starkc",
    "starktest",
)

def _stark_toolchain_impl(ctx):
    # starkc
    compiler = None
    for f in ctx.files.tools:
        if f.path.endswith("/bin/starkc"):
            compiler = f
            break
    if not compiler:
        fail("could not locate starkc command")

    # stark
    interpreter = None
    for f in ctx.files.tools:
        if f.path.endswith("/bin/stark"):
            interpreter = f
            break
    if not interpreter:
        fail("could not locate stark command")

    # starktest
    test_runner = None
    for f in ctx.files.tools:
        if f.path.endswith("/bin/starktest"):
            test_runner = f
            break
    if not test_runner:
        fail("could not locate starktest command")

    # Static runtime
    runtime = None
    for f in ctx.files.runtimes:
        if f.path.endswith("/lib/libstark.a"):
            runtime = f
            break
    if not runtime:
        fail("could not locate runtime (libstark.a)")
    env = {"STARK_RUNTIME": runtime.path}

    # Return a TooclhainInfo provider. This is the object that rules get
    # when they ask for the toolchain.
    return [platform_common.ToolchainInfo(
        # Functions that generate actions. Rules may call these.
        # This is the public interface of the toolchain.
        compile = starkc,
        test = starktest,

        # Internal data. Contents may change without notice.
        # Think of these like private fields in a class. Actions may use these
        # (they are methods of the class) but rules may not (they are clients).
        internal = struct(
            compiler = compiler,
            interpreter = interpreter,
            test_runner = test_runner,
            static_runtime = runtime,
            env = env,
            tools = ctx.files.tools,
            runtimes = ctx.files.runtimes,
        ),
    )]

stark_toolchain = rule(
    implementation = _stark_toolchain_impl,
    attrs = {
        "tools": attr.label_list(
            mandatory = True,
            doc = "Compiler, and other executables from the Stark distribution",
        ),
        "runtimes": attr.label_list(
            mandatory = True,
            doc = "Runtimes from the Stark distribution",
        ),
    },
    doc = "Gathers functions and file lists needed for a Stark toolchain",
)
