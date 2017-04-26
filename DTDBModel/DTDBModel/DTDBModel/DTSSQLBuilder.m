//
//  DTSSQLBuilder.m
//  DTDBSqliteModel
//
//  Created by KeithXi on 25/04/2017.
//  Copyright © 2017 KeithXi. All rights reserved.
//


#define DTSelect @"select"
#define DTUpdate @"update"
#define DTDelete @"delete"
#define DTGroupBy @"groupby"
#define DTWhere @"where"
#define DTLike @"like"
#define DTIn @"in"



#import "DTSSQLBuilder.h"

typedef NS_ENUM(NSUInteger, DTSQLOperation) {
    DTSQLSelect,
    DTSQLUpdate,
    DTSQLDelete,
};

@interface DTSSQLBuilder()

@property (nonatomic,strong) NSMutableString *sql;

@property (nonatomic,strong) NSMutableArray *values;

@property (nonatomic,assign) DTSQLOperation operation;

@property (nonatomic,copy) NSString *tableName;

@end

@implementation DTSSQLBuilder

+ (NSString *)buildInsertSqlWithTableStructure:(DTSTableStructure *)tableStructure tableName:(NSString *)tableName{

    
    NSMutableString *sqlColumns = [NSMutableString new];
    NSMutableString *sqlHolderPlaceValue = [NSMutableString new];


    [tableStructure enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, DTSSQLTable * _Nonnull obj, BOOL * _Nonnull stop) {
        
        [sqlColumns appendFormat:@"%@,",key];
        [sqlHolderPlaceValue appendString:@"?,"];
    }];
    
    NSRange range = NSMakeRange(sqlColumns.length-1, 1);
    [sqlColumns deleteCharactersInRange:range];
    
    NSRange holderPlaceRange = NSMakeRange(sqlHolderPlaceValue.length-1, 1);
    [sqlHolderPlaceValue deleteCharactersInRange:holderPlaceRange];
    
    NSString *sql = [NSString stringWithFormat:@"insert or replace into %@ (%@) values (%@)",tableName,sqlColumns,sqlHolderPlaceValue];
    return sql;
}

- (instancetype)init{
    
    if (self = [super init]) {
        _sql = [NSMutableString new];
        _values = [NSMutableArray new];
    }
    return self;
}

+ (instancetype)makeBuilder:(void (^)(DTSSQLBuilder * builder))block{
    DTSSQLBuilder *builder = [[DTSSQLBuilder alloc] init];
    block(builder);
    return builder;
}

- (DTSSQLBuilder *(^)(DTSQLOperation operation))Operate{
    
    return ^DTSSQLBuilder*(DTSQLOperation operation){
        
        self.operation = operation;
        
        switch (operation) {
            case DTSQLSelect:
                [self.sql appendFormat:@"%@ * from ",DTSelect];
                break;
            case DTSQLDelete:
                [self.sql appendFormat:@"%@ from ",DTDelete];
                break;
            case DTSQLUpdate:
                [self.sql appendFormat:@"%@ ",DTUpdate];
                break;
            default:
                break;
        }
        return self;
    };
}

- (DTSSQLBuilder *(^)(NSString *tableName))Table{
    
    return ^DTSSQLBuilder*(NSString *tableName){
        switch (self.operation) {
            case DTSQLSelect:
                [self.sql appendFormat:@" %@ ",tableName];
                break;
            case DTSQLDelete:
                [self.sql appendFormat:@" %@ ",tableName];
                break;
            case DTSQLUpdate:
                [self.sql appendFormat:@" %@ set ",tableName];
                break;
            default:
                break;
        }
        return self;
    };
}

- (DTSSQLBuilder *(^)(NSString *field))field{
    return ^DTSSQLBuilder*(NSString *field){
        
        [self.sql appendFormat:@" %@ ",field];
        return self;
    };
}

- (DTSSQLBuilder *(^)(id value))Prameter{
    
    return ^DTSSQLBuilder*(id value){
    
        [self.values addObject:value];
        [self.sql appendFormat:@" ? "];
        return self;
    };
    
}

- (DTSSQLBuilder *(^)(NSString *key))OrderBy{
    return ^DTSSQLBuilder*(NSString *key){
        [self.sql appendFormat:@" orderBy %@",key];
        return self;
    };

}

- (DTSSQLBuilder* )And{
    [self.sql appendString:@" and "];
    return self;
}

- (DTSSQLBuilder*)Or{

    [self.sql appendString:@" or "];
    return self;
}

- (DTSSQLBuilder* )Where{
    

    [self.sql appendString:@" where "];
    return self;
}

- (DTSSQLBuilder *)Select{
    self.operation = DTSQLSelect;
     [self.sql appendFormat:@"%@ * from ",DTSelect];
    return self;
}

- (DTSSQLBuilder *)Delete{
    self.operation = DTSQLDelete;
    [self.sql appendFormat:@"%@ from ",DTDelete];
    return self;
}

- (DTSSQLBuilder *)Update{
    self.operation = DTSQLUpdate;
    [self.sql appendFormat:@"%@ ",DTUpdate];
    return self;
}


- (DTSSQLBuilder *(^)(id value))Equal{
    
    return ^DTSSQLBuilder*(id value){
    
        [self.sql appendFormat:@" = ? "];
        [self.values addObject:value];
        return self;
    };
    
}

- (DTSSQLBuilder *(^)(id value))Less{

    return ^DTSSQLBuilder*(id value){
        
        [self.sql appendFormat:@" < ?"];
        [self.values addObject:value];
        return self;
    };
}

- (DTSSQLBuilder *(^)(id value))LessOrEqual{
    
    return ^DTSSQLBuilder*(id value){
        
        [self.sql appendFormat:@" <= ?"];
        [self.values addObject:value];
        return self;
    };

}

- (DTSSQLBuilder *(^)(id value))Greater{
    
    return ^DTSSQLBuilder*(id value){
        
        [self.sql appendFormat:@" > ?"];
        [self.values addObject:value];
        return self;
    };

}

- (DTSSQLBuilder *(^)(id value))GreaterOrEqual{
    
    return ^DTSSQLBuilder*(id value){
        
        [self.sql appendFormat:@" >= ?"];
        [self.values addObject:value];
        return self;
    };

}

- (DTSSQLBuilder *(^)(id value))Like{

    return ^DTSSQLBuilder*(id value){
        
        [self.sql appendFormat:@" like ?"];
        [self.values addObject:value];
        return self;
    };
}


- (NSArray *)parameters{
    return [self.values copy];
}

- (NSString *)buildSql{
    return [self.sql copy];
}

@end
