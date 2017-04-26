//
//  NSObject+HS_Coding.m
//  DTDBSqliteModel
//
//  Created by KeithXi on 25/04/2017.
//  Copyright © 2017 KeithXi. All rights reserved.
//

#import "NSObject+HS_Coding.h"
#import <objc/runtime.h>

@implementation NSObject (HS_Coding)

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    Class cls = [self class];
    while (cls != [NSObject class]) {
        /*判断是自身类还是父类*/
        BOOL bIsSelfClass = (cls == [self class]);
        unsigned int iVarCount = 0;
        unsigned int propVarCount = 0;
        unsigned int sharedVarCount = 0;
        Ivar *ivarList = bIsSelfClass ? class_copyIvarList([cls class], &iVarCount) : NULL;/*变量列表，含属性以及私有变量*/
        objc_property_t *propList = bIsSelfClass ? NULL : class_copyPropertyList(cls, &propVarCount);/*属性列表*/
        sharedVarCount = bIsSelfClass ? iVarCount : propVarCount;
        
        for (int i = 0; i < sharedVarCount; i++) {
            const char *varName = bIsSelfClass ? ivar_getName(*(ivarList + i)) : property_getName(*(propList + i));
            NSString *key = [NSString stringWithUTF8String:varName];
            /*valueForKey只能获取本类所有变量以及所有层级父类的属性，不包含任何父类的私有变量(会崩溃)*/
            id varValue = [self valueForKey:key];
            if (varValue) {
                [aCoder encodeObject:varValue forKey:key];
            }
        }
        free(ivarList);
        free(propList);
        cls = class_getSuperclass(cls);
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self)
    {
        Class cls = [self class];
        while (cls != [NSObject class]) {
            /*判断是自身类还是父类*/
            BOOL bIsSelfClass = (cls == [self class]);
            unsigned int iVarCount = 0;
            unsigned int propVarCount = 0;
            unsigned int sharedVarCount = 0;
            Ivar *ivarList = bIsSelfClass ? class_copyIvarList([cls class], &iVarCount) : NULL;/*变量列表，含属性以及私有变量*/
            objc_property_t *propList = bIsSelfClass ? NULL : class_copyPropertyList(cls, &propVarCount);/*属性列表*/
            sharedVarCount = bIsSelfClass ? iVarCount : propVarCount;
            
            for (int i = 0; i < sharedVarCount; i++) {
                const char *varName = bIsSelfClass ? ivar_getName(*(ivarList + i)) : property_getName(*(propList + i));
                NSString *key = [NSString stringWithUTF8String:varName];
                id varValue = [aDecoder decodeObjectForKey:key];
                if (varValue) {
                    [self setValue:varValue forKey:key];
                }
            }
            free(ivarList);
            free(propList);
            cls = class_getSuperclass(cls);
        }
        return self;
    }
    return self;
}

@end
