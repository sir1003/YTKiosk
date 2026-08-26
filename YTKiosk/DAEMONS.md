# Hướng dẫn tối ưu hóa iOS 9.3.6 trên iPhone 4s (Tắt Daemons thừa)

Trên các thiết bị 512MB RAM như iPhone 4s, iOS 9.3.6 chạy ngầm rất nhiều dịch vụ của Apple khiến máy bị giật lag và chỉ còn khoảng 60–80MB RAM trống. 

Nếu máy đã **Jailbreak (Phoenix)**, bạn có thể tắt các Daemons không cần thiết trong thư mục `/System/Library/LaunchDaemons/` để giải phóng thêm **120MB - 180MB RAM**, giúp xem YouTube siêu mượt mà không bao giờ bị văng app.

---

## 1. Cách thực hiện (Qua Filza / iFile hoặc SSH / MTerminal)

### Cách 1: Đổi tên file (An toàn nhất)
Dùng ứng dụng **Filza File Manager** từ Cydia, vào đường dẫn:
```
/System/Library/LaunchDaemons/
```
Tìm các file `.plist` trong danh sách dưới đây và đổi đuôi `.plist` thành `.plist.bak` (hoặc `.disabled`). Sau đó khởi động lại máy.

---

## 2. Danh sách Daemons an toàn 100% có thể tắt (Dành cho máy chỉ xem YouTube)

### 🔹 Siri & Đọc chính tả:
* `com.apple.assistantd.plist`
* `com.apple.assistant_service.plist`
* `com.apple.Dictation_CrashReporter.plist`

### 🔹 Thu thập lỗi & Thống kê hệ thống của Apple:
* `com.apple.CrashHouseKeeping.plist`
* `com.apple.ReportCrash.DirectoryService.plist`
* `com.apple.ReportCrash.Jetsam.plist`
* `com.apple.ReportCrash.SafetyMonitor.plist`
* `com.apple.ReportCrash.SimulateCrash.plist`
* `com.apple.ReportCrash.StackShot.plist`
* `com.apple.ReportCrash.plist`
* `com.apple.awdd.plist`
* `com.apple.aggregated.plist`

### 🔹 Cập nhật phần mềm OTA (Tránh bị hỏi update iOS):
* `com.apple.mobile.softwareupdated.plist`
* `com.apple.softwareupdateservicesd.plist`
* `com.apple.OTAPKIAssetTool.plist`

### 🔹 Ví Apple Pay & Thẻ (iPhone 4s không có phần cứng Apple Pay):
* `com.apple.passd.plist`
* `com.apple.stockholm.plist`

### 🔹 Nhà thông minh (HomeKit) & Sức khỏe (HealthKit):
* `com.apple.homed.plist`
* `com.apple.healthd.plist`

### 🔹 Game Center:
* `com.apple.gamecenter.plist`
* `com.apple.gamed.plist`

---

## 3. Lệnh tắt nhanh qua Terminal / SSH (1 dòng lệnh)

Mở **MTerminal** (hoặc SSH vào iPhone qua cổng 22) gõ:

```bash
su
# Mật khẩu mặc định là: alpine

cd /System/Library/LaunchDaemons
mkdir -p /System/Library/LaunchDaemons_Disabled

# Di chuyển các daemon thừa sang thư mục tạm:
mv com.apple.assistant* com.apple.ReportCrash* com.apple.awdd* com.apple.aggregated* com.apple.mobile.softwareupdated* com.apple.softwareupdateservicesd* com.apple.passd* com.apple.stockholm* com.apple.homed* com.apple.healthd* com.apple.game* /System/Library/LaunchDaemons_Disabled/ 2>/dev/null

# Khởi động lại
reboot
```

> **Lưu ý:** Nếu muốn khôi phục lại bất kỳ tính năng nào, bạn chỉ cần chuyển các file từ `/System/Library/LaunchDaemons_Disabled/` trở lại `/System/Library/LaunchDaemons/`.
