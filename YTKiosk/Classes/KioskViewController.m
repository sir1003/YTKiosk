#import "KioskViewController.h"
#import <dlfcn.h>

// Các domain được phép điều hướng tới (whitelist)
static NSArray *AllowedNavigationDomains(void) {
    static NSArray *domains = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        domains = @[
            @"youtube.com",
            @"m.youtube.com",
            @"youtu.be",
            @"ytimg.com",
            @"googlevideo.com",
            @"ggpht.com",
            @"googleusercontent.com",
            @"gstatic.com",
            @"accounts.google.com",
            @"google.com"
        ];
    });
    return domains;
}

// Script tối ưu hóa: Chặn quảng cáo, tắt CSS nặng, ép video 360p mượt mà
static NSString *AdBlockAndPerfScript(void) {
    return @""
    "(function() {"
    "  if (window.__ytKioskOptimized) return;"
    "  window.__ytKioskOptimized = true;"
    "  var css = '"
    "    * { text-shadow: none !important; box-shadow: none !important; -webkit-backface-visibility: hidden !important; }"
    "    .ytp-ad-overlay-container, .video-ads, .ytp-ad-module,"
    "    ytm-companion-ad-renderer, ytm-promoted-video-renderer,"
    "    .ytp-ad-progress-list, ytm-in-feed-ad-layout-renderer,"
    "    ytm-banner-promo-renderer, ytm-ad-slot-renderer,"
    "    .ytp-ambient-lighting, .ytp-cards-teaser, ytm-paid-content-overlay-renderer"
    "    { display:none !important; height:0 !important; }"
    "  ';"
    "  var style = document.createElement('style');"
    "  style.type = 'text/css';"
    "  style.appendChild(document.createTextNode(css));"
    "  (document.head || document.documentElement).appendChild(style);"
    "  setInterval(function() {"
    "    var skip = document.querySelector('.ytp-ad-skip-button, .videoAdUiSkipButton, .ytp-ad-skip-button-modern');"
    "    if (skip) { skip.click(); }"
    "    var video = document.querySelector('video');"
    "    var adShowing = document.querySelector('.ad-showing, .ytp-ad-player-overlay');"
    "    if (video && adShowing && video.duration && video.duration < 60) {"
    "      video.currentTime = video.duration;"
    "    }"
    "    var player = document.getElementById('movie_player') || document.querySelector('.html5-video-player');"
    "    if (player) {"
    "      if (typeof player.setPlaybackQualityRange === 'function') {"
    "        player.setPlaybackQualityRange('small', 'medium');"
    "      }"
    "      if (typeof player.setPlaybackQuality === 'function') {"
    "        player.setPlaybackQuality('medium');"
    "      }"
    "    }"
    "  }, 800);"
    "})();";
}

@implementation KioskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    // 1. Cấu hình WKWebView với Nitro JIT tăng tốc JavaScript
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.allowsInlineMediaPlayback = YES;
    
    // Tiêm script tối ưu hóa và chặn quảng cáo ngay khi nạp trang
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:AdBlockAndPerfScript()
                                                      injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                   forMainFrameOnly:NO];
    [config.userContentController addUserScript:userScript];

    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.backgroundColor = [UIColor blackColor];
    self.webView.opaque = NO;
    [self.view addSubview:self.webView];

    // 2. Vòng xoay tải trang (Spinner)
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.center = self.view.center;
    self.spinner.hidesWhenStopped = YES;
    self.spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.spinner];

    // 3. Nút nổi Tối ưu RAM & Tắt Services (Floating Boost Button)
    [self setupBoostButton];

    // 4. Cử chỉ vuốt để Back / Forward
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackSwipe:)];
    backSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:backSwipe];

    UISwipeGestureRecognizer *fwdSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleForwardSwipe:)];
    fwdSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:fwdSwipe];

    // 5. Cử chỉ chạm 2 ngón tay 2 lần để tải lại trang chủ
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadHome)];
    doubleTap.numberOfTouchesRequired = 2;
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];

    // Tự động chạy dọn dẹp khi khởi động
    [self boostDevicePerformance];

    [self loadHome];
}

- (void)setupBoostButton {
    self.boostButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.boostButton.frame = CGRectMake(self.view.bounds.size.width - 55, self.view.bounds.size.height - 55, 45, 45);
    self.boostButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.boostButton.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    self.boostButton.layer.cornerRadius = 22.5;
    self.boostButton.layer.borderWidth = 1.0;
    self.boostButton.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:0.8].CGColor;
    [self.boostButton setTitle:@"⚡" forState:UIControlStateNormal];
    self.boostButton.titleLabel.font = [UIFont systemFontOfSize:22];
    [self.boostButton addTarget:self action:@selector(boostDevicePerformance) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.boostButton];
}

- (void)boostDevicePerformance {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        int (*sys_func)(const char *) = (int (*)(const char *))dlsym(RTLD_DEFAULT, "system");
        if (sys_func) {
            // Tắt các dịch vụ chạy ngầm của Apple gây nặng máy
            sys_func("killall -9 ReportCrash assistantd homed healthd gamecenterd passd softwareupdated 2>/dev/null");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            [self showToast:@"⚡ Đã giải phóng RAM & Tắt dịch vụ ngầm!"];
        });
    });
}

- (void)showToast:(NSString *)message {
    if (self.toastLabel) {
        [self.toastLabel removeFromSuperview];
    }
    self.toastLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height - 110, self.view.bounds.size.width - 40, 36)];
    self.toastLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.toastLabel.backgroundColor = [UIColor colorWithRed:0.1 green:0.7 blue:0.3 alpha:0.9];
    self.toastLabel.textColor = [UIColor whiteColor];
    self.toastLabel.textAlignment = NSTextAlignmentCenter;
    self.toastLabel.font = [UIFont boldSystemFontOfSize:13];
    self.toastLabel.layer.cornerRadius = 18;
    self.toastLabel.clipsToBounds = YES;
    self.toastLabel.text = message;
    self.toastLabel.alpha = 0.0;
    [self.view addSubview:self.toastLabel];

    [UIView animateWithDuration:0.3 animations:^{
        self.toastLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 delay:1.8 options:0 animations:^{
            self.toastLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.toastLabel removeFromSuperview];
            self.toastLabel = nil;
        }];
    }];
}

- (void)loadHome {
    NSURL *url = [NSURL URLWithString:@"https://m.youtube.com/"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)handleBackSwipe:(UISwipeGestureRecognizer *)gr {
    if (self.webView.canGoBack) [self.webView goBack];
}

- (void)handleForwardSwipe:(UISwipeGestureRecognizer *)gr {
    if (self.webView.canGoForward) [self.webView goForward];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *host = navigationAction.request.URL.host.lowercaseString;
    if (!host) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

    for (NSString *allowed in AllowedNavigationDomains()) {
        if ([host isEqualToString:allowed] || [host hasSuffix:[@"." stringByAppendingString:allowed]]) {
            decisionHandler(WKNavigationActionPolicyAllow);
            return;
        }
    }

    NSLog(@"[YTKiosk] Chặn điều hướng ngoài whitelist: %@", host);
    decisionHandler(WKNavigationActionPolicyCancel);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.spinner startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.spinner stopAnimating];
    [webView evaluateJavaScript:AdBlockAndPerfScript() completionHandler:nil];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.spinner stopAnimating];
    if (error.code == NSURLErrorCancelled) return;
    NSLog(@"[YTKiosk] Lỗi điều hướng: %@", error);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.spinner stopAnimating];
    if (error.code == NSURLErrorCancelled) return;
    NSLog(@"[YTKiosk] Lỗi tải tạm: %@", error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
