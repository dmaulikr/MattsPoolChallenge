//
//  SettingsViewController.h
//  Final-Assignment
//
//  Created by Matt on 2015-07-27.
//  Copyright (c) 2015 CS2680. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kTableKey @"tableColor"

@interface SettingsViewController : UIViewController
- (IBAction)segmentClicked:(UISegmentedControl *)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *colorSegment;
@property (weak, nonatomic) IBOutlet UIImageView *poolTableImage;

@end
