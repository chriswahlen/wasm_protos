load("//tools:js_proto_gen.bzl", "js_proto_bundle")
load("//tools:copy_bundle.bzl", "copy_bundle")

js_proto_bundle(
  name = "web_protos",
  srcs = [
    "//main/proto:all_protos",
  ],
  bundle_name = "js/proto_bundle.js",
)

filegroup(
  name = "web_bundle",
  srcs = [
    "hello.html",
    "javascript/main.js",
    "third_party/protobuf.min.js",
  ],
)

copy_bundle(
  name = "copy_web_bundle",
  srcs = [
    ":web_bundle",
    ":web_protos",
    "//web/javascript/jslib:jslib_js",
    "//main:hello-world-wasm",
  ],
  out_dir = "web_bundle",
)
