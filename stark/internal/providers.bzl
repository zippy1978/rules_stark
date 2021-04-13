StarkModuleInfo = provider(
    doc = "Stark module provider",
    fields = {
        "test": "test",
        "dir": "Module directory",
        "deps": "A depset of info structs for this module's dependencies",
    },
)

StarkToolchainInfo = provider(
    doc = "Contains information about a Stark toolchain",
    fields = {
        "compile": """Function that compiles a Go package from sources.
        Args:
            ctx: analysis context.
            srcs: list of source Files to be compiled.
            out: output file (for main module) or directory (if module),
            deps: list of StarkModuleInfo objects for direct dependencies.
        """,
    },
)