# YT Kiosk — YouTube Kiosk Launcher cho iPhone 4S / iOS 9.3.6 (Jailbreak)

Ứng dụng biến iPhone 4s / iOS 9 thành một **máy xem YouTube chuyên dụng** siêu nhẹ, mượt mà, tự động chặn quảng cáo, lưu lại lịch sử xem, tự sinh đề xuất video và tích hợp sẵn công cụ dọn dẹp RAM / tắt các dịch vụ nền gây nặng máy của Apple.

---

## 🌟 Tính năng nổi bật

1. **Nhân WebKit Nitro JIT (`WKWebView`)**: Tăng tốc độ render JavaScript gấp 3-4 lần so với UIWebView cũ, cuộn trang mượt mà trên chip Apple A5.
2. **Lưu lịch sử & Tự động đề xuất**: Giữ lại cookies và localStorage của phiên xem, tự động đề xuất video theo sở thích ở trang chủ mà không bắt buộc phải đăng nhập lại mỗi lần mở app.
3. **Ép độ phân giải 360p / 480p**: Tự động ép video HTML5 phát ở chất lượng 360p (Medium) giúp chip A5 giải mã phần cứng siêu nhẹ, không bị nóng máy hay tràn RAM.
4. **Tự động chặn quảng cáo & CSS tối ưu**: Ẩn các banner, hiệu ứng đổ bóng, blur, ánh sáng môi trường và tự động bấm nút *Skip Ad* / tua nhanh quảng cáo.
5. **Nút bấm Tối ưu RAM & Tắt Services (`⚡`)**: Tích hợp sẵn nút dọn dẹp RAM và tắt các tiến trình rác của Apple (`ReportCrash`, `assistantd`, `homed`, `healthd`, `gamecenterd`, `passd`, `softwareupdated`...) trực tiếp ngay trong app.
6. **Cử chỉ điều hướng thông minh**:
   - Vuốt sang phải: Quay lại trang trước (Back).
   - Vuốt sang trái: Tiến tới trang sau (Forward).
   - Chạm 2 ngón tay 2 lần (Double Tap): Tải lại trang chủ YouTube.

---

## 📲 Hướng dẫn cài đặt Activator trên iOS 9.3.6 (Phoenix Jailbreak)

Trên iOS 9.3.6, chứng chỉ SSL mặc định của Cydia đã hết hạn dẫn đến việc tải tweak bị lỗi đỏ hoặc không cài được Activator. Hãy làm theo đúng thứ tự 3 bước sau:

### Bước 1: Sửa lỗi chứng chỉ SSL cho Cydia
1. Mở **Cydia** -> chọn tab **Các nguồn (Sources)** -> **Sửa (Edit)** -> **Thêm (Add)**:
   ```text
   http://cydia.invoxiplaygames.uk/certificates
   ```
   *(Lưu ý: Dùng `http://` thay vì `https://`)*
2. Vào nguồn vừa thêm, tìm và cài đặt gói: **`ISRG Root X1 CA (Let's Encrypt)`** (hoặc `Cydia HTTPatch`).

### Bước 2: Thêm nguồn chính thức của tác giả Activator
1. Trong Cydia, bấm **Sửa (Edit)** -> **Thêm (Add)** nguồn:
   ```text
   http://rpetri.ch/repo
   ```
2. Chờ Cydia tải lại dữ liệu (Reloading Data) xong.

### Bước 3: Cài đặt các gói theo đúng thứ tự
1. Cài gói: **`RocketBootstrap`** (từ nguồn rpetri.ch).
2. Cài gói: **`Flipswitch`** (từ nguồn rpetri.ch).
3. Cài gói: **`Activator`**.
4. Bấm **Khởi động lại SpringBoard (Restart SpringBoard)**.

---

## 🚀 Thiết lập máy tự mở YouTube khi bật nguồn (Kiosk Mode)

1. Mở ứng dụng **Activator** trên màn hình chính.
2. Chọn **Tại mọi nơi (Anywhere)** -> Chọn mục **Thiết bị đã khởi động xong (Device Boot Completes)**.
3. Chọn ứng dụng **YT Kiosk**.
4. (Tùy chọn) Chọn thêm cử chỉ **Mở khóa màn hình (Springboard Wakes Up)** -> Mở **YT Kiosk**.

---

## 🛠️ Tự động Build IPA bằng GitHub Actions

Repo đã cấu hình sẵn GitHub Actions workflow:
1. Mỗi khi bạn `git push` code lên GitHub, mục **Actions** sẽ tự động build file IPA trong vòng ~1 phút.
2. Vào tab **Actions** -> Chọn lượt build mới nhất -> Tải file **`YTKiosk-IPA`** ở mục Artifacts.
3. Dùng **Sideloadly** hoặc **Filza** để cài file `.ipa` vào iPhone 4s.
