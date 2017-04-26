//
//  device.h
//  DTDBModel
//
//  Created by KeithXi on 26/04/2017.
//  Copyright © 2017 KeithXi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTBaseModel.h"

@interface device : NSObject<DTBaseModel>

@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *deviceId;

@property (nonatomic,copy) NSDate *date;

@property (nonatomic,assign) NSInteger num;

@end
