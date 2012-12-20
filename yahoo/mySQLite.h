//
//  mySQLite.h
//  yahoo
//
//  Created by SGWORLD on 2012/12/21.
//  Copyright (c) 2012年 SGWORLD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface mySQLite : NSObject
{
    sqlite3 *woeidDB;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *woeid;
- (NSInteger)findWoeid:(NSString *)aWoeid;
@end
