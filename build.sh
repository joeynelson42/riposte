#!/bin/bash

echo "Starting Build Script"

cd Riposte/
swift build --configuration debug
cd ..

cp Riposte/.build/arm64-apple-macosx/debug/libRiposte.dylib Example/bin/libRiposte.dylib


echo "Finished Build Script"
