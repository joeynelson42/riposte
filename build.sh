#!/bin/bash

echo "Starting Build Script"

echo "Quitting Godot"
osascript -e 'quit app "Godot"'

sleep .5

echo "Building Extension"
cd Riposte/
swift build --configuration debug
cd ..

echo "Copying Extension"
cp Riposte/.build/arm64-apple-macosx/debug/libRiposte.dylib Example/bin/libRiposte.dylib
cp Riposte/.build/arm64-apple-macosx/debug/libSwiftGodot.dylib Example/bin/libSwiftGodot.dylib
cp Riposte/.build/arm64-apple-macosx/debug/libGDLasso.dylib Example/bin/libGDLasso.dylib

sleep .5

echo "Opening Godot"
open Example/project.godot

echo "Finished Build Script"
