//
//  ViewController5.m
//  Camera
//
//  Created by Ray Sabbineni on 11/4/15.
//  Copyright © 2015 Ray Sabbineni. All rights reserved.
//

#import "ViewController5.h"

@interface ViewController5 ()

@end

@implementation ViewController5

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"%@", self.urlFromViewController5);
    
    NSURL * url2 = self.urlFromViewController5;
    
    NSLog(@"%@", url2);

    AVURLAsset * asset = [AVURLAsset URLAssetWithURL:url2 options:nil];
    
    self.player = [AVPlayer playerWithURL:url2];
    
    [self.view.layer addSublayer:[AVPlayerLayer playerLayerWithPlayer:self.player]];
    
    
    self.view.layer.sublayers.firstObject.frame = self.view.frame;
    self.player.rate = self.rateValue; 


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
