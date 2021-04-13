filegroup(
    name = "all_files",
    testonly = True,
    srcs = glob(["**"]) + [
        "//stark:all_files",
    ],
    visibility = ["//visibility:public"],
)

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)
