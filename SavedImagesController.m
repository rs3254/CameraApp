//
//  SavedImagesController.m
//  Camera
//
//  Created by Ray Sabbineni on 10/27/15.
//  Copyright © 2015 Ray Sabbineni. All rights reserved.
//

#import "SavedImagesController.h"


NSIndexPath * path;
NSMutableArray *pngFiles;
NSMutableArray * directoryContents;
UILongPressGestureRecognizer * longPress;
@interface SavedImagesController ()
@end

@implementation SavedImagesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    
    longPress.delegate = self;
    
    [self.collectionView addGestureRecognizer:longPress];
    
    //self.collectionView.allowsMultipleSelection = YES;
    self.backwardArray = [self PNGArrayFromDocuments];
    
    self.imageFileArray = (NSMutableArray*)[[self.backwardArray reverseObjectEnumerator]allObjects];
    
    NSLog(@"%@", self.imageFileArray);
    
    NSMutableArray * firstSection = [[NSMutableArray alloc]init];
    
    
    self.array  = [[NSArray alloc]initWithObjects:firstSection, nil];
    UINib * cellNib = [UINib nibWithNibName:@"SavedImagesController" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"Cell"];
    
    
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc]init];
    [flowlayout setItemSize:CGSizeMake(200, 200)];
    [flowlayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowlayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.collectionView setCollectionViewLayout:flowlayout];
    
    
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    [self.collectionView.collectionViewLayout invalidateLayout];
    return 1;
}



-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    NSLog(@"%lu", self.imageFileArray .count);
    return self.imageFileArray.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"Cell";
    self.cell = (CollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsObj = [paths objectAtIndex:0];
    NSString * path = [documentsObj stringByAppendingPathComponent:self.imageFileArray[indexPath.row]];
    
    NSError *error = nil;
    UIImage *im = [UIImage imageWithContentsOfFile:path];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    
    self.cell.imageView.image = im;
    self.cell.imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    
    NSLog(@"%@", self.imageFileArray[indexPath.row]);
    
    UITextView *tv = (UITextView*)[self.cell viewWithTag:1001];
    tv.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    
    return self.cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    self.controller = [[ViewController4 alloc]initWithNibName:@"ViewController4" bundle:nil];
    self.controller.newimage2 = self.cell.imageView.image;
    [self.navigationController pushViewController:self.controller animated:YES];
    
    NSLog(@"%@. %@", self.cell.imageView.image, self.controller.newimage2);
    
    
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    // [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    
}

-(NSMutableArray*)PNGArrayFromDocuments {
    
    
    NSArray * pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSFileManager * fileManager = [NSFileManager defaultManager];
    directoryContents = (NSMutableArray*)[fileManager contentsOfDirectoryAtPath:[pathArray objectAtIndex:0] error:nil];
    
    if([directoryContents count]> 0)
    {
        NSPredicate * filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.png'" ];
        pngFiles = (NSMutableArray*)[directoryContents filteredArrayUsingPredicate:filter];
        return pngFiles;
    }
    return nil;
}


-(void)handleLongPress:(UILongPressGestureRecognizer*) gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [gestureRecognizer locationInView:self.collectionView];
        
        path = [self.collectionView indexPathForItemAtPoint:point];
        
        NSArray * paths = [[pngFiles reverseObjectEnumerator]allObjects];
        
        NSString* documentsObj = [paths objectAtIndex:path.row];
 
        NSLog(@"%@", documentsObj);
        [self removeImages:documentsObj];
   }
    
    
   
    
}




-(void)removeImages:(NSString*)filePath {
    
    // [self.collectionView reloadData];
    
    [self.collectionView performBatchUpdates:^{
        
    NSFileManager * fileManager = [NSFileManager defaultManager];
        
    NSArray * filePath2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
    NSString * documentsPath = [filePath2 objectAtIndex:0];
        
    NSLog(@"%@", documentsPath);
        
    NSString * stringFilePath = [documentsPath stringByAppendingPathComponent:filePath];
    NSError * error;
    [fileManager removeItemAtPath:stringFilePath error:&error];
        
    // reset collectonview datasource array after changes
    self.backwardArray = [self PNGArrayFromDocuments];
    self.imageFileArray = (NSMutableArray*)[[self.backwardArray reverseObjectEnumerator]allObjects];

        
        
    [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:path.row inSection:0]]];
        

        
    dispatch_async(dispatch_get_main_queue(), ^{
           [self.collectionView reloadData];

        });
    } completion:nil];
    
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
