source ./scripts/release-common.sh

[ -z ${VERSION+x} ] && { echo "VERSION is missing"; exit 1; }

release $VERSION "linux" "bin/linux/guaka" $GITHUB_TOKEN
