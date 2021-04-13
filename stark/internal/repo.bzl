def _stark_download_impl(ctx):
    # Download the Stark distribution.
    ctx.report_progress("downloading")
    ctx.download_and_extract(
        ctx.attr.urls,
        sha256 = ctx.attr.sha256,
    )

    # Add a build file to the repository root directory.
    # We need to fill in some template parameters, based on the platform.
    ctx.report_progress("generating build file")
    if ctx.attr.os == "Darwin":
        os_constraint = "@platforms//os:osx"
    elif ctx.attr.os == "Linux":
        os_constraint = "@platforms//os:linux"
    else:
        fail("unsupported os: " + ctx.attr.os)
    if ctx.attr.arch == "x86_64":
        arch_constraint = "@platforms//cpu:x86_64"
    else:
        fail("unsupported arch: " + ctx.attr.arch)
    constraints = [os_constraint, arch_constraint]
    constraint_str = ",\n        ".join(['"%s"' % c for c in constraints])

    substitutions = {
        "{os}": ctx.attr.os,
        "{arch}": ctx.attr.arch,
        "{exec_constraints}": constraint_str,
        "{target_constraints}": constraint_str,
    }
    ctx.template(
        "BUILD.bazel",
        ctx.attr._build_tpl,
        substitutions = substitutions,
    )

stark_download = repository_rule(
    implementation = _stark_download_impl,
    attrs = {
        "urls": attr.string_list(
            mandatory = True,
            doc = "List of mirror URLs where a Stark distribution archive can be downloaded",
        ),
        "sha256": attr.string(
            mandatory = True,
            doc = "Expected SHA-256 sum of the downloaded archive",
        ),
        "os": attr.string(
            mandatory = True,
            values = ["Darwin", "Linux"],
            doc = "Host operating system for the Stark distribution",
        ),
        "arch": attr.string(
            mandatory = True,
            values = ["x86_64"],
            doc = "Host architecture for the Go distribution",
        ),
        "_build_tpl": attr.label(
            default = "//stark/internal:BUILD.dist.bazel.tpl",
        ),
    },
    doc = "Downloads a standard Stark distribution and installs a build file",
)
