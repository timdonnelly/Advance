#!/bin/sh

rm -rf ./Docs

cd SampleApp

bundle install

bundle exec pod install

jazzy \
  --config ../.jazzy.yaml \
  --xcodebuild-arguments -workspace,SampleApp.xcworkspace,-scheme,Advance-iOS \
  --clean \
  --readme ../README.md \
  --output ../Docs


cd ..

open "Docs/index.html"
