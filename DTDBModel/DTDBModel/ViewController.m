//
//  ViewController.m
//  DTDBModel
//
//  Created by KeithXi on 26/04/2017.
//  Copyright © 2017 KeithXi. All rights reserved.
//

#import "ViewController.h"
#import "DTBaseTable.h"
#import "DTSSQLBuilder.h"
#import "device.h"

@interface ViewController ()

@property (nonatomic,strong) DTBaseTable *devicesTable;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *dbpath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/file.db"];
    NSLog(dbpath);
    
    FMDatabaseQueue *queue = [[FMDatabaseQueue alloc] initWithPath:dbpath];
    
    self.devicesTable = [[DTBaseTable alloc] initWithDBQueue:queue withModelClass:[device class]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)write:(id)sender {
    
    device *d1 = [device new];
    d1.deviceId = @"2";
    d1.name = @"gateway";
    d1.num = 1;
    d1.date = [NSDate date];
    
    [self.devicesTable saveObjToDb:d1];
    
}

- (IBAction)read:(id)sender {
    
    DTSSQLBuilder *builder = [DTSSQLBuilder makeBuilder:^(DTSSQLBuilder *builder) {
        
        builder.Select.Table([device tableName]).Where.field(@"num").Less(@3).And.field(@"date").Equal([NSDate date]);
    }];
    
    NSString *sql = [builder buildSql];
    
    NSArray *result = [self.devicesTable getObjsfromDB:builder];
    
    
}
- (IBAction)delete:(id)sender {
    
    DTSSQLBuilder *builder = [DTSSQLBuilder makeBuilder:^(DTSSQLBuilder *builder) {
        builder.Delete.Table([device tableName]).Where.field(@"num").Equal(@1);
    }];
    
    NSString *sql = [builder buildSql];
    
    BOOL success = [self.devicesTable deleteObjFromDb:builder];
}

@end
