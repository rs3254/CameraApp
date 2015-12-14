//
//  AppleView.m
//  Camera
//
//  Created by Ray Sabbineni on 10/22/15.
//  Copyright © 2015 Ray Sabbineni. All rights reserved.
//

#import "AppleView.h"


@implementation AppleView






+(Class)layerClass {
    
    return [AVCaptureVideoPreviewLayer class];
}



-(AVCaptureSession*)session{
    AVCaptureVideoPreviewLayer * previewLayer = (AVCaptureVideoPreviewLayer*)self.layer;
    
    return previewLayer.session;
    
}

-(void)setSession:(AVCaptureSession *)session
{
    AVCaptureVideoPreviewLayer * previewLayer = (AVCaptureVideoPreviewLayer*)self.layer;
    previewLayer.session = session; 
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
