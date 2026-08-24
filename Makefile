ARCHS = armv7 arm64
TARGET = iphone:clang:14.5:9.0

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = YTKiosk

YTKiosk_FILES = Classes/main.m Classes/AppDelegate.m Classes/KioskViewController.m Classes/AdBlockProtocol.m
YTKiosk_FRAMEWORKS = UIKit Foundation CoreGraphics
YTKiosk_INFOPLIST = Resources/Info.plist
YTKiosk_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-deprecated-module-dot-map

include $(THEOS_MAKE_PATH)/application.mk

after-all::
	@echo "==> Đang đóng gói IPA..."
	rm -rf ./Payload
	mkdir -p ./Payload
	find .theos -type d -name "YTKiosk.app" -exec cp -r {} ./Payload/ \; 2>/dev/null || cp -r $(THEOS_OBJ_DIR)/YTKiosk.app ./Payload/ 2>/dev/null || true
	rm -f YTKiosk.ipa
	zip -r YTKiosk.ipa Payload
	rm -rf ./Payload
	@echo "==> Đã đóng gói xong YTKiosk.ipa"
