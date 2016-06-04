//
//  MyScene.h
//  dumpTruck
//

//  Copyright (c) 2014 Rijul Gupta. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MyScene : SKScene


@property bool touchRecognized;
@property int globalFriction;
@property double globalLinearDamping;

@property int positionSize;
@property int sideSize;
@property int score;

@property bool justSwitchedNumberOfSquares;

@end
