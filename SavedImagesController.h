//
//  SavedImagesController.h
//  Camera
//
//  Created by Ray Sabbineni on 10/27/15.
//  Copyright © 2015 Ray Sabbineni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptureViewController.h"
#import "CollectionViewCell.h"
#import "ViewController4.h"

@interface SavedImagesController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property(strong, nonatomic)NSArray * array;


@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;


@property(strong, nonatomic)NSMutableArray * imageFileArray;
@property(strong, nonatomic)NSMutableArray * backwardArray; 
@property(strong, nonatomic)UIImageView * imageView;

@property(strong, nonatomic)CollectionViewCell * cell;
@property(strong, nonatomic)ViewController4 * controller;

@end
