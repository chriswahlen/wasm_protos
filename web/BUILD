load("//tools:js_proto_gen.bzl", "js_proto_bundle")

# hello.html must be renamed because it can't be an input and an output...
genrule(
  name = "copy_web_bundle",
  srcs = [
    "//main:hello-world-wasm",
    "hello.html",
    "javascript/main.js",
  ],
  outs = [
    "js/main.js",
    "js/hello-world.js",
    "js/hello-world.wasm",
    "hello-world.html",
  ],
  cmd = """
    cp $(locations //main:hello-world-wasm) .
    cp hello-world.js $(@D)/js/hello-world.js
    cp hello-world.wasm $(@D)/js/hello-world.wasm
    cp $(location hello.html) $(@D)/hello-world.html
    cp $(location javascript/main.js) $(@D)/js/main.js
  """,
)

js_proto_bundle(
  name = "web_protos",
  srcs = [
    "//main/proto:all_protos",
  ],
  bundle_name = "js/proto_bundle.js",
)