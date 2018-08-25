[ -z ${VERSION+x} ] && { echo "VERSION is missing"; exit 1; }
[ -z ${GITHUB_TOKEN+x} ] && { echo "GITHUB_TOKEN is missing"; exit 1; }

github-release release --user getGuaka --security-token ${GITHUB_TOKEN} --repo guaka-cli --tag ${VERSION} --name "Version ${VERSION}"
