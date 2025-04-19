load("@bazel_skylib//lib:paths.bzl", "paths")

# Creates the javascript output for the proto files compiled via protobufjs-cli and bundles them together.
#   bundle_name: The output filename of the js bundle.
#   export_names: An array of the output filenames for the helper export js.
#                 The names are based from the proto packages, so backage foo.bar outputs
#                 a file called "foo_bar.js".
# TODO: Find a way to call pbjs using something like rules_nodejs. This is pretty hacky.
# TODO: Find a way to automatically determine what the export_names should be.
def js_proto_bundle(name, srcs, bundle_name, export_names, visibility = None):
  emit_script = Label("//tools:emit_proto_exports.py")

  native.genrule(
    name = name,
    srcs = srcs + [emit_script],
    outs = [bundle_name] + export_names,
    cmd = """
      # create a list of files that excludes the emit script.
      PROTO_SRCS=""
      BUNDLE_BASENAME=`basename {out_file}`
      emit_script_path=$(location {script})
      for f in $(SRCS); do
        if [ "$$f" != "$$emit_script_path" ]; then
          PROTO_SRCS="$$PROTO_SRCS $$f"
        fi
      done
      $(location {script}) $$BUNDLE_BASENAME $(@D) $$PROTO_SRCS

      # Hack: install protobufjs in the execroot...
      cat > package.json <<EOF
{{
  "devDependencies": {{
    "protobufjs-cli": "^1.1.3"
  }}
}}
EOF
      npm install protobufjs-cli
      BUNDLE_FILE="$(@D)/$$BUNDLE_BASENAME"
      BUNDLE_FILE_TMP=tmp/bundle.js
      mkdir -p tmp
      # Relative include path so protos can find dependencies.
      # Also add external as an include path because that is where bazel
      # sticks any externally referenced repo.
      npx pbjs -p ./ -p ./external/ -t static --wrap es6 $$PROTO_SRCS > tmp/tmp.bundle.js
      echo "const \\$$protobuf = protobuf;" > $$BUNDLE_FILE
      cat tmp/tmp.bundle.js >> $$BUNDLE_FILE
    """.format(
      out_file=bundle_name,
      script = emit_script,
    ),
    tools = [emit_script],
    visibility = visibility or ["//visibility:public"],
  )

# Creates exports for easily consuming the protos
def js_proto_export(name, srcs, out_name = None, visibility = None):
  out_name = out_name or (name + "_exported.js")
  emit_script = Label("//tools:emit_proto_exports.py")
  proto_srcs = [s for s in srcs]
  native.genrule(
    name = name,
    srcs = proto_srcs + [emit_script],
    outs = [out_name],
    cmd = """
      # Only write real proto files to the input list
      > $(@D)/proto_inputs.txt
      for f in {proto_locations}; do
        echo "$$f" >> $(@D)/proto_inputs.txt
      done
      # $(location {script}) $(@D)/proto_inputs.txt > $@
      $(location {script}) $(@D)/proto_inputs.txt
    """.format(
        proto_locations = "$(locations {})".format(" ".join(proto_srcs)),
        script = emit_script,
    ),
    tools = [emit_script],
    visibility = visibility or ["//visibility:public"],
  )



# Conjure up a protobuf.min.js.
# TODO: Find a way to grab this out of the locally installed npm repo. This is very hacky.
def generate_protobufjs_dep(name, out, visibility = None):
  native.genrule(
    name = name,
    outs = [out],
    cmd = """
      # Hack: install protobufjs in the execroot...
      cat > package.json <<EOF
{{
  "dependencies": {{
    "protobufjs": "^7.2.4"
  }}
}}
EOF
      npm install protobufjs
      mkdir -p $(@D)
      cp node_modules/protobufjs/dist/minimal/protobuf.min.js $(@D)/{out_file}
    """.format(
      out_file = out
    ),
    visibility = visibility or ["//visibility:public"],
  )
