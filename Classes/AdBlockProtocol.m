#import "AdBlockProtocol.h"
#import "AdBlockDomains.h"

@implementation AdBlockProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    // Chỉ xét request http/https, bỏ qua data:/file: v.v.
    NSString *scheme = request.URL.scheme.lowercaseString;
    if (![scheme isEqualToString:@"http"] && ![scheme isEqualToString:@"https"]) {
        return NO;
    }

    NSString *urlString = request.URL.absoluteString.lowercaseString;
    static NSArray *blockedDomains = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blockedDomains = AdBlockDomainList();
    });

    for (NSString *domain in blockedDomains) {
        if ([urlString containsString:domain.lowercaseString]) {
            return YES; // Protocol này sẽ nhận xử lý request -> tức là sẽ bị chặn ở startLoading
        }
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return NO;
}

- (void)startLoading {
    // Trả về lỗi ngay lập tức thay vì thực hiện request -> tương đương hành vi
    // "block" của uBlock Origin. Không forward request ra network.
    NSError *error = [NSError errorWithDomain:@"AdBlockProtocol"
                                          code:NSURLErrorCancelled
                                      userInfo:@{NSLocalizedDescriptionKey: @"Blocked by AdBlockProtocol"}];
    [self.client URLProtocol:self didFailWithError:error];
}

- (void)stopLoading {
    // Không có tác vụ async nào đang chạy để hủy.
}

@end
