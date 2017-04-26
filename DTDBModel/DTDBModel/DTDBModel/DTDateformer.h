//
//  DTDateformer.h
//  DTDBSqliteModel
//
//  Created by KeithXi on 26/04/2017.
//  Copyright © 2017 KeithXi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTDateformer : NSObject

+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSDate *)dateFromString:(NSString *)datestr;

@end
