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
        @"youtube.com/api/stats/atr",
        @"youtube.com/api/stats/playback",
        @"youtube.com/api/stats/watchtime",
        @"youtube.com/api/stats/qoe",
        @"youtube.com/pagead",
        @"youtube.com/ptracking",
        @"youtube.com/get_midroll",
        @"play.google.com/log",
        @"crashlytics.com",
        @"app-measurement.com",
        @"tpc.googlesyndication.com"
    ];
}
