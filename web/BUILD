load("//tools:copy_bundle.bzl", "copy_bundle")
load("//tools:js_proto_defs.bzl", "generate_protobufjs_dep")

# Generate a local protobuf.min.js to load.
generate_protobufjs_dep(
  name = "protobuf_js",
  out = "protobuf.min.js",
)

filegroup(
  name = "web_bundle",
  srcs = [
    "hello.html",
    "javascript/main.js",
  ],
)

copy_bundle(
  name = "copy_web_bundle",
  srcs = [
    ":protobuf_js",
    ":web_bundle",
    "//main:hello-world-wasm",
    "//main/proto:web_proto_bundle",
    "//web/javascript/jslib:jslib_js",
  ],
  out_dir = "web_bundle",
)

exports_files(["third_party/protobuf.min.js"])
