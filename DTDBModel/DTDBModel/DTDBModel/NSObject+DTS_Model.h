//
//  NSObject+DTS_Model.h
//  DTDBSqliteModel
//
//  Created by KeithXi on 25/04/2017.
//  Copyright © 2017 KeithXi. All rights reserved.
//

#import <Foundation/Foundation.h>

//{properyName:{SQLiteType,value}}

@interface DTSSQLTable : NSObject

@property (nonatomic,copy) NSString *sqlType;

@property (nonatomic,copy) NSString *objType;

@property (nonatomic,strong) id value;

@end

typedef NSDictionary<NSString *,DTSSQLTable *> DTSTableStructure;

@interface NSObject (DTS_Model)

+ (DTSTableStructure *)DTS_GetObjTableStructure;

- (DTSTableStructure *)DTS_GetObjTableTableStructureAndValue;

@end
