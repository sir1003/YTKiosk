#import "KioskViewController.h"

// Các domain được phép điều hướng tới (whitelist) - mọi domain khác sẽ bị chặn
// để máy chỉ hoạt động như "thiết bị xem YouTube chuyên dụng"
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
            @"ggpht.com",            // avatar/channel art
            @"googleusercontent.com",// avatar/channel art
            @"gstatic.com",          // static assets (font, icon)
            @"accounts.google.com",  // đăng nhập tài khoản (tùy chọn, có thể bỏ nếu không cần login)
            @"google.com"            // reCAPTCHA / xác thực khi login
        ];
    });
    return domains;
}

// JS tiêm vào mỗi lần trang tải xong: ẩn overlay quảng cáo bằng CSS + tự động bấm nút Skip Ad.
// Đây là kỹ thuật "cosmetic filtering" giống cách uBlock Origin xử lý quảng cáo trong-luồng,
// vì bản thân segment quảng cáo đi qua chung domain googlevideo.com với video thật nên
// KHÔNG thể chặn ở tầng network mà phải xử lý ở tầng DOM.
static NSString *AdBlockInjectionScript(void) {
    return @""
    "(function() {"
    "  if (window.__ytKioskAdBlockInstalled) return;"
    "  window.__ytKioskAdBlockInstalled = true;"
    "  var css = '"
    "    .ytp-ad-overlay-container, .video-ads, .ytp-ad-module,"
    "    ytm-companion-ad-renderer, ytm-promoted-video-renderer,"
    "    .ytp-ad-progress-list, ytm-in-feed-ad-layout-renderer,"
    "    ytm-banner-promo-renderer, ytm-ad-slot-renderer"
    "    { display:none !important; height:0 !important; }"
    "  ';"
    "  var style = document.createElement('style');"
    "  style.type = 'text/css';"
    "  style.appendChild(document.createTextNode(css));"
    "  document.head.appendChild(style);"
    "  setInterval(function() {"
    "    var skip = document.querySelector('.ytp-ad-skip-button, .videoAdUiSkipButton, .ytp-ad-skip-button-modern');"
    "    if (skip) { skip.click(); }"
    "    var video = document.querySelector('video');"
    "    var adShowing = document.querySelector('.ad-showing, .ytp-ad-player-overlay');"
    "    if (video && adShowing && video.duration && video.duration < 60) {"
    "      video.currentTime = video.duration;" // tua nhanh qua quảng cáo không có nút skip
    "    }"
    "  }, 500);"
    "})();";
}

@interface KioskViewController ()
@end

@implementation KioskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    self.webView.suppressesIncrementalRendering = NO;
    self.webView.backgroundColor = [UIColor blackColor];
    self.webView.opaque = NO;
    [self.view addSubview:self.webView];

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.center = self.view.center;
    self.spinner.hidesWhenStopped = YES;
    self.spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.spinner];

    // Vuốt cạnh trái/phải để back/forward trong lịch sử điều hướng nội bộ của YouTube
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackSwipe:)];
    backSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:backSwipe];

    UISwipeGestureRecognizer *fwdSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleForwardSwipe:)];
    fwdSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:fwdSwipe];

    [self loadHome];
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

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *host = request.URL.host.lowercaseString;
    if (!host) return YES; // about:blank, data: nội bộ v.v.

    for (NSString *allowed in AllowedNavigationDomains()) {
        if ([host isEqualToString:allowed] || [host hasSuffix:[@"." stringByAppendingString:allowed]]) {
            return YES;
        }
    }

    NSLog(@"[YTKiosk] Chặn điều hướng ra ngoài whitelist: %@", host);
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.spinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.spinner stopAnimating];
    [webView stringByEvaluatingJavaScriptFromString:AdBlockInjectionScript()];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.spinner stopAnimating];
    // NSURLErrorCancelled (-999) xảy ra bình thường khi điều hướng bị hủy do whitelist,
    // hoặc khi request bị AdBlockProtocol chặn -> không cần xử lý gì thêm.
    if (error.code == NSURLErrorCancelled) return;
    NSLog(@"[YTKiosk] Lỗi tải trang: %@", error);
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
