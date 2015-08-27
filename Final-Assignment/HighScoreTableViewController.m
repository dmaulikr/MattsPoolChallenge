//
//  HighScoreTableViewController.m
//  Final-Assignment
//
//  Created by Matt on 2015-07-25.
//  Copyright (c) 2015 CS2680. All rights reserved.
//

#import "HighScoreTableViewController.h"
#import "HighScoreTableViewCell.h"

static NSString *cellID = @"HighScoreCell";

@interface HighScoreTableViewController ()

@end

@implementation HighScoreTableViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // register nib for custom table cell
    UINib *nib = [UINib nibWithNibName:@"HighScoreTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellID];
    
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"Score" ascending:NO];
    
    self.sortedScores = [self.highScores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    // 1 row for the first section which will have our top score, all other scores in second section
    if (section == 0) {
        return 1;
    }else{
        return self.highScores.count;
    }
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return @"Top Score:";
    }else{
        return @"Scores";
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HighScoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    //Date formatter for converting NSDate to string
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];

    // Top Score section
    if (indexPath.section ==0) {
        NSDictionary *topScore = [self getBestScore];
        cell.scoreLabel.text = [NSString stringWithFormat:@"%@",topScore[@"Score"]];
        cell.dateLabel.text = [formatter stringFromDate:topScore[@"Date"]];
        cell.ballImage.image = [UIImage imageNamed:@"OneBall"];


    }
    // Rest of the Scores
    else
    {
        cell.scoreLabel.text = self.sortedScores[indexPath.row][@"Score"];
        cell.dateLabel.text = [formatter stringFromDate:self.sortedScores[indexPath.row][@"Date"]];
        cell.ballImage.image = [UIImage imageNamed:@"CueBall"];

    }
    return cell;
}

// Method that returns an NSDictionary object containing the top score and date from the highscore nsmutablearray
-(NSDictionary*)getBestScore{
    NSDictionary *bestScore = @{@"Name":@"N/A", @"Score":@"0",@"Date":@"N/A"};

    for (int i = 0; i<self.highScores.count; i++)
    {
        if ([self.highScores[i][@"Score"] integerValue] >  [bestScore[@"Score"] integerValue]) {
            bestScore = self.highScores[i];
        }
    }
    return bestScore;
}


@end
