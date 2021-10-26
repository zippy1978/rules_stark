load(
    "@rules_stark//stark:defs.bzl",
    "stark_binary",
    "stark_module",
    "stark_clang_module",
    "stark_test",
)

stark_module(
    name = "greetings",
    srcs = glob(["src/modules/greetings/*.st"]),
)

stark_clang_module(
    name = "math_bridge",
    srcs = glob(["src/modules/math_bridge/*.c"]),
    hdr = "src/modules/math_bridge/bridge.sth",
)

stark_module(
    name = "math",
    srcs = glob(["src/modules/math/*.st"]),
    deps = [
        ":math_bridge",
    ],
)

stark_test(
    name = "math_tests",
    srcs = glob(["tests/modules/math/*.test.st"]),
    deps = [
        ":math",
    ],
)

stark_binary(
    name = "main",
    srcs = glob(["src/main/*.st"]),
    deps = [
        ":greetings",
        ":math",
        ":math_bridge",
    ],
)
