#!/usr/bin/env python3
"""Inject Shims/AdMobStub.swift + Shims/GooglePlacePickerStub.swift into GTField target.
Idempotent - safe to re-run."""
import re, sys

PBX = "GTField.xcodeproj/project.pbxproj"
src = open(PBX).read()

UUID = {
    "build_admob": "AA11220330440550660770B1",
    "build_picker": "AA11220330440550660770B2",
    "ref_admob": "AA11220330440550660770C1",
    "ref_picker": "AA11220330440550660770C2",
    "group_shims": "AA11220330440550660770A0",
}

inserts = []

# 1. PBXBuildFile entries
build_section_end = "/* End PBXBuildFile section */"
build_block = (
    f"\t\t{UUID['build_admob']} /* AdMobStub.swift in Sources */ = "
    f"{{isa = PBXBuildFile; fileRef = {UUID['ref_admob']} /* AdMobStub.swift */; }};\n"
    f"\t\t{UUID['build_picker']} /* GooglePlacePickerStub.swift in Sources */ = "
    f"{{isa = PBXBuildFile; fileRef = {UUID['ref_picker']} /* GooglePlacePickerStub.swift */; }};\n"
)
if UUID["build_admob"] not in src:
    src = src.replace(build_section_end, build_block + build_section_end, 1)
    inserts.append("PBXBuildFile")

# 2. PBXFileReference entries
ref_section_end = "/* End PBXFileReference section */"
ref_block = (
    f"\t\t{UUID['ref_admob']} /* AdMobStub.swift */ = "
    f"{{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AdMobStub.swift; sourceTree = \"<group>\"; }};\n"
    f"\t\t{UUID['ref_picker']} /* GooglePlacePickerStub.swift */ = "
    f"{{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = GooglePlacePickerStub.swift; sourceTree = \"<group>\"; }};\n"
)
if UUID["ref_admob"] not in src:
    src = src.replace(ref_section_end, ref_block + ref_section_end, 1)
    inserts.append("PBXFileReference")

# 3. PBXGroup Shims
group_section_end = "/* End PBXGroup section */"
group_block = (
    f"\t\t{UUID['group_shims']} /* Shims */ = {{\n"
    f"\t\t\tisa = PBXGroup;\n"
    f"\t\t\tchildren = (\n"
    f"\t\t\t\t{UUID['ref_admob']} /* AdMobStub.swift */,\n"
    f"\t\t\t\t{UUID['ref_picker']} /* GooglePlacePickerStub.swift */,\n"
    f"\t\t\t);\n"
    f"\t\t\tname = Shims;\n"
    f"\t\t\tpath = GTField/Shims;\n"
    f"\t\t\tsourceTree = \"<group>\";\n"
    f"\t\t}};\n"
)
if UUID["group_shims"] + " /* Shims */ = {" not in src:
    src = src.replace(group_section_end, group_block + group_section_end, 1)
    inserts.append("PBXGroup Shims")

# 4. Add Shims to GTField group children (handles 4-space or tab indent)
gtfield_group_pat = re.compile(
    r"(1628239D19AB38A100D08755 /\* GTField \*/ = \{\s*isa = PBXGroup;\s*children = \(\s*\n)"
)
if (UUID["group_shims"] + " /* Shims */,") not in src:
    new_src, n = gtfield_group_pat.subn(
        lambda m: m.group(1) + "\t\t\t\t" + UUID["group_shims"] + " /* Shims */,\n",
        src, count=1
    )
    if n == 1:
        src = new_src
        inserts.append("group children")

# 5. Add to Sources phase of GTField target (16549D9B1A08AC4C00C59D2E)
sources_pat = re.compile(
    r"(16549D9B1A08AC4C00C59D2E /\* Sources \*/ = \{\s*isa = PBXSourcesBuildPhase;\s*buildActionMask = \d+;\s*files = \(\s*\n)"
)
if UUID["build_admob"] + " /* AdMobStub.swift in Sources */," not in src:
    new_src, n = sources_pat.subn(
        lambda m: (m.group(1)
                   + "\t\t\t\t" + UUID["build_admob"] + " /* AdMobStub.swift in Sources */,\n"
                   + "\t\t\t\t" + UUID["build_picker"] + " /* GooglePlacePickerStub.swift in Sources */,\n"),
        src, count=1
    )
    if n == 1:
        src = new_src
        inserts.append("Sources phase")
    else:
        print("WARN: Sources phase pattern not found", file=sys.stderr)

# 6. Bump deployment target if not already
if "IPHONEOS_DEPLOYMENT_TARGET = 10.0;" in src:
    src = src.replace("IPHONEOS_DEPLOYMENT_TARGET = 10.0;", "IPHONEOS_DEPLOYMENT_TARGET = 12.0;")
    inserts.append("deployment target -> 12.0")

open(PBX, "w").write(src)
print("Injected:", inserts if inserts else "nothing (already present)")
