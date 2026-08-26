#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface KioskViewController : UIViewController <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIButton *boostButton;
@property (nonatomic, strong) UILabel *toastLabel;

- (void)boostDevicePerformance;

@end
