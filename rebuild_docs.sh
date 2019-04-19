#!/bin/sh

rm -rf ./Docs

jazzy \
  --config .jazzy.yaml \
  --xcodebuild-arguments -project,Advance.xcodeproj,-scheme,Advance-iOS \
  --clean \
  --readme ./README.md \
  --output ./Docs

open "Docs/index.html"
