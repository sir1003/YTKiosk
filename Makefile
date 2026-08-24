ARCHS = armv7
TARGET = iphone:clang:9.3:9.0

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = YTKiosk

YTKiosk_FILES = Classes/main.m Classes/AppDelegate.m Classes/KioskViewController.m Classes/AdBlockProtocol.m
YTKiosk_FRAMEWORKS = UIKit Foundation CoreGraphics
YTKiosk_INFOPLIST = Resources/Info.plist
YTKiosk_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/application.mk

after-all::
	@echo "==> Đang đóng gói IPA..."
	rm -rf ./Payload
	mkdir -p ./Payload
	cp -r $(THEOS_OBJ_DIR)/YTKiosk.app ./Payload/ 2>/dev/null || cp -r .theos/obj/debug/YTKiosk.app ./Payload/ 2>/dev/null || cp -r .theos/obj/YTKiosk.app ./Payload/ 2>/dev/null || true
	rm -f YTKiosk.ipa
	zip -r YTKiosk.ipa Payload
	rm -rf ./Payload
	@echo "==> Đã đóng gói xong YTKiosk.ipa"
