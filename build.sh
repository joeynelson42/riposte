#!/bin/bash

echo "Starting Build Script"

osascript -e 'quit app "Godot"'

cd Riposte/
swift build --configuration debug
cd ..

cp Riposte/.build/arm64-apple-macosx/debug/libRiposte.dylib Example/bin/libRiposte.dylib

open Example/project.godot

echo "Finished Build Script"
