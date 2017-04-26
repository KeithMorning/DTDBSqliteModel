//
//  DTBaseTable.h
//  DTDBSqliteModel
//
//  Created by KeithXi on 25/04/2017.
//  Copyright © 2017 KeithXi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "DTBaseModel.h"
#import "DTSSQLBuilder.h"



@interface DTBaseTable : NSObject

- (instancetype)initWithDBQueue:(FMDatabaseQueue *)dbqueue withModelClass:(Class)aclass;

- (BOOL)saveObjToDb:(id<DTBaseModel>)model;
- (BOOL)saveObjsToDb:(NSArray<id<DTBaseModel>> *)models;

- (NSArray *)getObjsDictfromDB:(DTSSQLBuilder *)builder;

- (NSArray *)getObjsfromDB:(DTSSQLBuilder *)builder;

- (BOOL)deleteObjFromDb:(DTSSQLBuilder *)builder;

#pragma mark - Table
- (BOOL)dropTableSelf;

- (void)createTableIfNeed;


- (void)stopSave;

- (void)allowSave;

@end
