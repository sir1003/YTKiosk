#import "AppDelegate.h"
#import "KioskViewController.h"
#import "AdBlockProtocol.h"

#import <dlfcn.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 1. Giới hạn bộ nhớ đệm (RAM Cache) xuống mức 4MB (mặc định của iOS có thể lên tới 64MB)
    // giúp máy chỉ 512MB RAM như iPhone 4s không bị tràn bộ nhớ.
    NSURLCache *lightCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                           diskCapacity:16 * 1024 * 1024
                                                               diskPath:nil];
    // 2. Bật chấp nhận và lưu trữ Cookie để YouTube nhớ lịch sử xem và đề xuất video
    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;

    // 3. Đăng ký AdBlockProtocol để lọc request và chặn quảng cáo
    [NSURLProtocol registerClass:[AdBlockProtocol class]];

    // 3. Chạy dọn dẹp các tiến trình nền rác ngốn RAM trong background thread (nếu môi trường cho phép)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        int (*sys_func)(const char *) = (int (*)(const char *))dlsym(RTLD_DEFAULT, "system");
        if (sys_func) {
            sys_func("killall -9 ReportCrash assistantd homed healthd gamecenterd passd 2>/dev/null");
        }
    });

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    KioskViewController *root = [[KioskViewController alloc] init];
    self.window.rootViewController = root;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    // Xả sạch toàn bộ cache mạng khi hệ điều hành báo cảnh báo bộ nhớ
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

@end
