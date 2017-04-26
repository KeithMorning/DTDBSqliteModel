//
//  device.m
//  DTDBModel
//
//  Created by KeithXi on 26/04/2017.
//  Copyright © 2017 KeithXi. All rights reserved.
//

#import "device.h"


@implementation device

+ (NSString *)tableName{
    return @"devices";
}

+ (NSString *)primaryKey{
    return @"deviceId";
}

@end
