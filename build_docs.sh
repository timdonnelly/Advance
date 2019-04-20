#!/bin/sh

rm -rf ./docs

gem install jazzy

jazzy \
  --config .jazzy.yaml \
  --xcodebuild-arguments -project,Advance.xcodeproj,-scheme,Advance-iOS \
  --clean \
  --readme ./README.md \
  --output ./docs
