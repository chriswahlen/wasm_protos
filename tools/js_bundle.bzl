# Starlark rule for creating Javascript "bundles".
def _js_bundle_impl(ctx):
  if ctx.var["COMPILATION_MODE"] == "opt":
    # TODO: Release mode: bundle logic (e.g. zip or combine files)
    out = ctx.actions.declare_file(ctx.label.name + "_release_bundle.txt")
    ctx.actions.write(
      output = out,
      content = "\n".join([f.short_path for f in ctx.files.srcs]),
    )
    return DefaultInfo(files = depset([out]))
  else:
    # Debug mode: pass-through like filegroup
    return DefaultInfo(files = depset(ctx.files.srcs))

js_bundle = rule(
  implementation = _js_bundle_impl,
  attrs = {
    "srcs": attr.label_list(allow_files = True),
  },
)