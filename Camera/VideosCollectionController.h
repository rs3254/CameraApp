//
//  VideosCollectionController.h
//  Camera
//
//  Created by Ray Sabbineni on 10/31/15.
//  Copyright © 2015 Ray Sabbineni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewCell2.h"
#import "ViewController5.h"

//VideosCollectionController

@interface VideosCollectionController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate>




@property (strong, nonatomic) IBOutlet UICollectionView *collectionView2;
@property(nonatomic)AVPlayer * player;
@property(nonatomic)AVPlayerItem * playerItem;
@property AVURLAsset * asset;
@property(nonatomic, strong)ViewController5 * controller5;
@property(nonatomic, strong)NSURL * urlView3;

@property (strong, nonatomic) IBOutlet UIButton *slowMotionButton;
@property (strong, nonatomic) IBOutlet UIButton *normalRecordSpeedButton;
@property (strong, nonatomic) IBOutlet UIButton *fastRecordingButton;

@end
