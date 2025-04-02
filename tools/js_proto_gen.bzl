load("@bazel_skylib//lib:paths.bzl", "paths")

# Creates the javascript output for the proto files and bundles them together.
def js_proto_bundle(name, srcs, bundle_name, visibility = None):
  native.genrule(
    name = name,
    srcs = srcs, 
    outs = [bundle_name],
    cmd = """
      BUNDLE_BASENAME=`basename {out_file}`
      BUNDLE_FILE="$(@D)/$$BUNDLE_BASENAME"
      PBJS=$(location //tools:pbjs)
      BUNDLE_FILE_TMP=tmp/bundle.js
      mkdir -p tmp
      $$PBJS -t static --wrap es6 $(SRCS) > tmp/tmp.bundle.js
      echo "const \\$$protobuf = protobuf;" > $$BUNDLE_FILE
      cat tmp/tmp.bundle.js >> $$BUNDLE_FILE
    """.format(out_file=bundle_name),
    tools = ["//tools:pbjs"],
    visibility = visibility or ["//visibility:public"],
  )

