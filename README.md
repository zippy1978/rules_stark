![Stark](https://github.com/zippy1978/stark/raw/main/logo/StarkLogoDark.png)

# Stark rules for Bazel

This repository contains Stark rules for bazel.

This includes:

- stark_bin
- stark_module
- stark_test

## Project setup

In order to setup a Stark project with Bazel, add the snippet below to your ``WORKSPACE`` file :

```bzl
workspace(name = "my-project")

# Load rules

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "rules_stark",
    strip_prefix = "rules_stark-main",
    urls = ["https://github.com/zippy1978/rules_stark/archive/refs/heads/main.zip"],
)

# Dependencies and Stark binary packages + tootchains registration

load(
    "@rules_stark//stark:deps.bzl", 
    "stark_rules_dependencies",
    "stark_download", 
)

stark_rules_dependencies()

# Note: this will be moved to a stark_register_toolchains when Stark will be released

stark_download(
    name = "stark_darwin_x86_64",
    arch = "x86_64",
    os = "Darwin",
    sha256 = "",
    urls = ["https://github.com/zippy1978/stark/releases/download/0.0.1-SNAPSHOT/Stark-Darwin-x86_64-0.0.1-SNAPSHOT.zip"],
)

stark_download(
    name = "stark_linux_x86_64",
    arch = "x86_64",
    os = "Linux",
    sha256 = "",
    urls = ["https://github.com/zippy1978/stark/releases/download/0.0.1-SNAPSHOT/Stark-Linux-x86_64-0.0.1-SNAPSHOT.zip"],
)

register_toolchains(
    "@stark_darwin_x86_64//:toolchain",
    "@stark_linux_x86_64//:toolchain",
)
```

## Writing build files

Once configured Stark rules can be used in any package ``BUILD`` file.

Here is an example:

```bzl

# Load rules
load(
    "@rules_stark//stark:defs.bzl",
    "stark_binary",
    "stark_module",
    "stark_test",
)

# Build module "my_module"
stark_module(
    name = "my_module",
	 srcs = glob(["src/modules/mymodule/*.st"]),
)

# Test module "my_module"
stark_test(
    name = "my_module_tests",
    srcs = glob(["tests/modules/mymodule/*.test.st"]),
    deps = [
        ": my_module",
    ],
)

# Build main executable (depends on "my_module")
stark_binary(
    name = "main",
    srcs = glob(["src/main/*.st"]),
    deps = [
        ":my_module",
    ],
)

```