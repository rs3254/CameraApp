//
//  ViewController4.m
//  Camera
//
//  Created by Ray Sabbineni on 11/2/15.
//  Copyright © 2015 Ray Sabbineni. All rights reserved.
//

#import "ViewController4.h"

@interface ViewController4 ()

@end

@implementation ViewController4

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView * newImage = [[UIImageView alloc]init];
    
    
    newImage.image = self.newimage2;
    newImage.transform = CGAffineTransformMakeRotation(M_PI_2);
    newImage.frame = self.view.frame;
    
    [self.view addSubview:newImage];
  //  self.newimage.contentMode = UIViewContentModeScaleAspectFill;
  //  self.newimage.frame = self.view.frame;
    //NSLog(@"%@", self.newimage.image);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
