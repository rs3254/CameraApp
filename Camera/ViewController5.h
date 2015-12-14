//
//  ViewController5.h
//  Camera
//
//  Created by Ray Sabbineni on 11/4/15.
//  Copyright © 2015 Ray Sabbineni. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation; 
//VideoPlaybackViewController

@interface ViewController5 : UIViewController

@property (nonatomic, strong)AVPlayer * player;

@property(nonatomic, strong)AVPlayerLayer * playerLayer;


@property(nonatomic, strong)NSURL * urlFromViewController5;



@property(nonatomic)float rateValue; 

@end
