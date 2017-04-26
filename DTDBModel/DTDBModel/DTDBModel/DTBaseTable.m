//
//  DTBaseTable.m
//  DTDBSqliteModel
//
//  Created by KeithXi on 25/04/2017.
//  Copyright © 2017 KeithXi. All rights reserved.
//

#import "DTBaseTable.h"
#import "NSObject+DTS_Model.h"
#import "DTSSQLBuilder.h"
#import "DTDateformer.h"

@interface DTSQLStatement : NSObject

@property (nonatomic, copy) NSString *sql;
@property (nonatomic, copy) NSArray *values;

- (instancetype)initWithSql:(NSString *)sql values:(NSArray *)values;

@end

@implementation DTSQLStatement

- (instancetype)initWithSql:(NSString *)sql values:(NSArray *)values{
    if (self = [super init]) {
        _sql = sql;
        _values = values;
    }
    return self;
}

@end

@interface DTBaseTable()

@property (nonatomic,strong) FMDatabaseQueue *dbqueue;

@property (atomic,assign) BOOL shouldStop;

@property (nonatomic,strong) DTSTableStructure *dbtableStructure;

@property (nonatomic,strong) DTSTableStructure *classStructure;

@property (nonatomic,strong) Class modelclass;

@end

@implementation DTBaseTable

- (instancetype)initWithDBQueue:(FMDatabaseQueue *)dbqueue withModelClass:(__unsafe_unretained Class)aclass{
    
    if (self = [super init]) {
        _dbqueue =dbqueue;
        _shouldStop = NO;
        _classStructure = [aclass DTS_GetObjTableStructure];
        _dbtableStructure = [self caluteFinalStructureForClass:aclass];
        _modelclass = aclass;
        [self createTableIfNeedForModel:aclass];
    }
    
    return self;
}

#pragma mark - drop table

- (BOOL)dropTableSelf{
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",[self.modelclass tableName]];
    
    __block BOOL success = YES;
    
    [self.dbqueue inDatabase:^(FMDatabase *db) {
       success = [db executeUpdate:sql];
    }];
    
    return success;
}

#pragma mark - create table 

- (void)createTableIfNeed{
    
    [self createTableIfNeedForModel:self.modelclass];
}

#pragma mark - delete

- (BOOL)deleteObjFromDb:(DTSSQLBuilder *)builder{
    
    __block BOOL success = YES;
    [self.dbqueue inDatabase:^(FMDatabase *db) {
        
        NSArray *parameters = [builder parameters];
        NSString *sql = [builder buildSql];
        
        if (parameters.count>0) {
          success = [db executeUpdate:sql withArgumentsInArray:parameters];
        }else{
          success = [db executeUpdate:sql];
        }
        
    }];
    
    return success;

}


#pragma mark - save
- (BOOL)saveToDBWithStatements:(NSArray<DTSQLStatement *> *)statements{

    if (!statements || statements.count ==0) {
        return NO;
    }
    
    __block BOOL success = YES;
    
    [self.dbqueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (DTSQLStatement *statement in statements) {
            if (self.shouldStop) {
                *rollback = YES;
                success = NO;
                break;
                return;
            }
            
          success =  [db executeUpdate:statement.sql withArgumentsInArray:statement.values];
        }
    }];
    
    return success;
}


- (BOOL)saveObjToDb:(id<DTBaseModel>)model{

    if (!model) {
        return NO;
    }
    
    if(![model isKindOfClass:self.modelclass]){
        assert(@"this model is not same as the table init class");
        return NO;
    }
    
    return [self saveObjsToDb:@[model]];
}

- (BOOL)saveObjsToDb:(NSArray<id<DTBaseModel>> *)models{
    NSMutableArray *statements = [NSMutableArray new];
    
    [models enumerateObjectsUsingBlock:^(id<DTBaseModel>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DTSQLStatement *statement = [self convertToinsertStatement:obj];
        
        if(statement){ [statements addObject:statement]; }
        
    }];
    
    return [self saveToDBWithStatements:[statements copy]];
}

#pragma mark - create table
- (void)createTableIfNeedForModel:(Class)aclass{
    
    NSString *tableName = [aclass tableName];
    
    if (!tableName) {
        assert(@"invalid tableName");
    }
    
    NSMutableString *sql = [NSMutableString new];
    
    [sql appendString:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@",tableName]];
    [sql appendString:@"("];
    DTSTableStructure *tablestructure = self.dbtableStructure;
    
    NSString *primaryKey = nil;
    if ([aclass respondsToSelector:@selector(primaryKey)]) {
        primaryKey =  [aclass primaryKey];
    }
    
    NSArray *uniqueKeys = nil;
    
    if ([aclass respondsToSelector:@selector(uniqueKeys)]) {
        uniqueKeys = [aclass uniqueKeys];
    }
    
    [tablestructure enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, DTSSQLTable * _Nonnull obj, BOOL * _Nonnull stop) {
        
        if (primaryKey && [key isEqualToString:primaryKey]) {
            [sql appendFormat:@" %@ %@ primary key,",key,obj.sqlType];
            return;
        }else if(uniqueKeys && [uniqueKeys containsObject:key]){
            [sql appendFormat:@" %@ %@ UNIQUE,",key,obj.sqlType];
        }else{
             [sql appendFormat:@" %@ %@,",key,obj.sqlType];
        }

    }];
    
    [sql deleteCharactersInRange:NSMakeRange(sql.length-1, 1)];
    [sql appendString:@")"];
    
    [self.dbqueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:sql];
    }];
    
    
}

#pragma mark - select

- (NSArray *)getObjsfromDB:(DTSSQLBuilder *)builder{
    
    NSArray *dicts = [self getObjsDictfromDB:builder];
    
    NSMutableArray *result = [NSMutableArray new];
    [dicts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        id objresult = [self.modelclass new];
        [objresult setValuesForKeysWithDictionary:obj];
        [result addObject:objresult];
    }];
    
    return result;
}

- (NSArray *)getObjsDictfromDB:(DTSSQLBuilder *)builder{
    
    __block NSMutableArray *array = [NSMutableArray new];;
    
    [self.dbqueue inDatabase:^(FMDatabase *db) {
        
        NSArray *parameters = [builder parameters];
        NSString *sql = [builder buildSql];
        
        FMResultSet *resultset;
        
        if (parameters.count>0) {
          resultset = [db executeQuery:sql withArgumentsInArray:parameters];
        }else{
           resultset = [db executeQuery:sql];
        }
        
        
        while ([resultset next]) {
            NSDictionary *dict = [self readRecordFromFMResult:resultset
                                                  dbStructure:self.dbtableStructure
                                               classStructure:self.classStructure
                                                        class:self.modelclass];
            [array addObject:dict];
        }
        
    }];
    
    return array;
}

#pragma mark - read from FMResultSet
- (NSDictionary *)readRecordFromFMResult:(FMResultSet *)resultset
                             dbStructure:(DTSTableStructure *)dbstructure
                          classStructure:(DTSTableStructure *)classStructure
                                   class:(Class)modelClass{
    NSDictionary *rowdict = [resultset resultDictionary];
    
    NSMutableDictionary * result = [NSMutableDictionary new];
    
    NSDictionary *customeMaping;
    if ([modelClass respondsToSelector:@selector(customMapping)]) {
        customeMaping = [modelClass customMapping];
    }
    
    NSArray *ignoreKeys = nil;
    if ([modelClass respondsToSelector:@selector(ignoreKeys)]) {
        ignoreKeys = [modelClass ignoreKeys];
    }
    
    [classStructure enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull classkey, DTSSQLTable * _Nonnull obj, BOOL * _Nonnull stop) {
        
        if (ignoreKeys && [ignoreKeys containsObject:classkey]) {
            return;
        }
        
        NSString *dbkey = nil;
        if (customeMaping) {
            dbkey = [customeMaping objectForKey:classkey];
            if (!dbkey) {
                dbkey = classkey;
            }
        }else{
            dbkey = classkey;
        }
        
        id value = [rowdict objectForKey:dbkey];
        if ([value isKindOfClass:[NSData class]]) {
            
            id unarachvierValue  = [NSKeyedUnarchiver unarchiveObjectWithData:value];
            [result setObject:unarachvierValue forKey:classkey];
        }else{
            if ([obj.objType.lowercaseString isEqualToString:@"NSDate".lowercaseString]) {
                
                NSString *stringdate = value;
                NSDate *date = [DTDateformer dateFromString:stringdate];
                [result setObject:date forKey:classkey];
            }else{
                 [result setObject:value forKey:classkey];
            }
           
        
        }
        
    }];
    
    return result;
}

#pragma mark - private method

- (DTSQLStatement *)convertToinsertStatement:(id<DTBaseModel>)model{
    
    NSString *tableName = [[model class] tableName];
    
    if (!tableName) {
        assert(@"this object must have a table to insert");
    }
    
    DTSTableStructure *finalStructureAndValue = [self caluteFinalStructureForModel:model];
    
    NSMutableArray *allvalues = [NSMutableArray new];
    [finalStructureAndValue enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, DTSSQLTable * _Nonnull obj, BOOL * _Nonnull stop) {
        
        id resultValue = obj.value;
        if ([resultValue isKindOfClass:[NSArray class]]
            || [resultValue isKindOfClass:[NSMutableArray class]]
            || [resultValue isKindOfClass:[NSDictionary class]]
            || [resultValue isKindOfClass:[NSMutableDictionary class]]) {
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:resultValue];
            [allvalues addObject:data];
            
        }else if ([resultValue isKindOfClass:[NSDate class]]){

            NSString *datestr = [DTDateformer stringFromDate:resultValue];
            [allvalues addObject:datestr];
        
        }else{
            [allvalues addObject:resultValue];
        }
        
    }];
    
    NSString *sql = [DTSSQLBuilder buildInsertSqlWithTableStructure:finalStructureAndValue tableName:tableName];
    
    DTSQLStatement *statement = [[DTSQLStatement alloc] initWithSql:sql values:allvalues];
    return statement;
    
}

//for class
- (DTSTableStructure *)caluteFinalStructureForClass:(Class)aclass{
    
    DTSTableStructure *table = [aclass DTS_GetObjTableStructure];
    
    NSMutableDictionary *m_dict = [table mutableCopy];
    
    if ([aclass respondsToSelector:@selector(ignoreKeys)]) {
        
        NSArray *ignorkeys = [aclass ignoreKeys];
        
        if (ignorkeys) {
            [m_dict removeObjectsForKeys:ignorkeys];
        }
    }
    
        
    if ([aclass respondsToSelector:@selector(customMapping)]){
        
        NSDictionary *customMapDict = [aclass customMapping];
        if (customMapDict) {
            [customMapDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull oldkey, id  _Nonnull newkey, BOOL * _Nonnull stop) {
                id value = [m_dict objectForKey:oldkey];
                [m_dict removeObjectForKey:newkey];
                [m_dict setObject:value forKey:newkey];
            }];
        }
    }
    
    
    return [m_dict copy];
    
}

- (DTSTableStructure *)caluteFinalStructureForModel:(id<DTBaseModel>)model{
    
    DTSTableStructure *tableAndValue = [model DTS_GetObjTableTableStructureAndValue];
    
    NSMutableDictionary *m_dict = [tableAndValue mutableCopy];
    Class aclass = [model class];
    if (![model isKindOfClass:self.modelclass]) {
        assert(@"must be same with the table class");
    }
    
    if ([aclass respondsToSelector:@selector(ignoreKeys)]) {
        
        NSArray *ignorkeys = [aclass ignoreKeys];
        
        if (ignorkeys) {
            [m_dict removeObjectsForKeys:ignorkeys];
        }
    }
    
    
    if ([aclass respondsToSelector:@selector(customMapping)]){
        
        NSDictionary *customMapDict = [aclass customMapping];
        if (customMapDict) {
            [customMapDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull oldkey, id  _Nonnull newkey, BOOL * _Nonnull stop) {
                id value = [m_dict objectForKey:oldkey];
                [m_dict removeObjectForKey:newkey];
                [m_dict setObject:value forKey:newkey];
            }];
        }
    }
    
    
    return [m_dict copy];
    
}




#pragma mark - stop start save

- (void)stopSave{
    self.shouldStop = YES;
}

- (void)allowSave{
    self.shouldStop = NO;
}

@end
