//
//  RGMPhotosTableViewController.h
//  PhotoMap
//
//  Created by Ramon Pastor on 5/14/14.
//  Copyright (c) 2014 Rogomi Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RGMPhotosTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *annotations;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
