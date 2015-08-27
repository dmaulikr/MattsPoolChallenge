//
//  SettingsViewController.m
//  Final-Assignment
//
//  Created by Matt on 2015-07-27.
//  Copyright (c) 2015 CS2680. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController


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
    // Do any additional setup after loading the view.

    [self refreshSegment];
    
    UIApplication * app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name: UIApplicationWillEnterForegroundNotification object:app];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Method that checks settings bundle values and sets segment controls and image
-(void) refreshSegment{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *color = [defaults objectForKey:kTableKey];
    if([color isEqualToString:@"Red"]){
        self.poolTableImage.image = [UIImage imageNamed:@"RedPoolTable"];
        self.colorSegment.selectedSegmentIndex = 0;
    }else if ([color isEqualToString:@"Blue"]){
        self.poolTableImage.image = [UIImage imageNamed:@"BluePoolTable"];
        self.colorSegment.selectedSegmentIndex = 1;
    }else{
        self.poolTableImage.image = [UIImage imageNamed:@"GreenPoolTable"];
        self.colorSegment.selectedSegmentIndex = 2;
    }
}

// Check which segment was clicked and synchronize with settings bundle
- (IBAction)segmentClicked:(UISegmentedControl *)sender {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    if (sender.selectedSegmentIndex == 0) {
        [defaults setObject:@"Red" forKey:kTableKey];
        [self refreshSegment];
    }else if (sender.selectedSegmentIndex ==1){
        [defaults setObject:@"Blue" forKey:kTableKey];
    }else{
        [defaults setObject:@"Green" forKey:kTableKey];
    }
    [self refreshSegment];
    [defaults synchronize];
}
// if app enters foreground
-(void) applicationWillEnterForeground:(NSNotification*) notification{
    NSUserDefaults * Defaults = [NSUserDefaults standardUserDefaults];
    [Defaults synchronize];
    [self refreshSegment];
}
@end
