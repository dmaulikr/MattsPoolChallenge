//
//  GameViewController.m
//  Final-Assignment
//
//  Created by Matt on 2015-07-18.
//  Copyright (c) 2015 CS2680. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
//#import "HighScoreTableViewController.h"
#import "SettingsViewController.h"

@implementation SKScene (Unarchive)

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    //skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Grab Table Color from Settings
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *color = [defaults objectForKey:kTableKey];
    
    // Create and configure the scene.
    GameScene *scene = [[[GameScene alloc] initWithSize:skView.bounds.size] initWithSettings:color numTries:3];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    scene.delegateContainerViewController = self;
    
    // Grab the contents of data.plist and store in an array to be used for High Scores
    NSString* filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        scores = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    }else{
        scores = [[NSMutableArray alloc] init];
    }
    
    // Set the Current Best Score in the GameScene based on contents from file
    [scene setHighScore:[self getBestScore]];
}


// Returns the highest score in public array of scores (grabded from contents of file)
-(int)getBestScore{
    int bestScore = 0;
    for (int i = 0; i<scores.count; i++)
    {
        if ([scores[i][@"Score"] integerValue] > bestScore) {
            bestScore = (int)[scores[i][@"Score"] integerValue];
        }
    }
    return bestScore;
}

// Returns a string with the path of data.plist
-(NSString*) dataFilePath
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString* documentDirectory = [paths objectAtIndex:0];
    
    return [documentDirectory stringByAppendingString:@"/data.plist"];
}

// Delegate method called from GameScene when the player runs out of tries
// Used to pass the players score from the GameScene to the GameViewController
// so we can pass it to the HighScoreTableViewController via a Segue
-(void)gameOver: (int) highScore{
    [scores addObject:@{@"Name":@"Player1", @"Score": [NSString stringWithFormat:@"%d",highScore], @"Date":[NSDate date]}];
    NSString* filePath = [self dataFilePath];
    [scores writeToFile:filePath atomically:true];
    [self performSegueWithIdentifier:@"BackToMainMenu" sender:self];
}

// Segue called to show the HighScoreTableViewController
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    
//    
//    if ([segue.identifier isEqualToString:@"ShowHighScore"]) {
//        HighScoreTableViewController *destination = segue.destinationViewController;
//        
//        destination.delegate = self;
//        destination.highScores = scores;
//        
//    }
//    
//    
//}


- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
