# Starlark rule for copying a bunch of files to the output directory,
# preserving relative paths.
def _copy_bundle_impl(ctx):
  out_dir = ctx.actions.declare_directory(ctx.attr.out_dir)

  # Write both the full path and the relative path for each source,
  # separated by a tab. If the paths are local to the build, the full
  # and relative paths are the same; otherwise the full path has the
  # bazel-out/ path in front of it.
  input_paths = []
  for f in ctx.files.srcs:
    input_paths.append("{}\t{}".format(f.path, f.short_path))

  # Write the manifest. Note that a newline at the end is required,
  # otherwise the last line is skipped.
  manifest = ctx.actions.declare_file(ctx.label.name + "_manifest.txt")
  ctx.actions.write(
    output = manifest,
    content = "\n".join(input_paths) + "\n",
  )

  # Copy files from the local manifest.
  ctx.actions.run_shell(
    inputs = ctx.files.srcs + [manifest],
    outputs = [out_dir],
    command = """
    out_dir="$1"
    manifest="$2"
    while IFS= read -r line; do
      abs_path="${{line%%$'\\t'*}}"
      rel_path="${{line#*$'\\t'}}"
      dest="{out_dir}/$rel_path"
      mkdir -p "$(dirname "$dest")"
      cp "$abs_path" "$dest"
    done < "$manifest"
    """.format(
      out_dir = out_dir.path,
      manifest = manifest.path,
    ),
    arguments = [out_dir.path, manifest.path],
    progress_message = "Copying bundle to {}".format(out_dir.path),
  )
  return DefaultInfo(files = depset([out_dir]))

copy_bundle = rule(
  implementation = _copy_bundle_impl,
  attrs = {
    "srcs": attr.label_list(allow_files = True),
    "out_dir": attr.string(mandatory = True),
  },
)

# Create a local alias of the source file. Makes it easier to reference the protobuf.min.js dependency
# from another build repo without needing to redefine the protobufjs dependency there.
def local_alias(name, src):
  filename = src.split(":")[-1]

  native.genrule(
    name = name,
    srcs = [src],
    outs = [filename],
    cmd = "cp $(location {}) $@".format(src),
  )
