//
//  ViewController3.m
//  Camera
//
//  Created by Ray Sabbineni on 10/31/15.
//  Copyright © 2015 Ray Sabbineni. All rights reserved.
//

#import "VideosCollectionController.h"



@interface VideosCollectionController ()
@property (strong, nonatomic) NSArray * arrayWithMovieFiles;
@property (strong, nonatomic) UILongPressGestureRecognizer * longPress2;
@property (strong, nonatomic) NSIndexPath * path2;
@property (strong, nonatomic) NSArray * movfiles;
@end

@implementation VideosCollectionController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.arrayWithMovieFiles = [[NSArray alloc]init];
    self.arrayWithMovieFiles = [self movieArrayFromDocuments];
    
    self.arrayWithMovieFiles = [[self.arrayWithMovieFiles reverseObjectEnumerator]allObjects];
    NSLog(@"%@", self.arrayWithMovieFiles);
    NSLog(@"%lu", [self.arrayWithMovieFiles count]);
    
    self.longPress2 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(HandleLongPress:)];
    
    self.longPress2.delegate = self;
    
    [self.collectionView2 addGestureRecognizer:self.longPress2];
    
    UINib * cellnib2 = [UINib nibWithNibName:@"CollectionViewCell2" bundle:[NSBundle mainBundle]];
    [self.collectionView2 registerNib:cellnib2 forCellWithReuseIdentifier:@"Cell2"];
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    [layout setItemSize:CGSizeMake(200, 200)];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    [self.collectionView2 setCollectionViewLayout:layout]; 
    
    
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    
    return [self.arrayWithMovieFiles count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellIdentifier = @"Cell2";
    CollectionViewCell2 * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString * documentObj = [paths objectAtIndex:0];
    NSString * path = [documentObj stringByAppendingPathComponent:self.arrayWithMovieFiles[indexPath.row]];
    
    NSURL * url = [NSURL fileURLWithPath:path];
    self.urlView3 = url; 
    
    AVAsset * asset = [AVAsset assetWithURL:url];
    
 
    NSLog(@"%@", asset);
    
    AVAssetImageGenerator * imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
    CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds, 2);
    NSError *error;
    CMTime actualTime;
    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
    UIImage * imageFromCG = [[UIImage alloc]initWithCGImage:halfWayImage];
    cell.ImageView.image = imageFromCG;
    cell.ImageView.transform = CGAffineTransformMakeRotation(M_PI_2);

    UITextView * tv = (UITextView*)[cell viewWithTag:100];
    tv.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    
    return cell; 
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.collectionView2 reloadItemsAtIndexPaths:@[indexPath]];

    ViewController5 * controller = [[ViewController5 alloc]initWithNibName:@"ViewController5" bundle:nil] ;
    controller.urlFromViewController5 = self.urlView3;
    if(self.slowMotionButton.isSelected ==YES)
    {
        controller.rateValue = .5;
    }
    else if(self.normalRecordSpeedButton.isSelected == YES)
    {
        controller.rateValue = 1;
    }
    else if(self.fastRecordingButton.isSelected ==YES)
    {
        controller.rateValue = 2;
    }
    else
    {
        controller.rateValue = 1; 
    }
    [self.navigationController pushViewController:controller animated:YES];
    
}

-(NSArray*)movieArrayFromDocuments {
    NSArray * pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * directories = [fileManager contentsOfDirectoryAtPath:[pathArray objectAtIndex:0] error:nil];
    
    if([directories count] >0)
    {
        NSPredicate * filter = [NSPredicate predicateWithFormat:@"self ENDSWITH 'mov'"];
        self.movfiles = [directories filteredArrayUsingPredicate:filter];
        return self.movfiles;
    }
    NSArray * otherArray = [[NSArray alloc]init];
    return  otherArray;
}

-(void)HandleLongPress:(UILongPressGestureRecognizer*)gesture
{
 if(gesture.state == UIGestureRecognizerStateEnded)
 {
     CGPoint point = [gesture locationInView:self.collectionView2];
     self.path2 = [self.collectionView2 indexPathForItemAtPoint:point];
     NSArray * movArray2 = [[self.movfiles reverseObjectEnumerator]allObjects];
     
     NSString * documentsObj = [movArray2 objectAtIndex:self.path2.row];
     
     [self removeMovie:documentsObj]; 
     NSLog(@"ended"); 
 }
    
    
}

-(void)removeMovie:(NSString*)filePath {
    
    
    [self.collectionView2 performBatchUpdates:^{
        
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSArray * filePath2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsPath = [filePath2 objectAtIndex:0];
        NSString * stringFile = [documentsPath stringByAppendingPathComponent:filePath];
        [fileManager removeItemAtPath:stringFile error:nil];
        
        self.arrayWithMovieFiles = [self movieArrayFromDocuments];
        
        self.arrayWithMovieFiles = [[self.arrayWithMovieFiles reverseObjectEnumerator]allObjects];
        
        [self.collectionView2 deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.path2.row inSection:0]]];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView2 reloadData];
        }); 
        
     } completion:nil];
}



-(void)playerItemDidReachEnd:(NSNotification*)notification {
    
}


- (IBAction)slowMotionButtonPressed:(id)sender {
    [self.slowMotionButton setSelected:YES];
    [self.slowMotionButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [self.fastRecordingButton setSelected:NO];
    [self.normalRecordSpeedButton setSelected:NO];
}


- (IBAction)normalRecordButtonPressed:(id)sender {
    [self.normalRecordSpeedButton setSelected:YES];
    [self.normalRecordSpeedButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [self.fastRecordingButton setSelected:NO];
    [self.slowMotionButton setSelected:NO];
}

- (IBAction)fastRecordButtonPressed:(id)sender {
    [self.fastRecordingButton setSelected:YES];
    [self.fastRecordingButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [self.normalRecordSpeedButton setSelected:NO];
    [self.slowMotionButton setSelected:NO];
}


@end
