load("@bazel_skylib//lib:paths.bzl", "paths")

# Creates the javascript output for the proto files compiled via protobufjs-cli and bundles them together.
# TODO: Find a way to call pbjs using something like rules_nodejs. This is pretty hacky.
def js_proto_bundle(name, srcs, bundle_name, visibility = None):
  native.genrule(
    name = name,
    srcs = srcs, 
    outs = [bundle_name],
    cmd = """
      # Hack: install protobufjs in the execroot...
      cat > package.json <<EOF
{{
  "devDependencies": {{
    "protobufjs-cli": "^1.1.3"
  }}
}}
EOF
      npm install protobufjs-cli
      BUNDLE_BASENAME=`basename {out_file}`
      BUNDLE_FILE="$(@D)/$$BUNDLE_BASENAME"
      BUNDLE_FILE_TMP=tmp/bundle.js
      mkdir -p tmp
      npx pbjs -t static --wrap es6 $(SRCS) > tmp/tmp.bundle.js
      echo "const \\$$protobuf = protobuf;" > $$BUNDLE_FILE
      cat tmp/tmp.bundle.js >> $$BUNDLE_FILE
    """.format(
      out_file=bundle_name,
    ),
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
