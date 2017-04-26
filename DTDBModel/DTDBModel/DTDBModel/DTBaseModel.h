//
//  DTBaseModel.h
//  DTDBSqliteModel
//
//  Created by KeithXi on 25/04/2017.
//  Copyright © 2017 KeithXi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+DTS_Model.h"

@protocol DTBaseModel <NSObject>

@required
+ (NSString *)tableName;

@optional
+ (NSString *)primaryKey;

+ (NSArray *)uniqueKeys;

+ (NSArray *)ignoreKeys;

//the propertyName in your class and the columName {classname:customColumName}
+ (NSDictionary *)customMapping;

+ (DTSTableStructure *)DTS_GetObjTableStructure;

- (DTSTableStructure *)DTS_GetObjTableTableStructureAndValue;

@end
