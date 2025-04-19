#!/usr/bin/env python3
import os
import re
import sys

# regex to match top-level message or enum declarations
MSG_PATTERN = re.compile(r'\b(message|enum|service)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{', re.MULTILINE)
# regex to match "package foo;" declarations
PKG_PATTERN = re.compile(r'^\s*package\s+([A-Za-z0-9_\.]+)\s*;')
PKG_NAME_PATTERN = re.compile(r'^[A-Za-z_][A-Za-z0-9_\.]*$')

def IsValidPackageName(name):
  return re.match(PKG_NAME_PATTERN, name)

def StripComments(proto_lines):
  new_lines = []
  for line in proto_lines:
    new_lines.append(re.sub(r'//.*', '', line))
  return new_lines

def WriteLines(file_name, lines):
  with open(file_name, "w") as f:
    for line in lines:
      f.write(line + "\n")

def ExtractPackage(proto_lines):
  pkg_names = []
  for line in proto_lines:
    match = PKG_PATTERN.match(line)
    if match:
      pkg_names.append(match[1])
  return pkg_names

def ExtractSymbols(proto_code):
  symbol_map = {}

  extract_past = 0
  for match in MSG_PATTERN.finditer(proto_code):
    kind, name = match.groups()
    start = match.start()
    if start < extract_past:
      # Nested message/enum/oneof; keep going.
      continue

    # Find matching closing brace
    brace_count = 0
    i = match.end() - 1
    first_brace = None
    while i < len(proto_code):
      if proto_code[i] == '{':
        if first_brace is None:
          first_brace = i + 1
        brace_count += 1
      elif proto_code[i] == '}':
        brace_count -= 1
        if brace_count == 0:
          symbol_map[name] = ExtractSymbols(proto_code[first_brace:i])
          # Any matches found before this point are submessages.
          extract_past = i;
          break
      i += 1
  return symbol_map

# Inputs: list of protos to generate imports for
bundle_basename = sys.argv[1]
output_path = sys.argv[2]
proto_files = sys.argv[3:]

package_tree = dict()
for proto_file in proto_files:
  lines = []
  with open(proto_file, "r") as f2:
    lines = [line for line in f2]
  lines = StripComments(lines)

  pkg_names = ExtractPackage(lines)
  if len(pkg_names) == 0:
    raise Exception("Failed to find package definition in %s" % proto_file)
  if len(pkg_names) > 1:
    raise Exception("Too many package definitions in %s" % proto_file)
  pkg_name = pkg_names[0]

  # Validate the package name since it becomes part of a filename.
  if not IsValidPackageName(pkg_name):
    raise Exception("Invalid package name %s in %s" % (pkg_name, proto_file))
  if not pkg_name in package_tree:
    package_tree[pkg_name] = dict()
  proto_code = "\n".join(lines)
  symbol_map = ExtractSymbols(proto_code)
  for key, value in symbol_map.items():
    if key in package_tree[pkg_name]:
      raise Exception("Duplicate key %s in package %s" % (key, pkg_name))
    package_tree[pkg_name][key] = value

# Write out the generated files, one file for each namespace
for pkg_name, entries in package_tree.items():
  lines = []
  lines.append("import * as _proto_imports_ from './%s';" % bundle_basename)
  for key, value in entries.items():
    lines.append("export const %s = _proto_imports_.%s.%s;" % (key, pkg_name, key))
  out_file_name = re.sub(r'\.', '_', pkg_name) + ".js"
  WriteLines(os.path.join(output_path, out_file_name), lines)
  print("Wrote %s" % os.path.join(output_path, out_file_name))
