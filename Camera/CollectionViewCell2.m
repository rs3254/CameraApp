//
//  CollectionViewCell2.m
//  Camera
//
//  Created by Ray Sabbineni on 10/31/15.
//  Copyright © 2015 Ray Sabbineni. All rights reserved.
//

#import "CollectionViewCell2.h"

@implementation CollectionViewCell2



-(AVPlayer*)player {
    
    return self.playerLayer.player;
}

-(void)setPlayer:(AVPlayer *)player {
    
    self.playerLayer.player = player;
}

+(Class)layerClass {
    
    return [AVPlayerLayer class];
}

-(AVPlayerLayer*)playerLayer {

    return  (AVPlayerLayer*)self.layer; 
}

- (void)awakeFromNib {
    // Initialization code
}

@end
