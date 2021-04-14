workspace(name = "rules_stark")

load(
    "@rules_stark//stark:deps.bzl", 
    "stark_rules_dependencies",
    "stark_download", 
)

# stark_rules_dependencies declares the dependencies of rules_stark. Any
# project that depends on rules_stark should call this.
stark_rules_dependencies()

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