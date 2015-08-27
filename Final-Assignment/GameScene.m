//
//  GameScene.m
//  Final-Assignment
//
//  Created by Matt on 2015-07-18.
//  Copyright (c) 2015 CS2680. All rights reserved.
//

#import "GameScene.h"

// Category Bit Masks used in Collision Detection
static const uint32_t cueBallCategory  = 0x1 << 0;  // 00000000000000000000000000000001 = 1
static const uint32_t stripeCategory = 0x1 << 1;  // 00000000000000000000000000000010 = 2
static const uint32_t solidCategory = 0x1 << 2; // 00000000000000000000000000000100 = 4
static const uint32_t eightCategory = 0x1 << 3; // 00000000000000000000000000001000 = 8
static const uint32_t pocketCategory = 0x1 << 4; // 0000000000000000000000000010000 = 16

@implementation GameScene

// Method to initialize the GameScene with the Pool Table Color from settings as well as the number of tries
-(id)initWithSettings:(NSString*)color numTries:(int)num{
    // set the pool table image based on the selected value in settings
    if([color isEqualToString:@"Red"]){
        tableImage = @"RedPoolTable";
        
    }else if ([color isEqualToString:@"Blue"]){
        tableImage = @"BluePoolTable";
        
    }else{
        tableImage = @"GreenPoolTable";
        
    }
    numTries = num;
    return self;
}

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    ballSize = self.frame.size.width*0.065;

    
    
    // Set up Sprite of the Pool Table (using image based on color passed in initWithSettings)
    SKSpriteNode *poolTableBG = [SKSpriteNode spriteNodeWithImageNamed:tableImage];
    poolTableBG.name = @"PoolTable";
    poolTableBG.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    poolTableBG.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    
    // Make sure Pool Table appears behind other images
    poolTableBG.zPosition = -1.0;
    [self addChild:poolTableBG];
    
    // Add a physics body to the pool table based on the dimensions of the image however
    // subtract some pixels and position it in a way that the border mimics that of the
    // border of the Pool Table in the image
    borderLeftRightWidth = self.frame.size.width*0.10617760617;
    borderTopBottomHeight = self.frame.size.height*0.05641025641;
    

    SKPhysicsBody *poolTableBorder = [SKPhysicsBody bodyWithEdgeLoopFromRect: CGRectMake(borderLeftRightWidth, borderTopBottomHeight, poolTableBG.size.width-(borderLeftRightWidth*2.0), poolTableBG.size.height-(borderTopBottomHeight*2.0))];
    self.physicsBody = poolTableBorder;
    self.physicsBody.friction = 0.5f;
    
    




    // Create and position a CueBall image
    
    cueBall = [SKSpriteNode spriteNodeWithImageNamed:@"CueBall"];
    cueBall.size = CGSizeMake(ballSize, ballSize);
    
    // Add Physics to the Cue Ball using the phsyics returns in the applyBallPhsyics method
    // this method is used on all balls on the table since they all use the same physics
    cueBall.physicsBody = [self applyBallPhysics:cueBallCategory];
    cueBall.name = @"cueBall";
    cueBall.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height*0.27);
    [self addChild:cueBall];
    
    // Initialize the Scene with the number of tries left based on numTries which was set in initWithSettings
    triesLeft = numTries;
    
    // set current score to 0, all flags to false
    currScore = 0;
    scratched = false;
    ballSunk = false;
    shotTaken = false;
    touchDown = false;

    // Call the rackBalls method
    // This method will create the SKSpriteNodes for the 15 pool balls as well as position them on the table
    [self rackBalls];
    
    NSArray *pocketNames = @[@"TopLeft", @"TopRight", @"MidLeft", @"MidRight", @"BottomLeft", @"BottomRight"];
    
    for (int i=0; i<6; i++) {
    
        // Set up SKSprite Nodes for each pocket, these pockets don't have images they are just black sprite nodes
        // we position them behind the pool table image since we don't want them visible, they are only to be used
        // for collision detection on the pool table
//        SKSpriteNode *pocket = [SKSpriteNode spriteNodeWithImageNamed:@"OneBall"];
//        pocket.size = CGSizeMake(borderLeftRightWidth*2.0, borderLeftRightWidth*2.0);

        SKSpriteNode *pocket = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(borderLeftRightWidth*2.0, borderLeftRightWidth*2.0)];
        pocket.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:borderLeftRightWidth];
        // we don't want these sprites to move or have physics, they are only here to detect if a ball is in the pocket
        pocket.physicsBody.dynamic = false;
        pocket.physicsBody.categoryBitMask = pocketCategory;
        pocket.name = pocketNames[i];
        pocket.zPosition = -2.0;
        [self addChild:pocket];
    }
    
    // position all 6 of the pockets individually based on the Pool Table image
    [self childNodeWithName:@"TopLeft"].position = CGPointMake(borderLeftRightWidth/2.0, poolTableBG.size.height - (borderTopBottomHeight/2.0));
    [self childNodeWithName:@"TopRight"].position = CGPointMake(poolTableBG.size.width-(borderLeftRightWidth/2.0), poolTableBG.size.height - (borderTopBottomHeight/2.0));
    
    [self childNodeWithName:@"MidLeft"].position = CGPointMake(borderLeftRightWidth/2.0-10.0, poolTableBG.size.height/2.0);
    [self childNodeWithName:@"MidRight"].position = CGPointMake(poolTableBG.size.width-(borderLeftRightWidth/2.0)+10.0, poolTableBG.size.height/2.0);
    
    [self childNodeWithName:@"BottomLeft"].position = CGPointMake(borderLeftRightWidth/2.0, borderTopBottomHeight/2.0);
    [self childNodeWithName:@"BottomRight"].position  = CGPointMake(poolTableBG.size.width-(borderLeftRightWidth/2.0), borderTopBottomHeight/2.0);
    
    // Add gravity and set contactTestBitMasks for collission detection
    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
    cueBall.physicsBody.contactTestBitMask = pocketCategory | solidCategory | stripeCategory | eightCategory;
    self.physicsWorld.contactDelegate = self;

    
    // Set up label nodes at the bottom of the gamescene that will display scores and number of tries left
    currScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    currScoreLabel.text = [NSString stringWithFormat:@"Your Score: %d",currScore];
    currScoreLabel.fontSize = 10.0;
    currScoreLabel.position = CGPointMake(CGRectGetMinX(self.frame)+80.0,CGRectGetMinY(self.frame)+10.0);
    currScoreLabel.name = @"CurrScoreLabel";
    [self addChild:currScoreLabel];
    
    bestScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    bestScoreLabel.text = [NSString stringWithFormat:@"Best: %d",bestScore];
    bestScoreLabel.fontSize = 10.0;
    bestScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMinY(self.frame)+10.0);
    bestScoreLabel.name = @"BestScoreLabel";
    [self addChild:bestScoreLabel];
    
    triesLeftLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    triesLeftLabel.text = [NSString stringWithFormat:@"Tries Left: %d",triesLeft];
    triesLeftLabel.fontSize = 10.0;
    triesLeftLabel.position = CGPointMake(CGRectGetMaxX(self.frame)-80.0,CGRectGetMinY(self.frame)+10.0);
    triesLeftLabel.name = @"TriesLeftLabel";
    [self addChild:triesLeftLabel];
    
    
    
    
    
    
    

    
}

// Method called to set up the 15 pool ball sprite nodes and position them in our gamescene
-(void) rackBalls{
    
    // Set up the balls in an Array of dictionaries that we will use later

    ballsLeftOnTable = 15;
    NSArray *rackOrder = @[
                           @{@"Name" : @"OneBall", @"Type" : @"Solid"},
                           @{@"Name" : @"NineBall", @"Type" : @"Stripe"},
                           @{@"Name" : @"FourteenBall", @"Type" : @"Stripe"},
                           @{@"Name" : @"TwoBall", @"Type" : @"Solid"},
                           @{@"Name" : @"EightBall", @"Type" : @"Eight"},
                           @{@"Name" : @"SixBall", @"Type" : @"Solid"},
                           @{@"Name" : @"TenBall", @"Type" : @"Stripe"},
                           @{@"Name" : @"SevenBall", @"Type" : @"Solid"},
                           @{@"Name" : @"FifteenBall", @"Type" : @"Stripe"},
                           @{@"Name" : @"ThirteenBall", @"Type" : @"Stripe"},
                           @{@"Name" : @"ThreeBall", @"Type" : @"Solid"},
                           @{@"Name" : @"ElevenBall", @"Type" : @"Stripe"},
                           @{@"Name" : @"FourBall", @"Type" : @"Solid"},
                           @{@"Name" : @"TwelveBall", @"Type" : @"Stripe"},
                           @{@"Name" : @"FiveBall", @"Type" : @"Solid"}
                        ];
    
    // the Starting position where our first ball will be placed, all other balls placed relative to this
    CGPoint position = CGPointMake(self.frame.size.width/2.0, self.frame.size.height*0.63);

    // Nested loop that positions all 15 balls relative to each other
    // We want it positioned in a pyramid
    int ballNumber = 0;
    for (int i=0; i<5; i++) {
        for (int j=0; j<i+1; j++) {
            SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:rackOrder[ballNumber][@"Name"]];
            ball.size = CGSizeMake(ballSize, ballSize);
            
            // position the current ball using i and j form the nested loop, this positions balls relative to each other
            // in a pyramid
            ball.position = CGPointMake((position.x + (j*ballSize))-(i*(ballSize/2.0)),position.y+(i*ballSize));
            
            // Set the Type of ball
            // Note we don't actually care what the type of the ball is since in the high score game
            // we don't actually keep track of what type of ball was sunk
            // this was only implemented in case other modes (like 2-player mode) get added later
            if ([rackOrder[ballNumber][@"Type"] isEqualToString:@"Solid"]) {
                ball.physicsBody = [self applyBallPhysics:solidCategory];
            }else if ([rackOrder[ballNumber][@"Type"] isEqualToString:@"Stripe"]){
                ball.physicsBody = [self applyBallPhysics:stripeCategory];
            }else if ([rackOrder[ballNumber][@"Type"] isEqualToString:@"Eight"]){
                ball.physicsBody = [self applyBallPhysics:eightCategory];
            }
            
            ball.name = rackOrder[ballNumber][@"Name"];
            ball.physicsBody.contactTestBitMask = pocketCategory;
            [self addChild:ball];
            ballNumber++;
        }
    }
}

// Method to clear the balls from the table and reset all flags and effectively reset the game
-(void) resetTable{
    // reset flags
    triesLeft = numTries;
    currScore = 0;
    scratched = false;
    ballSunk = false;
    shotTaken = false;
    touchDown = false;
    
    // remove sprites that contain the string "Ball"
    NSArray *ballsLeft = [self children];
    for(SKSpriteNode *x in ballsLeft){
        if ([x.name rangeOfString:@"Ball"].location != NSNotFound) {
            [x removeFromParent];
        }
    }
    // re-add and position cue ball since it will have been removed
    cueBall.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height*0.27);
    [self addChild:cueBall];
    
    // call the rackballs method again after all the sprites are removed
    [self rackBalls];
    currScoreLabel.text = [NSString stringWithFormat:@"Your Score: %d",currScore];
}

// Method for gameviewcontroller to pass the best score (which it grabs from data.plist)
-(void)setHighScore:(int)score{
    bestScore = score;
    bestScoreLabel.text = [NSString stringWithFormat:@"Best: %d",bestScore];
}

// Method for returning an SKPhysics object that can be applied to all ball sprites
-(SKPhysicsBody*)applyBallPhysics: (uint32_t) category{

    SKPhysicsBody* physics = [SKPhysicsBody bodyWithCircleOfRadius:cueBall.size.width/2];
    
    physics.friction = 0.8f;
    physics.restitution = 0.8f;
    physics.linearDamping = 0.9f;
    physics.angularDamping = 0.9f;
    physics.allowsRotation = YES;
    physics.affectedByGravity = NO;
    physics.categoryBitMask = category;
    
    return physics;
    
}

// Method for positioning the Pool Cue when touch events are triggered, called in touch events
-(void)positionCue:(CGPoint)touchLocation {
    
    // position and rotate the pool cue based on where the touch event is from the cue ball
    CGFloat xdiff = touchLocation.x - cueBall.position.x;
    CGFloat ydiff = touchLocation.y - cueBall.position.y;
    CGFloat cueRotation = atan2f(xdiff, (ydiff * (-1.0)));
    CGFloat dottedLineLength = sqrtf(xdiff*xdiff + ydiff*ydiff);
    
    cue.zRotation = cueRotation;
    cue.position = CGPointMake(touchLocation.x, touchLocation.y);
    
    line1.size = CGSizeMake(2.0, dottedLineLength);

    line1.zRotation = cueRotation;
    line1.position = CGPointMake(cue.position.x, cue.position.y);
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    // disable this touch event if the ball is still in motion (set with ballinMotion flag) or
    // if the user is still touching down
    if (ballInMotion || touchDown) {
        return;
    }
    touchDown = true;
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    // if the cue ball was scratched, this flag would have been set and instead of positioning the cue
    // we need to reposition the cue ball first
    if (scratched) {
        
        // check to make sure that the cueball is not being positioned over top of an existing sprite node
        // since we dont the cue positioned out of bounds or interacting with other physics bodies
        // if it is positioned out of bounds, set the starting point at the same location as when the scene starts
        // the cueball can still be moved if the user drags their finger to a valid location before ending the touch
        SKPhysicsBody* body = [self.physicsWorld bodyAtPoint:touchLocation];
        if (body == nil && (touchLocation.x > borderLeftRightWidth && touchLocation.x < (self.frame.size.width - borderLeftRightWidth)) && (touchLocation.y > borderTopBottomHeight && touchLocation.y < (self.frame.size.height - borderTopBottomHeight))) {
            cueBall.position = CGPointMake(touchLocation.x, touchLocation.y);
        }else{
            cueBall.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height*0.27);
        }
        [self addChild:cueBall];
        
    }
    //if cue ball is not scratched do the following when a touch event begins
    else
    {
        // draw a pool cue
        cue = [SKSpriteNode spriteNodeWithImageNamed:@"Cue"];
        line1 = [SKSpriteNode spriteNodeWithImageNamed:@"dottedline"];

        cue.size = CGSizeMake(10.0, 300.0);
        
        // set the anchor point of the pool cue to the tip of the cue so that it is
        // positioned and rotates around the tip of the pool cue sprite instead of the centre of the sprite
        cue.anchorPoint = CGPointMake(0.5, 1.0);
        line1.anchorPoint = CGPointMake(0.5, 0.0);
        [self positionCue:touchLocation];

        
        [self addChild:cue];
        [self addChild:line1];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (touchDown == false || ballInMotion) {
        return;
    }
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    // if the cueball was scratched, move the cueball to the touch position
    if (scratched) {
        
        // check to make sure that the cueball is not being positioned over top of an existing sprite node
        // since we dont the cue positioned out of bounds or interacting with other physics bodies
        SKPhysicsBody* body = [self.physicsWorld bodyAtPoint:touchLocation];
        if (body == nil && (touchLocation.x > borderLeftRightWidth && touchLocation.x < (self.frame.size.width - borderLeftRightWidth)) && (touchLocation.y > borderTopBottomHeight && touchLocation.y < (self.frame.size.height - borderTopBottomHeight))) {
            cueBall.position = touchLocation;
        }
    }
    
    // if the cueball wasn't scratched we use this method to animate/pullback/rotate the pool cue sprite for effect
    [self positionCue:touchLocation];
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    /* Called when a touch begins */
    if (ballInMotion) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    // once the touch is ended we know that the cueball has been placed somewhere and we can reset the flags
    if (scratched) {
        touchDown = false;
        scratched = false;
    }
    
    // grab the difference between the touch location and cue ball from where the touch event ended
    CGFloat xdiff = touchLocation.x - cueBall.position.x;
    CGFloat ydiff = touchLocation.y - cueBall.position.y;
    
    // use the difference in touch loucation to create a vector which will determine how hard the ball is hit
    CGVector hitCueBallVector = CGVectorMake(xdiff/5.0*(-1.0), ydiff/5.0*(-1.0));
    
    // Sk action that will animate the pool cue hitting the cue ball (this doesnt actually do anything other than
    // play an animation since we never apply phsysics to the pool cue, rather we push the cue ball after this animation
    // by using the applyImpluse function on the cueball physics body
    SKAction *shootCueBall = [SKAction moveTo:CGPointMake(cueBall.position.x, cueBall.position.y) duration:0.3];
    
    [line1 removeFromParent];

    [cue runAction:shootCueBall completion:^{
        
        // once the pool cue animation is completed we can set all of the flags that tell us a shot has been taken
        // and apply the impulse to the cue ball that
        
        ballSunk = false;
        ballInMotion = true;
        shotTaken = true;
        touchDown = false;
        [cueBall.physicsBody applyImpulse:hitCueBallVector];
    }];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    touchDown = false;
    [cue removeFromParent];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    // Check if the ballInMotion flag is set
    // We use this flag to disable touch controls while a shot is taken and wait for our phsysics to finish
    if (ballInMotion == true) {
        
        // If the Cue Ball has stopped moving after a shot we can re-allow touch controls and set the ballInMotion flag
        // to false. We Also remove the Pool Cue sprite
        if (cueBall.physicsBody.resting || scratched) {
            ballInMotion = false;
            [cue removeFromParent];
        }
    }
    // once the cue ball has stopped moving, ie the turn finished
    else
    {
        // check if no balls were sunk after a shot was taken
        if (shotTaken == true && ballSunk== false)
        {
            //i f no balls were sunk we decrease the number of tries the player has left
            triesLeft--;
            
            // if there are no tries left we know the game is over and we call the GameViewController to post a high score
            if (triesLeft < 1) {
                [self.delegateContainerViewController gameOver:currScore];
                [self resetTable];
            }
        
            triesLeftLabel.text = [NSString stringWithFormat:@"Tries Left: %d",triesLeft];
            shotTaken = false;
        }
        // if there are no balls left on the table (ie all balls have been sank but the game is still going,
        // call the rackBalls method again
        if (ballsLeftOnTable == 0) {
            [self rackBalls];
        }
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact{
    
    // if the cueball goes into a pocket, ie is scratched
    if (contact.bodyA.categoryBitMask == cueBallCategory && contact.bodyB.categoryBitMask == pocketCategory) {
        // set flags that let us know there is no cue ball on the table and that the player should lose a turn
        scratched = true;
        ballSunk = false;
        // remove the cueball to simulate it going into a pocket
        [cueBall removeFromParent];
    }
    
    // check if any solid, stripe or eightball comes into contact with a pocket
    // we could have applied the same category to solids, stripes and eight balls for the high score game
    // I left the extra categories in case other modes get added later like 2-player where we would need to know
    // what balls are being sank
    if ((contact.bodyA.categoryBitMask == solidCategory || contact.bodyA.categoryBitMask == stripeCategory || contact.bodyA.categoryBitMask == eightCategory) && contact.bodyB.categoryBitMask == pocketCategory) {
        //remove the ball, increment the score, decrease the number storing the amount of balls left on the table
        [contact.bodyA.node removeFromParent];
        currScore++;
        ballsLeftOnTable--;
        currScoreLabel.text = [NSString stringWithFormat:@"Your Score: %d",currScore];
        
        // check if the current score is higher than the best score, if so update the best score
        if (currScore > bestScore) {
            bestScore = currScore;
            bestScoreLabel.text = [NSString stringWithFormat:@"Best: %d",bestScore];
        }
        
        // if the cue ball was note scratched, we set ballsunk to true so the player doesn't lose a turn
        // note this means that even though the player scratches a cueball they still get points for that turn even though
        // they will lose a turn from the scratch
        if(!scratched){
            ballSunk = true;
        }
    }
    

    // The following code was never used but could be used to implement other game modes
    // such as a 2-player mode where we might want to know what type of ball was sunk, if the Eight Ball was sunk, etc
    
    /*
        if (contact.bodyA.categoryBitMask == cueBallCategory && contact.bodyB.categoryBitMask == solidCategory) {
            NSLog(@"cue ball hit a solid");
        }
        if (contact.bodyA.categoryBitMask == cueBallCategory && contact.bodyB.categoryBitMask == stripeCategory) {
            NSLog(@"cue ball hit a stripe");
        }
        if (contact.bodyA.categoryBitMask == cueBallCategory && contact.bodyB.categoryBitMask == eightCategory) {
            NSLog(@"cue ball hit the eight ball");
        }
        if (contact.bodyA.categoryBitMask == solidCategory && contact.bodyB.categoryBitMask == pocketCategory) {
            [contact.bodyA.node removeFromParent];
        }
        if (contact.bodyA.categoryBitMask == stripeCategory && contact.bodyB.categoryBitMask == pocketCategory) {
            [contact.bodyA.node removeFromParent];
        }
        if (contact.bodyA.categoryBitMask == eightCategory && contact.bodyB.categoryBitMask == pocketCategory) {
            [contact.bodyA.node removeFromParent];
        }
     */
}



@end
