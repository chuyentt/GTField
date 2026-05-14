#!/usr/bin/env python3
"""Inject tất cả file trong Shims/ vào GTField target. Idempotent."""
import re, sys

PBX = "GTField.xcodeproj/project.pbxproj"
src = open(PBX).read()

UUID = {
    "build_admob":        "AA11220330440550660770B1",
    "build_picker":       "AA11220330440550660770B2",
    "build_placement":    "AA11220330440550660770B3",
    "build_interstitial": "AA11220330440550660770B4",
    "ref_admob":          "AA11220330440550660770C1",
    "ref_picker":         "AA11220330440550660770C2",
    "ref_placement":      "AA11220330440550660770C3",
    "ref_interstitial":   "AA11220330440550660770C4",
    "group_shims":        "AA11220330440550660770A0",
}

SHIM_FILES = [
    ("build_admob",        "ref_admob",        "AdMobStub.swift"),
    ("build_picker",       "ref_picker",       "GooglePlacePickerStub.swift"),
    ("build_placement",    "ref_placement",    "AdMobBannerPlacement.swift"),
    ("build_interstitial", "ref_interstitial", "InterstitialHelper.swift"),
]

inserts = []

# 1. PBXBuildFile
build_block = ""
for bk, rk, name in SHIM_FILES:
    if UUID[bk] not in src:
        build_block += (f"\t\t{UUID[bk]} /* {name} in Sources */ = "
                        f"{{isa = PBXBuildFile; fileRef = {UUID[rk]} /* {name} */; }};\n")
if build_block:
    src = src.replace("/* End PBXBuildFile section */", build_block + "/* End PBXBuildFile section */", 1)
    inserts.append("PBXBuildFile")

# 2. PBXFileReference
ref_block = ""
for bk, rk, name in SHIM_FILES:
    if UUID[rk] not in src:
        ref_block += (f"\t\t{UUID[rk]} /* {name} */ = {{isa = PBXFileReference; "
                      f"lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = \"<group>\"; }};\n")
if ref_block:
    src = src.replace("/* End PBXFileReference section */", ref_block + "/* End PBXFileReference section */", 1)
    inserts.append("PBXFileReference")

# 3. PBXGroup Shims (xoá cũ, rebuild với đủ children)
old_group_pat = re.compile(r"\t\t" + UUID['group_shims'] + r" /\* Shims \*/ = \{.*?\};\n", re.DOTALL)
src = old_group_pat.sub("", src)
children_lines = "".join(f"\t\t\t\t{UUID[rk]} /* {name} */,\n" for _, rk, name in SHIM_FILES)
group_block = (f"\t\t{UUID['group_shims']} /* Shims */ = {{\n"
               f"\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n{children_lines}\t\t\t);\n"
               f"\t\t\tname = Shims;\n\t\t\tpath = Shims;\n\t\t\tsourceTree = \"<group>\";\n\t\t}};\n")
src = src.replace("/* End PBXGroup section */", group_block + "/* End PBXGroup section */", 1)
inserts.append("PBXGroup Shims")

# 4. GTField group children
gtfield_pat = re.compile(
    r"(1628239D19AB38A100D08755 /\* GTField \*/ = \{\s*isa = PBXGroup;\s*children = \(\s*\n)")
if UUID["group_shims"] + " /* Shims */," not in src:
    new_src, n = gtfield_pat.subn(lambda m: m.group(1) + f"\t\t\t\t{UUID['group_shims']} /* Shims */,\n", src, 1)
    if n: src = new_src; inserts.append("GTField group children")

# 5. Sources phase
sources_pat = re.compile(
    r"(16549D9B1A08AC4C00C59D2E /\* Sources \*/ = \{\s*isa = PBXSourcesBuildPhase;\s*buildActionMask = \d+;\s*files = \(\s*\n)")
lines = "".join(f"\t\t\t\t{UUID[bk]} /* {name} in Sources */,\n"
                for bk, _, name in SHIM_FILES if UUID[bk] + f" /* {name} in Sources */," not in src)
if lines:
    new_src, n = sources_pat.subn(lambda m: m.group(1) + lines, src, 1)
    if n: src = new_src; inserts.append("Sources phase")
    else: print("WARN: Sources phase pattern not found", file=sys.stderr)

open(PBX, "w").write(src)
print("Injected:", inserts if inserts else "nothing (already present)")
