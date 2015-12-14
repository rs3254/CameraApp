//
//  CollectionViewCell2.h
//  Camera
//
//  Created by Ray Sabbineni on 10/31/15.
//  Copyright © 2015 Ray Sabbineni. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;



@interface CollectionViewCell2 : UICollectionViewCell



@property AVPlayer * player;

@property(nonatomic)AVPlayerLayer * playerLayer;


@property (strong, nonatomic) IBOutlet UIImageView *ImageView;





@end
