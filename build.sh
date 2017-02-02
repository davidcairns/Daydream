git clone -b master git@github.com:gizmosachin/Daydream.git ./source

jazzy \
	--min-acl internal \
	--clean \
	--source-directory ./source/Daydream \
	--output docs

rm -rf ./source

open "docs/index.html"
