ARCHS = armv7 arm64
TARGET = iphone:clang:14.5:9.0

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = YTKiosk

YTKiosk_FILES = Classes/main.m Classes/AppDelegate.m Classes/KioskViewController.m Classes/AdBlockProtocol.m
YTKiosk_FRAMEWORKS = UIKit Foundation CoreGraphics WebKit
YTKiosk_INFOPLIST = Resources/Info.plist
YTKiosk_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-deprecated-module-dot-map

include $(THEOS_MAKE_PATH)/application.mk

after-all::
	@echo "==> Đang đóng gói IPA chuẩn..."
	rm -rf ./Payload ./YTKiosk.ipa
	mkdir -p ./Payload
	if [ -d "$(THEOS_OBJ_DIR)/YTKiosk.app" ]; then cp -r "$(THEOS_OBJ_DIR)/YTKiosk.app" ./Payload/; else APP_DIR=$$(find .theos -type d -name "YTKiosk.app" | grep -v "/arm" | head -n 1); cp -r "$$APP_DIR" ./Payload/; fi
	chmod -R 755 ./Payload/YTKiosk.app
	zip -r -y -q YTKiosk.ipa Payload
	rm -rf ./Payload
	@echo "==> Đã đóng gói xong YTKiosk.ipa chuẩn cho Sideloadly/AltStore"
