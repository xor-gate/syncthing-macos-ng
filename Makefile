all:
build:
	swift build
run:
	swift run
test:
	swift test
clean:
	rm -Rf .build
	rm -Rf .swiftpm
