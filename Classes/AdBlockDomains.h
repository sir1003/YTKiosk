//
//  AdBlockDomains.h
//  Danh sách rút gọn các domain quảng cáo/theo dõi liên quan tới YouTube/Google.
//  CHỈ chặn domain quảng cáo/analytics, KHÔNG chặn googlevideo.com hay ytimg.com
//  vì đó là domain phục vụ video thật + thumbnail, chặn nhầm sẽ làm video không phát được.
//
#import <Foundation/Foundation.h>

static NSArray *AdBlockDomainList(void) {
    return @[
        @"doubleclick.net",
        @"googlesyndication.com",
        @"googleadservices.com",
        @"google-analytics.com",
        @"googletagmanager.com",
        @"googletagservices.com",
        @"adservice.google.com",
        @"pagead2.googlesyndication.com",
        @"static.doubleclick.net",
        @"stats.g.doubleclick.net",
        @"youtube.com/api/stats/ads",
        @"youtube.com/pagead",
        @"youtube.com/ptracking",
        @"youtube.com/get_midroll",
        @"crashlytics.com",
        @"app-measurement.com"
    ];
}
