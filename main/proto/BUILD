load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_proto_library")
load("@rules_proto//proto:defs.bzl", "proto_library")

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

# Group the protos so it can be read by the js_proto_bundle.
filegroup(
  name = "all_protos",
  srcs = [
    "hello.proto",
    "goodbye.proto"
  ],
  visibility = ["//web:__pkg__"],
)
