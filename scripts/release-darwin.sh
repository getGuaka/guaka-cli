source ./scripts/release-common.sh

[ -z ${VERSION+x} ] && { echo "VERSION is missing"; exit 1; }

release $VERSION "darwin" "bin/darwin/guaka"
