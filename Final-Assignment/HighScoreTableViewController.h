//
//  HighScoreTableViewController.h
//  Final-Assignment
//
//  Created by Matt on 2015-07-25.
//  Copyright (c) 2015 CS2680. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameViewController.h"

@interface HighScoreTableViewController : UITableViewController
@property (copy,nonatomic) NSMutableArray *highScores;
@property (copy,nonatomic) NSArray *sortedScores;
@property (weak, nonatomic) UIViewController* delegate;

@end
