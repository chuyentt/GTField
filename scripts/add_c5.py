#!/usr/bin/env python3
"""Add C5 (AppOpenAdHelper PBXFileReference) to pbxproj."""
PBX = "GTField.xcodeproj/project.pbxproj"
src = open(PBX).read()

C4_line = '        AA11220330440550660770C4 /* InterstitialHelper.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = InterstitialHelper.swift; sourceTree = "<group>"; };'
C5_line = '        AA11220330440550660770C5 /* AppOpenAdHelper.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppOpenAdHelper.swift; sourceTree = "<group>"; };'

if C4_line in src and C5_line not in src:
    src = src.replace(C4_line, C4_line + "\n" + C5_line)
    print("Added C5 PBXFileReference")
elif C5_line in src:
    print("C5 already present")
else:
    print("ERROR: C4 line not found!")
    print("Looking for:", repr(C4_line[:80]))

open(PBX, "w").write(src)
