//
//  NSObject+DTS_Model.m
//  DTDBSqliteModel
//
//  Created by KeithXi on 25/04/2017.
//  Copyright © 2017 KeithXi. All rights reserved.
//

#import "NSObject+DTS_Model.h"
#import <objc/runtime.h>
@implementation DTSSQLTable

@end

@implementation NSObject (DTS_Model)


- (DTSTableStructure *)DTS_GetObjTableTableStructureAndValue{
    
    NSMutableDictionary *propertyAndType = [NSMutableDictionary new];
    
    unsigned int count;
    objc_property_t * properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i <count; i++) {
        objc_property_t property = properties[i];
        NSString *name = @(property_getName(property));
        NSString *attribute = @(property_getAttributes(property));
        NSString *objcType =[NSObject DTS_GetObjcTypeWithattribute:attribute];
        NSString *sqlType = [NSObject DTS_TransformObjctTypeToSqlType:objcType];
        //NSLog(@"name:%@ objcType:%@ sqlType:%@",name,objcType,sqlType);
        if (name && sqlType && objcType) {
            DTSSQLTable *table = [DTSSQLTable new];
            table.objType = objcType;
            table.sqlType = sqlType;
            id varValue = [self valueForKey:name];
            table.value = varValue;
            [propertyAndType setObject:table forKey:name];
        }
    }
    
    free(properties);
    
    return [propertyAndType copy];

}

+ (DTSTableStructure *)DTS_GetObjTableStructure{
    
    NSMutableDictionary *propertyAndType = [NSMutableDictionary new];
    
    unsigned int count;
    objc_property_t * properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i <count; i++) {
        objc_property_t property = properties[i];
        NSString *name = @(property_getName(property));
        NSString *attribute = @(property_getAttributes(property));
        NSString *objcType =[NSObject DTS_GetObjcTypeWithattribute:attribute];
        NSString *sqlType = [NSObject DTS_TransformObjctTypeToSqlType:objcType];
        //NSLog(@"name:%@ objcType:%@ sqlType:%@",name,objcType,sqlType);
        if (name && sqlType && objcType) {
            DTSSQLTable *table = [DTSSQLTable new];
            table.objType = objcType;
            table.sqlType = sqlType;
            [propertyAndType setObject:table forKey:name];
        }
    }
    
    free(properties);
    
    return [propertyAndType copy];
    
}


//convert a objc type to a sqlite type
+ (NSString *)DTS_TransformObjctTypeToSqlType:(NSString *)type{
    if (!type || [type isEqualToString:@""]) {
        return nil;
    }
    
    type = type.lowercaseString;
    
    if ([type isEqualToString:@"Int".lowercaseString]
        ||[type isEqualToString:@"NSInteger".lowercaseString]
        ||[type isEqualToString:@"bool"]
        ||[type isEqualToString:@"long"]) {
        return @"Integer";
    }
    
    if ([type isEqualToString:@"double"]
        ||[type isEqualToString:@"float"]
        ||[type isEqualToString:@"CGFloat".lowercaseString]) {
        return @"Real";
    }
    
    if ([type isEqualToString:@"NSString".lowercaseString]
        ||[type isEqualToString:@"NSDate".lowercaseString]) {
        return @"Text";
    }
    
    if ([type isEqualToString:@"NSArray".lowercaseString]
        ||[type isEqualToString:@"NSDictionary".lowercaseString]
        ||[type isEqualToString:@"NSMutableArray".lowercaseString]
        ||[type isEqualToString:@"NSMutableDictionary".lowercaseString]) {
        return @"BLOB";
    }
    return @"BLOB";
}

//Use the objc_property_t to get the type of the property
+ (NSString *)DTS_GetObjcTypeWithattribute:(NSString *)attribute{
    NSString *propertyType = attribute.uppercaseString;
    NSString* propertyClassName = nil;
    
    if ([propertyType rangeOfString:@",R,"].length > 0 || [propertyType hasSuffix:@",R"]) {
        return nil;
    }
    
    if ([propertyType hasPrefix:@"T@"]) {
        
        NSRange range = [propertyType rangeOfString:@","];
        if (range.location > 4 && range.location <= propertyType.length) {
            range = NSMakeRange(3, range.location - 4);
            propertyClassName = [propertyType substringWithRange:range];
            if ([propertyClassName hasSuffix:@">"]) {
                NSRange categoryRange = [propertyClassName rangeOfString:@"<"];
                if (categoryRange.length > 0) {
                    propertyClassName = [propertyClassName substringToIndex:categoryRange.location];
                }
            }
        }
    }
    else if ([propertyType hasPrefix:@"T{"]) {
        NSRange range = [propertyType rangeOfString:@"="];
        if (range.location > 2 && range.location <= propertyType.length) {
            range = NSMakeRange(2, range.location - 2);
            propertyClassName = [propertyType substringWithRange:range];
        }
    }
    else {
        propertyType = [propertyType lowercaseString];
        if ([propertyType hasPrefix:@"ti"] || [propertyType hasPrefix:@"tb"]) {
            propertyClassName = @"NSInteger";
        }
        else if ([propertyType hasPrefix:@"tf"]) {
            propertyClassName = @"float";
        }
        else if ([propertyType hasPrefix:@"td"]) {
            propertyClassName = @"double";
        }
        else if ([propertyType hasPrefix:@"tl"] || [propertyType hasPrefix:@"tq"]) {
            propertyClassName = @"long";
        }
        else if ([propertyType hasPrefix:@"tc"]) {
            propertyClassName = @"BOOL";
        }
        else if ([propertyType hasPrefix:@"ts"]) {
            propertyClassName = @"int";
        }
    }
    
    
    return propertyClassName;
    
}



@end
