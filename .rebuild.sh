rm -rf ./temp_master

git clone -b master git@github.com:timdonnelly/Advance.git ./temp_master

jazzy \
  --clean \
  --source-directory ./temp_master \
  --output docs

rm -rf ./temp_master

open "docs/index.html"
