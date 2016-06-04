//
//  MyScene.m  -- TOUCH EVERY SQUARE. DON"T LET SQUARE GO UNTOUCHED.
//  dumpTruck
//
//  Created by Rijul Gupta on 4/9/14.
//  Copyright (c) 2014 Rijul Gupta. All rights reserved.
//

#import "MyScene.h"
#define   IsIphone5     ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )


/*
static const uint32_t truckCategory     =  1 << 1;
static const uint32_t floorCategory     =  1 << 2;
static const uint32_t lawnCategory     =  1 << 3;
static const uint32_t dividerCategory     =  1 << 4;
static const uint32_t garbageBagCategory     =  1 << 5;
static const uint32_t squareCategory     =  1 << 6;
static const uint32_t touchedCategory     =  1 << 7;
*/

@interface MyScene () <SKPhysicsContactDelegate>

@property (nonatomic) double sizeChanger;

@property (nonatomic) SKSpriteNode * dumpTruck;



//@property (nonatomic) NSMutableArray * mainSquareArray;



@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval addRowInterval;

//@property (nonatomic) int numberSquaresPerRow;
//@property (nonatomic) int previousnumberSquaresPerRow;

@property (nonatomic) int numberRows;


@property (nonatomic) NSMutableArray *rowHolder;
@property (nonatomic) int currentNumberOfRows;

@property (nonatomic) NSMutableArray *squareHolder;
@property (nonatomic) NSMutableArray *touchedSquareHolder;

@property (nonatomic) CGVector globalVelocity;

@property (nonatomic) SKNode *backDropHolder;

@property (nonatomic) SKSpriteNode * gameOverOverlay;
@property (nonatomic) BOOL gameIsOver;
@property (nonatomic) UIColor *truckColor;
@property (nonatomic) UIColor *bagColor;
@property (nonatomic) UIColor *obstacleColor;
@property (nonatomic) UIColor *backColor;

@end

@implementation MyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self setupGame];
        
    }
    return self;
}

-(void)setupGame{
    
    
    _gameIsOver = false;
    _sizeChanger = self.size.width/320;
    _rowHolder = [NSMutableArray array];
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    self.physicsWorld.contactDelegate = self;
    self.backgroundColor = [self colorWithHexString:@"2C3E50"];
   // _numberSquaresPerRow = 2;
   // _previousnumberSquaresPerRow = 1;
    
    _numberRows = 30;
    _globalFriction = 20.0;//not used
    _globalLinearDamping = 10;//not used
    _sideSize = 60;
    _justSwitchedNumberOfSquares = false;
    _currentNumberOfRows = 0;
    _addRowInterval = 0.0;
    _globalVelocity = CGVectorMake(0, -150);
    
    _positionSize = round((self.size.width)/3.0);
    
    
   // _mainSquareArray = [[NSMutableArray alloc] init];
    _squareHolder = [NSMutableArray array];
    _touchedSquareHolder = [NSMutableArray array];

   
   // [self setUpBackDrop];
   /*
    
    for(int i = 0; i < 5; i ++){
        [self addRow];

    }


    */
    
    _truckColor = [self colorWithHexString:@"3FFF39"];
    _bagColor = [self colorWithHexString:@"B27812"];
    _obstacleColor = [self colorWithHexString:@"FFA300"];
    _backColor = [self colorWithHexString:@"8314CC"];
    
    
}


-(void)setUpBackDrop{
    /*
    _backDropHolder = [SKNode node];
    
    SKSpriteNode *backDrop = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(self.size.width, self.size.height)];
    backDrop.position = CGPointMake(self.size.width/2, self.size.height/2);
    [_backDropHolder addChild:backDrop];
    
    SKSpriteNode *scoreHolder = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(280*_sizeChanger, 150*_sizeChanger)];
    scoreHolder.position = CGPointMake(self.size.width/2, 400*_sizeChanger);
    [_backDropHolder addChild:scoreHolder];
    scoreHolder.name = @"scoreHolderNode";
    
    SKSpriteNode *newGameButton = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(100*_sizeChanger, 50*_sizeChanger)];
    newGameButton.position = CGPointMake(self.size.width/2 - 100*_sizeChanger, 300*_sizeChanger);
    [_backDropHolder addChild:newGameButton];
    newGameButton.name = @"scoreHolderNode";
    
    
    
    
    
    
    [self addChild:_backDropHolder];
   // _backDropHolder.frame = CGRectMake(0, 0, self.size.width, self.size.height);
     */
    
    
    int cornerSize = 15*_sizeChanger;
    int fontSize = 20*_sizeChanger;
    
    int addScreenHeight = 0;
    if(IsIphone5) addScreenHeight = 44;
    double duration = 0.4;
    double duration2 = 0.5;
    
    [self removeAllChildren];
    
    SKAction *fadeInFirst = [SKAction fadeAlphaTo:1 duration:duration2];
    _gameOverOverlay = [SKSpriteNode spriteNodeWithColor:_truckColor size:self.size];
    _gameOverOverlay.position = CGPointMake(self.size.width/2, self.size.height/2);
    _gameOverOverlay.name = @"gameOverOverlayNode";
    
    [_gameOverOverlay runAction:[SKAction fadeAlphaTo:1 duration:duration] completion:^{
        //  [self removeAllChildren];
    }];
    
    
    [self addChild:_gameOverOverlay];
    _gameOverOverlay.zPosition = 200;
    
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    
    label.fontColor = _bagColor;
    label.fontSize = fontSize + 12*_sizeChanger;
    label.text = @"Game Over!";
    label.position = CGPointMake(0, 200*_sizeChanger + addScreenHeight);
    [_gameOverOverlay addChild:label];
    
    
    
    SKShapeNode* scoreBox = [SKShapeNode node];
    CGPathRef scoreBoxPath = CGPathCreateWithRoundedRect(CGRectMake(-cornerSize, -cornerSize, 200*_sizeChanger, 80*_sizeChanger), 4*_sizeChanger, 4*_sizeChanger, nil);
    [scoreBox setPath:scoreBoxPath];
    scoreBox.lineWidth = 0.5*_sizeChanger;
    scoreBox.strokeColor = _obstacleColor;
    scoreBox.fillColor = _backColor;
    scoreBox.position = CGPointMake(0 - scoreBox.frame.size.width/2 + cornerSize, (120 + addScreenHeight)*_sizeChanger);
    CGPathRelease(scoreBoxPath);
    
    SKLabelNode *scoreLabel1 = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    scoreLabel1.fontColor = _bagColor;
    scoreLabel1.fontSize = fontSize - 2*_sizeChanger;
    scoreLabel1.text = @"SCORE";
    scoreLabel1.position = CGPointMake(scoreBox.frame.size.width/2 - cornerSize, 45*_sizeChanger);
    [scoreBox addChild:scoreLabel1];
    
    SKLabelNode *scoreLabel2 = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    scoreLabel2.fontColor =_bagColor;
    scoreLabel2.fontSize = fontSize;
    scoreLabel2.text = [NSString stringWithFormat:@"%d", _score];
    scoreLabel2.position = CGPointMake(scoreBox.frame.size.width/2 - cornerSize, 29*_sizeChanger);
    [scoreBox addChild:scoreLabel2];
    
    SKLabelNode *scoreLabel3 = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    scoreLabel3.fontColor =_bagColor;
    scoreLabel3.fontSize = fontSize - 2*_sizeChanger;
    scoreLabel3.text = @"HIGH SCORE";
    scoreLabel3.position = CGPointMake(scoreBox.frame.size.width/2 - cornerSize, 7*_sizeChanger);
    [scoreBox addChild:scoreLabel3];
    
    NSInteger lastHighScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"high_score"];
    SKLabelNode *scoreLabel4 = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    scoreLabel4.fontColor =_bagColor;
    scoreLabel4.fontSize = fontSize;
    scoreLabel4.text = [NSString stringWithFormat:@"%ld", (long)lastHighScore];
    scoreLabel4.position = CGPointMake(scoreBox.frame.size.width/2 - cornerSize, -9*_sizeChanger);
    [scoreBox addChild:scoreLabel4];
    
    [_gameOverOverlay addChild:scoreBox];
    [scoreBox setAlpha:0];
    [scoreBox runAction:fadeInFirst];
    
    
    // lastHighScore = 0;
    
    if(_score > lastHighScore){
        
        scoreLabel1.text = @"NEW HIGH SCORE";
        scoreLabel1.position = CGPointMake(scoreBox.frame.size.width/2 - cornerSize, 45*_sizeChanger);
        scoreLabel3.text = @"CONGRATULATIONS";
        scoreLabel3.position = CGPointMake(scoreBox.frame.size.width/2 - cornerSize, 7*_sizeChanger);
        scoreLabel4.text = @"________________";
        scoreLabel4.position = CGPointMake(scoreBox.frame.size.width/2 - cornerSize, -9*_sizeChanger);
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    SKShapeNode* shareBox = [SKShapeNode node];
    CGPathRef shareBoxPath = CGPathCreateWithRoundedRect(CGRectMake(-cornerSize, -cornerSize, 200*_sizeChanger, 40*_sizeChanger), 4*_sizeChanger, 4*_sizeChanger, nil);
    [shareBox setPath:shareBoxPath];
    shareBox.name = @"shareBoxNode";
    shareBox.lineWidth = 0.5*_sizeChanger;
    shareBox.strokeColor = _obstacleColor;
    shareBox.fillColor = _backColor;
    shareBox.position = CGPointMake(0 - shareBox.frame.size.width/2 + cornerSize, (70 + addScreenHeight)*_sizeChanger);
    CGPathRelease(shareBoxPath);
    
    SKLabelNode *shareLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    shareLabel.name = @"shareLabelNode";
    shareLabel.fontColor = _bagColor;
    shareLabel.fontSize = fontSize - 0*_sizeChanger;
    shareLabel.text = @"SHARE";
    
    shareLabel.position = CGPointMake(shareBox.frame.size.width/2 - cornerSize, 0 - shareLabel.frame.size.height/2 + cornerSize/2);
    [shareBox addChild:shareLabel];
    /*
    
    if([self checkShareDate] == TRUE){
        CGPathRef shareBoxPath = CGPathCreateWithRoundedRect(CGRectMake(-cornerSize, -cornerSize, 270*_sizeChanger, 40*_sizeChanger), 4*_sizeChanger, 4*_sizeChanger, nil);
        [shareBox setPath:shareBoxPath];
        shareBox.position = CGPointMake(0 - shareBox.frame.size.width/2 + cornerSize, (70 + addScreenHeight)*_sizeChanger);
        
        CGPathRelease(shareBoxPath);
        
        shareLabel.text = @"SHARE FOR MORE POINTS";
        shareLabel.position = CGPointMake(shareBox.frame.size.width/2 - cornerSize, 0 - shareLabel.frame.size.height/2 + cornerSize/2);
    }
    else{
        
    }
     */
    //  shareBox.position = CGPointMake(0, 10*_sizeChanger);
    [_gameOverOverlay addChild:shareBox];
    
    [shareBox setAlpha:0];
    [shareBox runAction:fadeInFirst];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // int squareSize = 50;
    // int spaceSize = (self.size.width - squareSize*4)/5;
    //  int spaceAdjuster = 80;
    
    
    SKSpriteNode *fb = [SKSpriteNode spriteNodeWithImageNamed:@"facebook_128"];
    fb.size = CGSizeMake(75*_sizeChanger, 75*_sizeChanger);
    fb.position = CGPointMake(0 + 60*_sizeChanger, shareBox.position.y + 10 - fb.size.height);
    [_gameOverOverlay addChild:fb];
    fb.name = @"fbNode";
    fb.zPosition = 100;
    //[fb runAction:[SKAction moveByX:0 y:-200*_sizeChanger duration:0.5]];
    [fb setAlpha:0];
    [fb runAction:fadeInFirst];
    
    
    SKSpriteNode *tw = [SKSpriteNode spriteNodeWithImageNamed:@"twitter_128"];
    tw.size = CGSizeMake(75*_sizeChanger, 75*_sizeChanger);
    tw.position = CGPointMake(0 - 60*_sizeChanger,  shareBox.position.y + 10 - tw.size.height);
    [_gameOverOverlay addChild:tw];
    tw.name = @"twNode";
    tw.zPosition = 100;
    // [tw runAction:[SKAction moveByX:0 y:-200*_sizeChanger duration:0.5]];
    [tw setAlpha:0];
    [tw runAction:fadeInFirst];
    
    SKSpriteNode *rp = [SKSpriteNode spriteNodeWithImageNamed:@"squarePandaButton_small"];
    rp.size = CGSizeMake(125*_sizeChanger, 125*_sizeChanger);
    
    rp.position = CGPointMake(18*_sizeChanger + rp.frame.size.width/2, (-102 - addScreenHeight)*_sizeChanger);
    [_gameOverOverlay addChild:rp];
    rp.name = @"rpNode";
    rp.zPosition = 100;
    //[rp runAction:[SKAction moveByX:0 y:-200*_sizeChanger duration:0.5]];
    [rp setAlpha:0];
    
    
    
    //   jjhkj
    SKShapeNode* shareBox2 = [SKShapeNode node];//leaderboard
    CGPathRef shareBox2Path = CGPathCreateWithRoundedRect(CGRectMake(-cornerSize, -cornerSize, 150*_sizeChanger, 50*_sizeChanger), 4*_sizeChanger, 4*_sizeChanger, nil);
    [shareBox2 setPath:shareBox2Path];
    shareBox2.lineWidth = 0.5*_sizeChanger;
    shareBox2.strokeColor = _obstacleColor;
    shareBox2.fillColor = _backColor;
    shareBox2.position = CGPointMake(20*_sizeChanger - shareBox2.frame.size.width - 0*cornerSize, (-75 - addScreenHeight)*_sizeChanger);
    shareBox2.name = @"leaderboardButtonNode";
    [shareBox2 setAlpha:0];
    CGPathRelease(shareBox2Path);
    
    SKLabelNode *leaderboardLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    leaderboardLabel.fontColor = _bagColor;
    leaderboardLabel.fontSize = fontSize - 2*_sizeChanger;
    leaderboardLabel.text = @"LEADERBOARD";
    leaderboardLabel.name = @"leaderboardButtonNode";
    leaderboardLabel.position = CGPointMake(shareBox2.frame.size.width/2 - cornerSize, 0);
    [shareBox2 addChild:leaderboardLabel];
    
    [_gameOverOverlay addChild:shareBox2];
    
    
    
    
    
    SKShapeNode* newgameBox = [SKShapeNode node];
    CGPathRef newGamePath = CGPathCreateWithRoundedRect(CGRectMake(-cornerSize, -cornerSize, 150*_sizeChanger, 50*_sizeChanger), 4*_sizeChanger, 4*_sizeChanger, nil);
    [newgameBox setPath:newGamePath];
    newgameBox.lineWidth = 0.5*_sizeChanger;
    newgameBox.strokeColor = _obstacleColor;
    newgameBox.fillColor = _backColor;
    newgameBox.position = CGPointMake(20*_sizeChanger - newgameBox.frame.size.width + 0*cornerSize, (-150 - addScreenHeight)*_sizeChanger);
    newgameBox.name = @"newgameNode";
    [newgameBox setAlpha:0];
    CGPathRelease(newGamePath);
    
    
    SKLabelNode *newgameLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    newgameLabel.fontColor = _bagColor;
    newgameLabel.fontSize = fontSize + 4*_sizeChanger;
    newgameLabel.text = @"NEW GAME";
    newgameLabel.name = @"newgameNode";
    newgameLabel.position = CGPointMake(newgameBox.frame.size.width/2 - cornerSize,0);
    [newgameBox addChild:newgameLabel];
    
    [_gameOverOverlay addChild:newgameBox];
    
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (duration2*1.5) * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //  [self dismissNode:emitterSprite];
        // [self gameOver];
        [shareBox2 runAction:fadeInFirst];
        [newgameBox runAction:fadeInFirst];
        [rp runAction:fadeInFirst];
        
    });
    
    
    
}
-(void)addRow{
    
    int maxSquares = 8;
    int maxRows = 20;

    
    if(_rowHolder.count < _currentNumberOfRows + 4){
        
        int counterDif = (_currentNumberOfRows + 4) - _rowHolder.count;
        for (int k = 0; k < counterDif; k++) {
            NSMutableArray *holder = [NSMutableArray array];
            
            for (int l = 0; l < maxSquares; l++) {
                [holder addObject:[NSNumber numberWithInt:10]];
            }
            [_rowHolder addObject:holder];
        }
        
    }
    

    
    NSMutableArray *row = [NSMutableArray array];
    NSMutableArray *squareRow = [NSMutableArray array];

    
    row = [_rowHolder objectAtIndex:_currentNumberOfRows];
    float lastRowCenter = 250;
    bool doesHaveSquares = false;

    double duration = 0.1;
    SKAction *flashUp_a = [SKAction fadeAlphaTo:1 duration:duration];
    SKAction *flashUp_b = [SKAction fadeAlphaTo:0.5 duration:duration];
    SKAction *falshUpSequence = [SKAction sequence:@[flashUp_a, flashUp_b]];
    
    SKAction *colorUp_a = [SKAction colorizeWithColor:[UIColor blackColor] colorBlendFactor:1 duration:duration];
    SKAction *colorUp_b = [SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:1 duration:duration];
    SKAction *colorUpSequence = [SKAction sequence:@[colorUp_a, colorUp_b]];
    
    SKAction *totalSequnce = [SKAction group:@[falshUpSequence, colorUpSequence]];
    
    SKAction *repeatAction = [SKAction repeatActionForever:totalSequnce];
    
    for (int i = 0; i < maxSquares; i++) {
        int rowNumber = [[row objectAtIndex:i] intValue];
        if(rowNumber == 10){
        int spacesLeft = maxSquares - i;
            doesHaveSquares = true;
            
            int spaceCounter = 0;
            if(_currentNumberOfRows > 0){
                for (int y = i; y < maxSquares; y++) {
                    int testSize = [[[_rowHolder objectAtIndex:_currentNumberOfRows] objectAtIndex:y] intValue];
                    
                    if(testSize == 10) spaceCounter = spaceCounter + 1;
                    else y = maxSquares;
                    
                }
                
                if(spaceCounter < spacesLeft) spacesLeft = spaceCounter;
            }
            int rowSize = 10;
            int rand4 = ceil(40.0/(_currentNumberOfRows + 1))*2 - 0;
            int rand8 = ceil(80.0/(_currentNumberOfRows + 1))*2 - 0;

        if(spacesLeft >= 4){
            rowSize = 2;
            if(_currentNumberOfRows >= 8){
                if(arc4random()%rand4 == 0) rowSize = 4;
                
                if(_currentNumberOfRows >= 30){
                    if(arc4random()%rand8 == 0) rowSize = 8;

                }
            }
            
            
        }
        else if(spacesLeft >= 2){
             rowSize = 4;
            if(_currentNumberOfRows >= 30){
                if(arc4random()%rand8 == 0) rowSize = 8;
            }

        }
        else{
            rowSize = 8;
        }

            
            
            
            int yPosAdd = lastRowCenter;


            
            int squareSizer = ceil(self.frame.size.width/rowSize);
            
            SKSpriteNode *squareSprite = [SKSpriteNode spriteNodeWithColor:[self colorWithHexString:@"ECF0F1"] size:CGSizeMake(squareSizer, squareSizer)];
            squareSprite.name = @"squareSpriteNode";
            //[self addChild:squareSprite];
            [squareRow addObject:squareSprite];
            squareSprite.alpha = 0.5;
            
            

            

            
            
            int yPos = yPosAdd + squareSizer/2;//squareSprite.size.height/2 + testNode.size.height/2 + testNode.position.y + 50;
            
            CGVector prevVel = CGVectorMake(0, 0);
            
            if(_currentNumberOfRows > 0){
                
                SKSpriteNode *firstNodeOfRow = [[_squareHolder objectAtIndex:(_squareHolder.count - 1)] objectAtIndex:(0)];
                
                int testYpos = firstNodeOfRow.position.y - firstNodeOfRow.size.height/2 + 20;
                int testXPos = i*(self.size.width/maxSquares) + squareSizer/2 - 5;
                
                
                SKSpriteNode *testBeneathNode = (SKSpriteNode *)[self nodeAtPoint:CGPointMake(testXPos, testYpos)];
                yPos = testBeneathNode.position.y + testBeneathNode.size.height/2 + squareSizer/2+ 0;
                
                prevVel = firstNodeOfRow.physicsBody.velocity;

                
            }
            int xPos = squareSprite.size.width/2;
            
            xPos = i*(self.size.width/maxSquares) + squareSizer/2;
         //   [_mainSquareArray addObject:squareSprite];
            
            squareSprite.position = CGPointMake(xPos, yPos);
            squareSprite.zPosition = 1;
            
            
            squareSprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:squareSprite.size];
            // 1
            
            //prevVel = CGVectorMake(0, 0);
            squareSprite.physicsBody.velocity = _globalVelocity;
            
            
            squareSprite.physicsBody.dynamic = YES; // 2
            squareSprite.physicsBody.friction = 0;
            squareSprite.physicsBody.linearDamping = 0;
         //   squareSprite.physicsBody.categoryBitMask = squareCategory;
            squareSprite.physicsBody.collisionBitMask = 0;
         //   squareSprite.physicsBody.contactTestBitMask = truckCategory;
            
            int arrayChanger = 1;
            if(rowSize == 2) arrayChanger = 4;
            if(rowSize == 4) arrayChanger = 2;
            if(rowSize == 8) arrayChanger = 1;
            
            for (int j = 0; j < arrayChanger; j++) {
                for (int k = 0; k < arrayChanger; k++) {
                    int num = rowSize;
                    [[_rowHolder objectAtIndex:(_currentNumberOfRows + k)] replaceObjectAtIndex:(i + j) withObject:[NSNumber numberWithInt:num]];
                    
                    NSLog(@"POWER POWER POWER %d", num);

                }
            }

            
        }
    }
    

    
    if(doesHaveSquares == true){
        [_squareHolder addObject:squareRow];
        
        for(int i = 0; i < squareRow.count; i++){
            SKSpriteNode *testNode = [squareRow objectAtIndex:i];
            [self addChild:testNode];
            [testNode runAction:repeatAction];
        }
    }

    [_rowHolder replaceObjectAtIndex:_currentNumberOfRows withObject:row];
    
    _currentNumberOfRows = _currentNumberOfRows + 1;
    
}

-(void)squareTouched:(SKSpriteNode *)node{
    
  
    if(_gameIsOver == false){
    
    if([node.name isEqualToString:@"squareTouchedName"]){
        
    }
    else{
        double duration = 0.1;
        SKAction *grow = [SKAction scaleTo:1.5 duration:duration];
        SKAction *shrink = [SKAction scaleTo:1.0 duration:duration];
        SKAction *sequence = [SKAction sequence:@[grow, shrink]];
        node.name = @"squareTouchedName";
        [node removeAllActions];
      //  [node setColor:[UIColor redColor]];
   //     [node setColorBlendFactor:1];
        [node runAction:[SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:1 duration:0.05]];
        [node runAction:sequence];
        node.alpha = 1.0;

        [self increaseScore];

        
    }
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        
        if([node.name isEqualToString:@"squareSpriteNode"])
        {
            SKSpriteNode *node2 = (SKSpriteNode *)node;
            [self squareTouched:node2];
        }
        
        if(_gameIsOver == true){
            SKNode *backNode = [_backDropHolder nodeAtPoint:location];
            if([node.name isEqualToString:@"scoreHolderNode"]){
                
                SKView * skView = (SKView *)self.view;

                
                // Create and configure the scene.
                SKScene * scene = [MyScene sceneWithSize:skView.bounds.size];
                scene.scaleMode = SKSceneScaleModeAspectFill;
                
                // Present the scene.
                [skView presentScene:scene];
                
            }


        }
        
        
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        SKNode *node = [self nodeAtPoint:location];
        
        if([node.name isEqualToString:@"squareSpriteNode"])
        {
            SKSpriteNode *node2 = (SKSpriteNode *)node;
            [self squareTouched:node2];
        }
        
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        CGPoint checkPoint = CGPointMake(location.x - self.size.width/2, location.y - self.size.height/2);
        SKSpriteNode *node = (SKSpriteNode *)[_gameOverOverlay nodeAtPoint:checkPoint];

        
        if([node.name isEqualToString:@"newgameNode"] && _gameIsOver == true){
            // NSLog(@"lsdkfjkllskdfj");
            
            
            [_gameOverOverlay removeFromParent];
    //        _gameHasStarted = false;
            //  [self setupGame];
           // [self runAction:[SKAction playSoundFileNamed:@"buttonClicked.mp3" waitForCompletion:NO]];
            
        //    [_backgroundMusicPlayer stop];
        //    _backgroundMusicPlayer = nil;
            SKView * skView = (SKView *)self.view;
            //SKView *skView = [[SKView alloc] initWithFrame:self.view.frame];
            //  skView.showsFPS = YES;
            //  skView.showsNodeCount = YES;
            
            // Create and configure the scene.
            SKScene * scene = [MyScene sceneWithSize:skView.bounds.size];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            
            // Present the scene.
            [skView presentScene:scene];
            
        }
        
        
    }
}

-(void)increaseScore{
    _score = _score + 1;
    NSLog(@"Score - %d",_score);
    
 //   _previousnumberSquaresPerRow = _numberSquaresPerRow;
    
    //   _numberRows = floor(_score/10.0) + 5;
    int x = _score;
       double changePerScore = 0.12 - pow((x*0.01), 3)*0.1;
    double changeVelPerScore = 5;
    
    if(changePerScore <= 0.02){
        changePerScore = 0.02;
    }
    _globalLinearDamping  = _globalLinearDamping - changePerScore;
    if(_globalLinearDamping <= 3.0)
    {
        _globalLinearDamping = 3;
    }
    
    _globalVelocity = CGVectorMake(0, _globalVelocity.dy - changeVelPerScore);
    for(int i = 0; i < _squareHolder.count; i++){
        
        NSMutableArray *testArray = [_squareHolder objectAtIndex:i];
        
        for (int j = 0; j < testArray.count; j++) {
            SKSpriteNode *testNode = [testArray objectAtIndex:j];
          //  testNode.physicsBody.linearDamping = _globalLinearDamping;
            testNode.physicsBody.velocity = _globalVelocity;

        }
        
        
    }
    for (int i = 0; i < _touchedSquareHolder.count; i++) {
        SKSpriteNode *testNode = [_touchedSquareHolder objectAtIndex:i];
       // testNode.physicsBody.linearDamping = _globalLinearDamping;
        testNode.physicsBody.velocity = _globalVelocity;


    }
    
}
-(void)endGame{
    
    _gameIsOver = true;
    //NSLog(@"Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||Game end||");
    _globalVelocity = CGVectorMake(0, 0);
    
    
    for(int i = 0; i < _squareHolder.count; i++){
        NSMutableArray *testArray = [_squareHolder objectAtIndex:i];
        for(int j = 0; j < testArray.count; j++){
            SKSpriteNode *testNode = [testArray objectAtIndex:j];

            if([testNode.name isEqualToString:@"squareSpriteNode"]){
            CGVector pushVector = CGVectorMake(0, 0);
            int changeX = 0;
            int changeY = 0;

            
            int xDiff = testNode.position.x - self.size.width/2;
            int yDiff = testNode.position.y - self.size.height/2;

            if(xDiff < 0){
                changeX = -10 + (xDiff/self.size.width/2)*10;
            }
            else{
                changeX = 10 + (xDiff/self.size.width/2)*10;

            }
            
            if(yDiff < 0){
                changeY = -10 + (yDiff/self.size.height/2)*50;
            }
            else{
                changeY = 10 + (yDiff/self.size.height/2)*50;

            }
            testNode.physicsBody.velocity = CGVectorMake(changeX*20, changeY*20);

        }
        else{
            testNode.physicsBody.velocity = CGVectorMake(0, testNode.physicsBody.velocity.dy*4);

        }
          //  [self fadeOut:testNode];
            [testNode runAction:[SKAction fadeAlphaTo:0 duration:0.3] completion:^{
                [testNode removeFromParent];
            }];

        }
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (0.5) * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //  [self dismissNode:emitterSprite];
        // [self gameOver];
        [self setUpBackDrop];

        
    });
    
    
    
}

//sets events to happen at a given time interval
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    
    _addRowInterval += timeSinceLast;
    
    if(_gameIsOver == false){
    if(_addRowInterval >= (0.02)){
        
        if(_squareHolder.count <= 18){
        
            [self addRow];
            _addRowInterval = 0.0;
        }
    }
    
    
 
    if(_squareHolder.count > 0){
    int i = 0;
        bool didActivate = false;
        NSMutableArray *arrayHolder = [_squareHolder objectAtIndex:i];
        
        for (int j = 0; j < arrayHolder.count; j++) {
            SKSpriteNode *testNode = [arrayHolder objectAtIndex:j];

            int checker = testNode.position.y + testNode.size.height/2;

            
            if(checker <= 50){
              //  [testNode removeFromParent];
                if([testNode.name isEqualToString:@"squareSpriteNode"]){
                    [self endGame];
                }
                didActivate = true;
            }
            
            
        }
        
        if(didActivate == true){

            NSLog(@"LSKDFJLSDKFJSKDF");
            for (int j = 0; j < arrayHolder.count; j++) {
                SKSpriteNode *testNode = [arrayHolder objectAtIndex:j];
                [testNode removeFromParent];
            }
            [_squareHolder removeObjectAtIndex:i];


        }
    }
    }


}




- (void)update:(NSTimeInterval)currentTime {
    
    
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    //
    //
    
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}

-(void)fadeOut:(SKSpriteNode *)node{
    
    
    [node runAction:[SKAction fadeAlphaBy:-0.1 duration:0.05] completion:^{
        
        [self fadeOut:node];
    }];
    
}



-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}






@end
