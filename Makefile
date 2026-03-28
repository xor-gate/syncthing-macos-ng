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
force-clear-caches:
	rm -rf ~/Library/Developer/Xcode/DerivedData/*
	rm -rf ~/Library/Caches/org.swift.swiftpm
	rm -rf ~/Library/org.swift.swiftpm
	rm -rf ~/Library/Developer/CoreSimulator/Caches
