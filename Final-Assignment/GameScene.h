//
//  GameScene.h
//  Final-Assignment
//

//  Copyright (c) 2015 CS2680. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

// Implement Delegate to communicate between GameScene and GameViewController
@protocol GameSceneDelegate <NSObject>

@required
// Method to be called in GameViewController when the game finishes in GameScene
-(void)gameOver:(int)highScore;

@end


@interface GameScene : SKScene <SKPhysicsContactDelegate>
{
    bool touchDown;
    bool ballInMotion;
    bool scratched;
    bool shotTaken;
    bool ballSunk;
    int numTries;
    int currScore;
    int bestScore;
    int triesLeft;
    int ballsLeftOnTable;
    CGFloat ballSize;
    
    CGFloat borderLeftRightWidth;
    CGFloat borderTopBottomHeight;
    
    NSString* tableImage;
    SKSpriteNode *cueBall;
    SKSpriteNode *cue;
    SKLabelNode *currScoreLabel;
    SKLabelNode *bestScoreLabel;
    SKLabelNode *triesLeftLabel;
    
    SKSpriteNode *line1;
    SKSpriteNode *line2;
    
    
}
@property (nonatomic,strong) id<GameSceneDelegate> delegateContainerViewController;

// Method to initialize the GameScene with the Pool Table Color from settings as well as the number of tries
-(id)initWithSettings:(NSString*)color numTries:(int)num;

// Method for setting the Current Best Score (passed in through the GameViewController)
-(void)setHighScore:(int)score;

@end
