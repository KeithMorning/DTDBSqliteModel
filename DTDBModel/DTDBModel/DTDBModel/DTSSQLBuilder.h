//
//  DTSSQLBuilder.h
//  DTDBSqliteModel
//
//  Created by KeithXi on 25/04/2017.
//  Copyright © 2017 KeithXi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+DTS_Model.h"


@interface DTSSQLBuilder : NSObject


+ (NSString *)buildInsertSqlWithTableStructure:(DTSTableStructure *)tableStructure tableName:(NSString *)tableName;


- (NSString *)buildSql;

- (NSArray *)parameters;


+ (instancetype)makeBuilder:(void (^)(DTSSQLBuilder * builder))block;

- (DTSSQLBuilder *(^)(NSString *tableName))Table;

- (DTSSQLBuilder *(^)(id value))Equal;

- (DTSSQLBuilder *(^)(id value))Less;

- (DTSSQLBuilder *(^)(id value))LessOrEqual;

- (DTSSQLBuilder *(^)(id value))Greater;

- (DTSSQLBuilder *(^)(id value))GreaterOrEqual;

- (DTSSQLBuilder *(^)(id value))Like;

- (DTSSQLBuilder *(^)(NSString *field))field;

- (DTSSQLBuilder *(^)(id value))Prameter;

//- (DTSSQLBuilder *(^)(NSString *field,id value))UpdateKey;

- (DTSSQLBuilder *(^)(NSString *field))OrderBy;

- (DTSSQLBuilder *)And;

- (DTSSQLBuilder *)Or;

- (DTSSQLBuilder *)Where;

- (DTSSQLBuilder *)Select;

- (DTSSQLBuilder *)Delete;

- (DTSSQLBuilder *)Update;

//- (DTSSQLBuilder*(^)(NSString *field,DTSQLCondition condition,id value))Condition;

@end
