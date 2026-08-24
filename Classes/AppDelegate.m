#import "AppDelegate.h"
#import "KioskViewController.h"
#import "AdBlockProtocol.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Phải đăng ký AdBlockProtocol TRƯỚC khi bất kỳ UIWebView nào bắt đầu tải,
    // vì NSURLProtocol chỉ chặn được các request tạo ra SAU thời điểm đăng ký.
    [NSURLProtocol registerClass:[AdBlockProtocol class]];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    KioskViewController *root = [[KioskViewController alloc] init];
    self.window.rootViewController = root;
    [self.window makeKeyAndVisible];
    return YES;
}

// Ngăn app bị suspend quá nhanh khi vào background - giữ trạng thái video nếu người dùng
// vuốt xem Control Center/Notification Center rồi quay lại (không phải Guided Access nên
// các cử chỉ hệ thống này vẫn hoạt động bình thường, không bị app can thiệp).
- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

@end
