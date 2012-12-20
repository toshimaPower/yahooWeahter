//
//  mySQLite.m
//  yahoo
//
//  Created by SGWORLD on 2012/12/21.
//  Copyright (c) 2012年 SGWORLD. All rights reserved.
//

#import "mySQLite.h"
#import <sqlite3.h>
@implementation mySQLite
@synthesize name = _name;
@synthesize woeid = _woeid;
- (NSInteger)findWoeid:(NSString *)aWoeid
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"db" ofType:@"sqlite"];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:path] == NO) {
        NSLog(@"Not SQLite File");
    }
    
    const char *dbPath = [path UTF8String];
    sqlite3_stmt *statement;
    if(sqlite3_open(dbPath, &woeidDB) == SQLITE_OK)
    {
        NSLog(@"sqlite3_open");
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM WOEID WHERE NAME = \"%@\"",aWoeid];
        const char *query_stmt = [querySQL UTF8String];
        NSLog(@"querySQL %@",querySQL);
        if(sqlite3_prepare_v2(woeidDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSLog(@"sqlite3_prepare");
            if(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSLog(@"sqlite3_step");
                self.name = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)];
                NSLog(@"name %@",self.name);
                self.woeid = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                NSLog(@"woe %@",self.woeid);
            }
            sqlite3_finalize(statement);
        }
            sqlite3_close(woeidDB);
    }
    NSInteger num = [self.woeid integerValue];

    return num;
}

-(void) dealloc
{
    self.name = nil;
    self.woeid = nil;
}

@end
