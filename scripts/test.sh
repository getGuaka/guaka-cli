if [[ "${TRAVIS_OS_NAME}" == "osx" ]]; then make test-darwin ; fi
if [[ "${TRAVIS_OS_NAME}" == "linux" ]]; then make test-linux ; fi
