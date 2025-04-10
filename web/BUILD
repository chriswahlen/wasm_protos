load("//tools:copy_bundle.bzl", "copy_bundle")

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
    "//web/javascript/jslib:jslib_js",
    "//main:hello-world-wasm",
    "//main/proto:web_proto_bundle"
  ],
  out_dir = "web_bundle",
)
