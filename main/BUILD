load("@rules_cc//cc:defs.bzl", "cc_binary")
load("@emsdk//emscripten_toolchain:wasm_rules.bzl", "wasm_cc_binary")

WASM_LINKER_OPTIONS = [
  "-sMODULARIZE=1",
  "-sEXPORT_ES6=1",
  "-sENVIRONMENT=web",
  "-sNO_EXIT_RUNTIME=1",
  "-sEXPORTED_FUNCTIONS=['_say_hello,_main','_malloc','_free']",
  "-sEXPORTED_RUNTIME_METHODS=['ccall']",
  "--no-entry",
]

WASM_OPTIONS = [
  "--no-entry",
]

cc_binary(
  name = "hello-world",
  srcs = ["hello-world.cc"],
  deps = [
    "//main/proto:hello_cc_proto",
    "//main/proto:goodbye_cc_proto",
  ],
  copts = WASM_OPTIONS,
  linkopts = WASM_LINKER_OPTIONS,
)

wasm_cc_binary(
  name = "hello-world-wasm",
  cc_target = ":hello-world",
  visibility = ["//visibility:public"],
)
