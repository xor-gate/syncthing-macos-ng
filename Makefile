DIST_DIR=./.build/dist

all:
build:
	swift build
run:
	swift run
test:
	swift test

dist: Syncthing.app

sign:
	codesign --force --deep --sign - "$(DIST_DIR)/STLoginHelper.app"

clean:
	swift package clean
clean-all:
	rm -Rf .build
	rm -Rf .swiftpm
clean-caches:
	rm -rf ~/Library/Developer/Xcode/DerivedData/*
	rm -rf ~/Library/Caches/org.swift.swiftpm
	rm -rf ~/Library/org.swift.swiftpm
	rm -rf ~/Library/Developer/CoreSimulator/Caches

STLoginHelper: $(DIST_DIR)/STLoginHelper
$(DIST_DIR)/STLoginHelper: 
	swift build -c release --product STLoginHelper --triple arm64-apple-macosx
	swift build -c release --product STLoginHelper --triple x86_64-apple-macosx
	mkdir -p $(DIST_DIR)
	lipo -create \
		.build/arm64-apple-macosx/release/STLoginHelper \
		.build/x86_64-apple-macosx/release/STLoginHelper \
		-output "$(DIST_DIR)/STLoginHelper"

STLoginHelper.app: $(DIST_DIR)/STLoginHelper.app
$(DIST_DIR)/STLoginHelper.app: $(DIST_DIR)/STLoginHelper
	swift build -c release --product STLoginHelper --triple arm64-apple-macosx
	swift build -c release --product STLoginHelper --triple x86_64-apple-macosx
	mkdir -p ".build/dist/STLoginHelper.app/Contents"
	mkdir -p ".build/dist/STLoginHelper.app/Contents/MacOS"
	mkdir -p ".build/dist/STLoginHelper.app/Contents/Resources"
	cp "$(DIST_DIR)/STLoginHelper" ".build/dist/STLoginHelper.app/Contents/MacOS"
	cp "Sources/STLoginHelperMain/Info.plist" ".build/dist/STLoginHelper.app/Contents"

Syncthing: $(DIST_DIR)/Syncthing
$(DIST_DIR)/Syncthing: 
	swift build -c release --product Syncthing --triple arm64-apple-macosx
	swift build -c release --product Syncthing --triple x86_64-apple-macosx
	mkdir -p $(DIST_DIR)
	lipo -create \
		.build/arm64-apple-macosx/release/Syncthing \
		.build/x86_64-apple-macosx/release/Syncthing \
		-output "$(DIST_DIR)/Syncthing"

Syncthing.app: $(DIST_DIR)/Syncthing.app
$(DIST_DIR)/Syncthing.app: $(DIST_DIR)/Syncthing $(DIST_DIR)/STLoginHelper.app
	swift build -c release --product Syncthing --triple arm64-apple-macosx
	swift build -c release --product Syncthing --triple x86_64-apple-macosx
	mkdir -p ".build/dist/Syncthing.app/Contents"
	mkdir -p ".build/dist/Syncthing.app/Contents/MacOS"
	mkdir -p ".build/dist/Syncthing.app/Contents/Resources"
	mkdir -p ".build/dist/Syncthing.app/Contents/Frameworks"
	mkdir -p ".build/dist/Syncthing.app/Contents/Library/LoginItems"
	cp -r "$(DIST_DIR)/STLoginHelper.app" ".build/dist/Syncthing.app/Contents/Library/LoginItems"
	cp -R ".build/release/Sparkle.framework" ".build/dist/Syncthing.app/Contents/Frameworks"
	cp "$(DIST_DIR)/Syncthing" ".build/dist/Syncthing.app/Contents/MacOS"
	cp "Sources/STMacOsApplicationMain/Info.plist" ".build/dist/Syncthing.app/Contents"
	install_name_tool -add_rpath "@executable_path/../Frameworks" ".build/dist/Syncthing.app/Contents/MacOS/Syncthing"
