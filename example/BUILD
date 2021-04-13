load(
    "@rules_stark//:defs.bzl",
    "stark_binary",
    "stark_module",
    "stark_test",
)

stark_module(
    name = "greetings",
    srcs = glob(["src/modules/greetings/*.st"]),
)

stark_module(
    name = "math",
    srcs = glob(["src/modules/math/*.st"]),
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
    ],
)
