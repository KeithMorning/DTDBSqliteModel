//
//  DTDateformer.m
//  DTDBSqliteModel
//
//  Created by KeithXi on 26/04/2017.
//  Copyright © 2017 KeithXi. All rights reserved.
//

#import "DTDateformer.h"

@implementation DTDateformer

+ (NSDate *)dateFromString:(NSString *)datestr{

    NSDateFormatter *formatter = [self dateFormatter];
    return [formatter dateFromString:datestr];
}

+ (NSString *)stringFromDate:(NSDate *)date{
    
    NSDateFormatter *formatter = [self dateFormatter];
    return [formatter stringFromDate:date];

}

+ (NSDateFormatter *)dateFormatter{
    
    static NSDateFormatter *former;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        former = [[NSDateFormatter alloc] init];
        [former setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    });
    
    return former;
}

@end
