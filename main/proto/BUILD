load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_proto_library")
load("@rules_proto//proto:defs.bzl", "proto_library")
load("//tools:js_proto_bundle.bzl", "js_proto_bundle")

proto_library(
  name = "hello_proto",
  srcs = ["hello.proto"],
  visibility = ["//visibility:public"],
)

cc_proto_library(
  name = "hello_cc_proto",
  deps = [":hello_proto"],
  visibility = ["//visibility:public"],
)

proto_library(
  name = "goodbye_proto",
  srcs = ["goodbye.proto"],
  visibility = ["//visibility:public"],
)

cc_proto_library(
  name = "goodbye_cc_proto",
  deps = [":goodbye_proto"],
  visibility = ["//visibility:public"],
)

js_proto_bundle(
  name = "web_proto_bundle",
  srcs = [
    "hello.proto",
    "goodbye.proto"
  ],
  bundle_name = "proto_bundle.js",
  visibility = ["//web:__pkg__"],
)