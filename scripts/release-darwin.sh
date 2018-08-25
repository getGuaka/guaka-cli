source ./scripts/release-common.sh

[ -z ${VERSION+x} ] && { echo "VERSION is missing"; exit 1; }
[ -z ${GITHUB_TOKEN+x} ] && { echo "GITHUB_TOKEN is missing"; exit 1; }

release $VERSION "darwin" "bin/darwin/guaka" $GITHUB_TOKEN
