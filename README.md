# YT Kiosk — YouTube launcher cho iPhone 4S / iOS 9.3.6 (jailbreak)


## Cấu trúc project
```
YTKiosk/
├── Classes/
│   ├── main.m
│   ├── AppDelegate.h/.m          -> đăng ký AdBlockProtocol, tạo cửa sổ chính
│   ├── KioskViewController.h/.m  -> UIWebView load m.youtube.com, whitelist domain, inject JS chặn ads
│   ├── AdBlockProtocol.h/.m      -> NSURLProtocol chặn request quảng cáo/tracking ở tầng network
│   └── AdBlockDomains.h          -> danh sách domain quảng cáo (dễ sửa/thêm)
├── Resources/Info.plist
├── Makefile        (Theos, target armv7 / iOS 9.0-9.3)
├── control         (cho gói .deb cài qua Cydia/Filza)
└── README.md
```

## Cách A — Theos

1. Cài Theos trên Linux hoặc macOS:
   ```bash
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"
   ```
2. **Cần iOS SDK** — trích `iPhoneOS9.3.sdk` từ Xcode 7.3.1 (Apple không cho tải SDK
   rời, đây là bước bạn phải tự chuẩn bị vì lý do bản quyền). Đặt vào:
   `$THEOS/sdks/iPhoneOS9.3.sdk`
3. Vào thư mục project, build:
   ```bash
   cd YTKiosk
   make package IPA=1      # ra file .deb trong ./packages/, cài thẳng qua Cydia/Filza
   # hoặc:
   make package            # dùng target "package" tự viết trong Makefile -> ra YTKiosk.ipa (chưa ký)
   ```
4. Vì máy đã jailbreak, **không cần ký code thật** — chỉ cần fake-sign bằng `ldid`:
   ```bash
   ldid -S YTKiosk.app/YTKiosk
   ```
   rồi cài qua Filza (copy `.app` vào `/Applications/`, chạy `uicache` qua SSH/NewTerm)
   hoặc đóng gói `.deb` và cài qua Cydia (cách này ổn định hơn `.ipa` trên máy jailbreak).

## Cách B — Xcode 7.3.1 thật (nếu có Mac cũ)

1. Tạo project Xcode "Single View Application" (Objective-C), Deployment Target 9.0.
2. Copy toàn bộ `Classes/*.m/.h` vào project, thay `Info.plist` mặc định bằng file
   trong `Resources/`.
3. Build target Generic iOS Device → Product > Archive → Export → "Development" hoặc
   "Ad Hoc" → ra `.ipa`.
4. Cài qua Cydia Impactor / 3uTools / Filza (SSH). Vì máy jailbreak, cài qua Filza +
   `ldid -S` là nhanh nhất, không cần chứng chỉ Apple Developer.

## Sau khi cài

- Mở Activator (nếu chưa có, cài từ Cydia) → gán "Springboard Wakes Up" hoặc
  "Device Boot Completes" → chọn "Launch YT Kiosk" → máy tự mở thẳng app mỗi khi mở khóa/khởi động.
- Cài Springtomize 3 nếu muốn ẩn toàn bộ icon khác trên SpringBoard, biến máy thành
  "chỉ có 1 app" — Control Center và Notification Center **không bị ảnh hưởng** vì
  đây không phải Guided Access, chỉ là ẩn icon ở tầng SpringBoard.


