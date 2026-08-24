ARCHS = armv7
TARGET = iphone:clang:9.3:9.0

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = YTKiosk

YTKiosk_FILES = Classes/main.m Classes/AppDelegate.m Classes/KioskViewController.m Classes/AdBlockProtocol.m
YTKiosk_FRAMEWORKS = UIKit Foundation CoreGraphics
YTKiosk_INFOPLIST = Resources/Info.plist
YTKiosk_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/application.mk

# Sau khi build xong .app, đóng gói lại thành .ipa chuẩn (thư mục Payload/ + zip)
# để dùng được với các công cụ sideload (Cydia Impactor / AltStore / 3uTools...)
package: all
	rm -rf ./Payload
	mkdir -p ./Payload
	cp -r ./.theos/obj/debug/YTKiosk.app ./Payload/
	rm -f YTKiosk.ipa
	zip -r YTKiosk.ipa Payload
	rm -rf ./Payload
	@echo "==> Xuất xong: YTKiosk.ipa (chưa ký). Cần ldid -S hoặc chữ ký hợp lệ trước khi cài."
