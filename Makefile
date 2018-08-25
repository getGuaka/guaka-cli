install:
	make build-project
	cp bin/guaka ~/bin/guaka

test:
	bash scripts/test.sh

test-darwin: generate
	xcodebuild -project guaka-cli.xcodeproj -scheme guaka-cli-Package build test

test-linux:
	swift test

coverage:
	slather coverage guaka-cli.xcodeproj

generate:
	swift package generate-xcodeproj --enable-code-coverage

clean-darwin:
	rm -rf bin/darwin
	rm -rf release/darwin

clean-linux:
	rm -rf bin/linux
	rm -rf release/linux

clean:
	rm -rf .build
	make clean-darwin
	make clean-linux

build-project:
	swift build -Xswiftc -static-stdlib

build-project-darwin:
	mkdir -p bin/darwin
	make build-project
	cp ./.build/debug/guaka-cli bin/darwin/guaka
	@echo "\nDarwin version built at bin/darwin/guaka\n"

build-project-linux:
	mkdir -p bin/linux
	make build-project
	cp -f ./.build/debug/guaka-cli bin/linux/guaka

release-darwin:
	bash scripts/release-darwin.sh

release-darwin-local:
	rm -rf .build
	make build-project-darwin
	bash scripts/release-darwin.sh

release-linux:
	bash scripts/release-linux.sh

release-linux-local:
	rm -rf .build
	make clean-linux
	make build-project-linux

publish-local-darwin:
	bash scripts/publish-homebrew-mac.sh

build-linux-docker:
	@echo "Runs release-linux-local inside a docker image"
	@echo "The built file is located at bin/linux/guaka"
	docker run --volume `pwd`:`pwd` --workdir `pwd` swift:4.1.3 make release-linux-local
	@echo "\nLinux version built at bin/linux/guaka\n"

build-all-local: clean build-linux-docker build-project-darwin
	@echo "Binaries built at bin/\n"

release-local:
	make build-all-local
	@echo "Starting the github release for version ${VERSION}/\n"
	bash scripts/github-release.sh

	@echo "Upload darwin binary\n"
	bash scripts/release-darwin.sh

	@echo "Upload linux binary\n"
	bash scripts/release-linux.sh

publish-local:
	make publish-local-darwin

release-publish-local:
	make release-local
	make publish-local

release-and-deploy:
	if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then make build-project-darwin release-darwin VERSION=${TRAVIS_TAG} ; fi
	if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then make build-project-linux release-linux VERSION=${TRAVIS_TAG} ; fi

sha256:
	@shasum -a 256 bin/guaka | cut -f 1 -d " "
