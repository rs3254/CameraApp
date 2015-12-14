//
//  CaptureViewController.h
//  Camera
//
//  Created by Ray Sabbineni on 10/22/15.
//  Copyright © 2015 Ray Sabbineni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppleView.h"
#import "SavedImagesController.h"
#import "VideosCollectionController.h"

@import AVFoundation;
@import Photos;


@interface CaptureViewController : UIViewController <AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate>


typedef NS_ENUM(NSInteger,  AVCamSetupResult)
{
    
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
};




@property (strong, nonatomic) IBOutlet AppleView *previewView;


@property (nonatomic) AVCamSetupResult setupResult;
@property(nonatomic)dispatch_queue_t sessionQueue; 


@property(strong, nonatomic) NSURL * urlForRecording;
@property(nonatomic, strong)NSMutableArray * PictureArray1;


@property(nonatomic)AVCaptureSession * session;
@property(nonatomic)AVCaptureDeviceInput * deviceInput;
@property(nonatomic)AVCaptureMovieFileOutput * moviefileOutput;
@property(nonatomic)AVCaptureMovieFileOutput * moviefileOutputDocuments; 
@property(nonatomic)AVCaptureStillImageOutput * stillImageOutput;
@property (nonatomic, getter=isSessionRunning) BOOL sessionRunning;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;


@property(nonatomic, strong)UIButton * recordButton;
@property(nonatomic, strong)UIButton * takePhoto;
@property(nonatomic, strong)UIButton * switchCamera;
@property(nonatomic, strong)UIButton * savedPicturesButton;
@property(nonatomic, strong)UIButton * savedVideosButton;



-(UIImage*)loadImage;

@end

