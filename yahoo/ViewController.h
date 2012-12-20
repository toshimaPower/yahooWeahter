//
//  ViewController.h
//  yahoo
//
//  Created by SGWORLD on 2012/12/20.
//  Copyright (c) 2012年 SGWORLD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UISearchBarDelegate,UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
