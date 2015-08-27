//
//  HighScoreTableViewCell.h
//  Final-Assignment
//
//  Created by Matt on 2015-07-28.
//  Copyright (c) 2015 CS2680. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighScoreTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ballImage;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@end
