//
//  MainMenuViewController.m
//  Final-Assignment
//
//  Created by Matt on 2015-07-25.
//  Copyright (c) 2015 CS2680. All rights reserved.
//

#import "MainMenuViewController.h"
#import "HighScoreTableViewController.h"
#import "GameViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
// return string containing path of data.plist
-(NSString*) dataFilePath
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString* documentDirectory = [paths objectAtIndex:0];
    
    return [documentDirectory stringByAppendingString:@"/data.plist"];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSString* filePath = [self dataFilePath];
    
    // set up mutable array for scores
    // that contains the contents of the file
    NSMutableArray* scores = [[NSMutableArray alloc] init];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        scores = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    }
    
    // if the high scores button was clicked make sure we're applying the segue for highScoresSegue
    if ([segue.identifier isEqualToString:@"highScoresSegue"]) {
        HighScoreTableViewController *destination = segue.destinationViewController;
        
        // set scores in the HighScoreTableViewController with the array grabbed from our file
        destination.delegate = self;
        destination.highScores = scores;

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
