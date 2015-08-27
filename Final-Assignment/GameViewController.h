//
//  GameViewController.h
//  Final-Assignment
//

//  Copyright (c) 2015 CS2680. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@interface GameViewController : UIViewController <GameSceneDelegate>{
    NSMutableArray *scores;
}
-(void)gameOver: (int) highScore;

@end
