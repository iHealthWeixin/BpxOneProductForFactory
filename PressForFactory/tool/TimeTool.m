//
//  TimeTool.m
//  PressForFactory
//
//  Created by liutengjiao on 2022/9/14.
//

#import "TimeTool.h"


@implementation TimeTool
+ (NSString *)getCurrentTimeNet {
    NSString *urlString = @"https://www.baidu.com";
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: urlString]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval: 2];
    [request setHTTPShouldHandleCookies:FALSE];
    [request setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    //NSLog(@">>>>> response :%@",response);
    NSString *date = [[response allHeaderFields] objectForKey:@"Date"];
    
    //NSLog(@">>>>> date :%@",date);
    date = [date substringFromIndex:5];
    date = [date substringToIndex:[date length]-4];
//    NSLog(@">>>>> date :%@",date);
    NSDateFormatter *dMatter = [[NSDateFormatter alloc] init];
    dMatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dMatter setDateFormat:@"dd MMM yyyy HH:mm:ss"];
    NSDate *netDate = [[dMatter dateFromString:date] dateByAddingTimeInterval:60*60*8];
    
    NSDateFormatter *formatDay = [[NSDateFormatter alloc] init];
    formatDay.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    formatDay.timeZone = [NSTimeZone timeZoneWithName:@"en_US"];
    NSString *dayStr = [formatDay stringFromDate:netDate];
    
    
    return dayStr;
}



+(NSString*)getCurrentTimes {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *dateNow = [NSDate date];
    NSString *currentTime = [formatter stringFromDate:dateNow];
    return currentTime;
}


////获取事件戳
+ (NSString *)getCurrentTimeInterval {
    NSDate *datenow = [NSDate date];
//    NSLog(@"时间戳 == %@",[NSString stringWithFormat:@"%ld",(long)[datenow timeIntervalSince1970]]);
    return   [NSString stringWithFormat:@"%ld",(long)[datenow timeIntervalSince1970]]  ;
}

@end
