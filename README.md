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

# Load rules from git repository
# Note: this should be moved to http_archive when released

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
git_repository(
    name = "rules_stark",
    remote = "https://github.com/zippy1978/rules_stark.git",
    branch = "main",
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
    # This keeps moving, until released
    # sha256 = "2b60e615b0af7563a2c0ecf0715d233fe7d01f01ccbbf547cf1de1b2523be2ac",
    urls = ["https://github.com/zippy1978/stark/releases/download/snapshot/Stark-Darwin-x86_64-0.0.1.zip"],
)

stark_download(
    name = "stark_linux_x86_64",
    arch = "x86_64",
    os = "Linux",
    # This keeps moving, until released
    # sha256 = "6f1977ab0fa80ca998d102322436991df09256e48ffd6dd2315aeb7bec0a08c5",
    urls = ["https://github.com/zippy1978/stark/releases/download/snapshot/Stark-Linux-x86_64-0.0.1.zip"],
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