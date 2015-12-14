//
//  CaptureViewController.m
//  Camera
//
//  Created by Ray Sabbineni on 10/22/15.
//  Copyright © 2015 Ray Sabbineni. All rights reserved.
//

#import "CaptureViewController.h"


static void * SessionRunningContext = &SessionRunningContext;
static void * captureStillImageContext = &captureStillImageContext;

CMSampleBufferRef imageDataSampleBuffer;
NSString * idString;



@interface CaptureViewController ()

@end

@implementation CaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.session = [[AVCaptureSession alloc]init];
    
    self.previewView.session = self.session;
    
    self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    
    self.setupResult = AVCamSetupResultSuccess;
    
    
    dispatch_async(self.sessionQueue, ^{
        if(self.setupResult != AVCamSetupResultSuccess)
        {
            return ;
        }
        NSError * error = nil;
        AVCaptureDevice *device = [CaptureViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack ];
        
        AVCaptureDeviceInput * videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        
        if ( ! videoDeviceInput ) {
            NSLog( @"Could not create video device input: %@", error );
        }
        
        [self.session beginConfiguration];
        if([self.session canAddInput:videoDeviceInput])
        {
            [self.session addInput:videoDeviceInput];
            self.deviceInput = videoDeviceInput;
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
                
                AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
                
                
                if(statusBarOrientation != UIInterfaceOrientationUnknown )
                {
                    initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
                }
                
                AVCaptureVideoPreviewLayer * previewLayer = (AVCaptureVideoPreviewLayer*)self.previewView.layer;
                previewLayer.frame = self.view.bounds;
                previewLayer.connection.videoOrientation = initialVideoOrientation;
            } );
        }
        else {
            NSLog( @"Could not add video device input to the session" );
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        
        AVCaptureDevice * audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput * audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if ( ! audioDeviceInput ) {
            NSLog( @"Could not create audio device input: %@", error );
        }
        
        if([self.session canAddInput:audioDeviceInput])
        {
            [self.session addInput:audioDeviceInput];
        }
        else {
            NSLog( @"Could not add audio device input to the session" );
        }
        AVCaptureMovieFileOutput * movieFileOutput = [[AVCaptureMovieFileOutput alloc]init];
        
        if([self.session canAddOutput:movieFileOutput])
        {
            [self.session addOutput:movieFileOutput];
            AVCaptureConnection * connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if(connection.isVideoStabilizationSupported )
            {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
            self.moviefileOutput = movieFileOutput;
        }
        else {
            NSLog( @"Could not add movie file output to the session" );
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        
        AVCaptureStillImageOutput * stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
        
        if([self.session canAddOutput:stillImageOutput])
        {
            stillImageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
            
            [self.session addOutput:stillImageOutput];
            self.stillImageOutput = stillImageOutput;
        }
        else {
            NSLog( @"Could not add still image output to the session" );
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        [self.session commitConfiguration];
        
    } );
    
    self.recordButton = [[UIButton alloc]initWithFrame:CGRectMake(self.previewView.frame.size.width/20-20, self.previewView.frame.size.height, 80, 80)];
    [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
    
    [self.recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.recordButton addTarget:self action:@selector(RecordPhoto:) forControlEvents:UIControlEventTouchUpInside];
    self.recordButton.selected = NO;
    [self.view addSubview:self.recordButton];
    
    self.takePhoto = [[UIButton alloc]initWithFrame:CGRectMake(self.previewView.frame.size.width/10 +50, self.previewView.frame.size.height, 80, 80)];
    [self.takePhoto setTitle:@"Photo" forState:UIControlStateNormal];
    [self.takePhoto setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.takePhoto addTarget:self action:@selector(PhotoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.takePhoto];
    
    self.switchCamera = [[UIButton alloc]initWithFrame:CGRectMake(self.previewView.frame.size.width/10+150, self.previewView.frame.size.height, 140, 80)];
    
    [self.switchCamera addTarget:self action:@selector(SwitchCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.switchCamera setTitle:@"Switch Camera" forState:UIControlStateNormal];
    [self.switchCamera setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:self.switchCamera];
    
    self.savedPicturesButton = [[UIButton alloc]initWithFrame:CGRectMake(self.previewView.frame.size.width/20-20, self.previewView.frame.size.height/15, 120, 80)];
    [self.savedPicturesButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.savedPicturesButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.savedPicturesButton setTitle:@"Saved Images" forState:UIControlStateNormal];
    [self.view addSubview:self.savedPicturesButton];
    
    
    self.savedVideosButton = [[UIButton alloc]initWithFrame:CGRectMake(self.previewView.frame.size.width/2.5, self.previewView.frame.size.height/15, 120, 80)];
    [self.savedVideosButton addTarget:self action:@selector(buttonClicked2:) forControlEvents:UIControlEventTouchUpInside];
    [self.savedVideosButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.savedVideosButton setTitle:@"Saved Videos" forState:UIControlStateNormal];
    [self.view addSubview:self.savedVideosButton];
    
    
    
    
    
    
}

-(void)buttonClicked:(UIButton*)sender
{
    SavedImagesController * controller =[[SavedImagesController alloc]initWithNibName:@"SavedImagesController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}


-(void)buttonClicked2:(UIButton*)sender {
    
    VideosCollectionController * controller = [[VideosCollectionController alloc]initWithNibName:@"VideosCollectionController" bundle:nil];

    [self.navigationController pushViewController:controller animated:YES];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    dispatch_async(self.sessionQueue, ^{
        switch(self.setupResult)
        {
            case AVCamSetupResultSuccess:
            {
                [self addObservers];
                [self.session startRunning];
                self.sessionRunning = self.session.isRunning;
                break;
            }
            case AVCamSetupResultSessionConfigurationFailed:
            {
                break;
            }
        }
    });
    
}


-(void)viewDidDisappear:(BOOL)animated  {
    dispatch_async(self.sessionQueue, ^{
        if(self.setupResult == AVCamSetupResultSuccess) {
            
            [self.session stopRunning];
            [self removeObservers];
            
            
        }
    });
    
    [super viewDidDisappear:animated];
}


-(BOOL)shouldAutorotate
{
    
    return ! self.moviefileOutput.isRecording;
}


-(UIInterfaceOrientationMask)supportedInterfaceOrientations

{
    return UIInterfaceOrientationMaskAll;
    
}



-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator: (id<UIViewControllerTransitionCoordinator>) coordinator {
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator ];
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if(UIDeviceOrientationIsPortrait(deviceOrientation)  ||UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        AVCaptureVideoPreviewLayer * previewLayer = (AVCaptureVideoPreviewLayer*)self.previewView.layer;
        previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
        
    }
    
    
}


-(void)addObservers {
    
    [self.session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:SessionRunningContext];
    
    [self.stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:captureStillImageContext];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(subjectAreaDidChange:) name: AVCaptureDeviceSubjectAreaDidChangeNotification object:self.deviceInput];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:self.session ];
    
    
    [[NSNotificationCenter defaultCenter]addObserver: self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:self.session ];
    
    
    [[NSNotificationCenter defaultCenter]addObserver: self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:self.session];
    
    
}

-(void)removeObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [self.session removeObserver:self forKeyPath:@"running" context:SessionRunningContext];
    [self.stillImageOutput removeObserver:self forKeyPath:@"capturingStillImage" context:captureStillImageContext ];
    
}


-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    
    if(context == captureStillImageContext)
    {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey]boolValue];
        
        if(isCapturingStillImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.previewView.layer.opacity = 0.0;
                
                [UIView animateWithDuration:.25 animations: ^{
                    
                    self.previewView.layer.opacity = 1.0;
                }];
            });
            
        }
    }
    else if (context == SessionRunningContext)
    {
        bool isSessionRunning = [change [NSKeyValueChangeNewKey]boolValue];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.cameraButton.enabled = isSessionRunning && ( [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1 );
            self.recordButton.enabled = isSessionRunning;
            self.takePhoto.enabled = isSessionRunning;
            
        });
    }
    else {
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context ];
    }
    
}


-(void)subjectAreaDidChange:(NSNotification*)notification {
    
    
    CGPoint devicePoint = CGPointMake(.5, .5);
    
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
    
    //    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode: AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
    
}


-(void)sessionRuntimeError: (NSNotification*)notification {
    NSError * error = notification.userInfo[AVCaptureSessionErrorKey] ;
    
    NSLog( @"Capture session runtime error: %@", error );
    
    //    if ( error.code == AVErrorMediaServicesWereReset ) {
    //        dispatch_async( self.sessionQueue, ^{
    //            if ( self.isSessionRunning ) {
    //                [self.session startRunning];
    //                self.sessionRunning = self.session.isRunning;
    //            }
    //            else {
    //                dispatch_async( dispatch_get_main_queue(), ^{
    //                    self.resumeButton.hidden = NO;
    //                } );
    //            }
    //        } );
    //    }
    //    else {
    //        self.resumeButton.hidden = NO;
    //    }
    
    if(error.code == AVErrorMediaServicesWereReset)
    {
        dispatch_async(self.sessionQueue, ^{
            if(self.isSessionRunning)
            {
                [self.session startRunning];
                self.sessionRunning = self.session.isRunning;
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //self.resumeButton.hidden = NO;
                    
                });
            }
        });
    }
    else {
        //self.resumeButton.hidden = NO;
    }
    
    
}


-(void)sessionWasInterrupted:(NSNotification*)notification {
    
    
    
}

-(void)sessionInterruptionEnded:(NSNotification*)notification {
    
    
    
}

-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    
    
}

-(void)PhotoButtonPressed:(UIButton*)sender  {
    
    
    dispatch_async(self.sessionQueue, ^{
        
        AVCaptureConnection * connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        
        AVCaptureVideoPreviewLayer * previewLayer = (AVCaptureVideoPreviewLayer*)self.previewView.layer;
        
        
        connection.videoOrientation = previewLayer.connection.videoOrientation;
        
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
         {
             if(imageDataSampleBuffer)
             {
                 NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                 UIImageView * imageView = [[UIImageView alloc]init];
                 imageView.image = [UIImage imageWithData:imageData];
                 [self saveImage:imageView.image];
                 // self.ImageView.image =  [self loadImage];
                 
                 ([PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                     //  NSLog(@"data %@", imageData);
                     
                     if(status == PHAuthorizationStatusAuthorized) {
                         
                         if([PHAssetCreationRequest class])
                         {
                             
                             [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{[[PHAssetCreationRequest creationRequestForAsset]addResourceWithType:PHAssetResourceTypePhoto data:imageData options:nil];
                             }completionHandler:^(BOOL success, NSError *error) {
                                 if(!success)
                                 {
                                     NSLog(@"Error occurred while saving image to library: %@", error);
                                 }
                             }];
                         }
                         else {
                             
                             NSString * temporaryFileName = [NSProcessInfo processInfo].globallyUniqueString;
                             NSString * temporaryFilePath = [NSTemporaryDirectory()stringByAppendingPathComponent:[temporaryFileName stringByAppendingPathExtension:@"jpg"]];
                             NSURL * temporaryFileURL = [NSURL fileURLWithPath:temporaryFilePath];
                             [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
                                 NSError * error = nil;
                                 [imageData writeToURL:temporaryFileURL options:NSDataWritingAtomic error:&error];
                                 if(error )
                                 {
                                     NSLog(@"Error occured while writing image data to a temporary file: %@", error);
                                 }
                                 else
                                 {
                                     [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:temporaryFileURL];
                                 }
                             } completionHandler:^(BOOL success, NSError * error) {
                                 
                                 
                                 if(!success)
                                 {
                                     NSLog(@"Error occurred while saving image to photo library: %@", error );
                                 }
                                 [[NSFileManager defaultManager]removeItemAtURL:temporaryFileURL error:nil];
                                 
                             }];
                         }
                     }
                 }] );
             }
             else {
                 NSLog( @"Could not capture still image: %@", error );
                 
             }
         }];
    });
}



-(void)SwitchCamera:(UIButton*)sender {
    
    dispatch_async(self.sessionQueue,^{
        AVCaptureDevice * VideoDevice = self.deviceInput.device;
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = VideoDevice.position;
        
        switch( currentPosition)
        {
            case AVCaptureDevicePositionUnspecified:
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
        }
        AVCaptureDevice * currentDevice = [CaptureViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        
        AVCaptureDeviceInput * DeviceInput = [ AVCaptureDeviceInput deviceInputWithDevice:currentDevice error:nil];
        
        [self.session beginConfiguration];
        [self.session removeInput:self.deviceInput];
        
        if([self.session canAddInput:DeviceInput])
        {
            [[NSNotificationCenter defaultCenter]removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:VideoDevice];
            
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentDevice];
            [self.session addInput:DeviceInput];
            self.deviceInput = DeviceInput;
        }
        else{
            [self.session addInput:self.deviceInput];
        }
        AVCaptureConnection * connection = [self.moviefileOutput connectionWithMediaType:AVMediaTypeVideo];
        
        if(connection.isVideoStabilizationSupported)
        {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
        [self.session commitConfiguration];
    });
}




-(void)RecordPhoto:(UIButton*)sender {
    // self.Record.selected = YES;
    // [self.Record setTitle:@"Stop" forState:UIControlStateSelected];
    dispatch_async(self.sessionQueue, ^{
        
        if(! self.moviefileOutput.isRecording )
        {
            NSLog(@"Record Starts");
            dispatch_async(dispatch_get_main_queue(), ^{
                //       self.Record.enabled = YES;
                [self.recordButton setTitle:@"Stop" forState:UIControlStateNormal];
            });
            
            if([UIDevice currentDevice].isMultitaskingSupported)
            {
                self.backgroundRecordingID  =[[UIApplication sharedApplication]beginBackgroundTaskWithExpirationHandler:nil];
            }
            
            AVCaptureConnection * connection = [self.moviefileOutput connectionWithMediaType:AVMediaTypeVideo];
            AVCaptureVideoPreviewLayer * previewLayer = (AVCaptureVideoPreviewLayer*)self.previewView.layer;
            connection.videoOrientation = previewLayer.connection.videoOrientation;
            
            NSString * outputFileName = [NSProcessInfo processInfo].globallyUniqueString;
            NSString * outPutFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"mov"]];
            
            
            
            [self.moviefileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:outPutFilePath] recordingDelegate:self];
        }
        else {
            
            NSLog(@"Record Stops");
            [self.moviefileOutput stopRecording];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
            });
            
            
        }
    });
}


-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    UIBackgroundTaskIdentifier currentBackgroundRecordingID = self.backgroundRecordingID;
    self.backgroundRecordingID = UIBackgroundTaskInvalid;
    
    dispatch_block_t cleanup = ^ {
        [[NSFileManager defaultManager]removeItemAtURL:outputFileURL error:nil];
        
        if(currentBackgroundRecordingID != UIBackgroundTaskInvalid ) {
            [[UIApplication sharedApplication]endBackgroundTask:currentBackgroundRecordingID];
        }
    };
    BOOL success = YES;
    if(error)
    {
        NSLog( @"Movie file finishing error: %@", error );
        success = [error.userInfo[AVErrorRecordingSuccessfullyFinishedKey]boolValue];
    }
    if(success)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if(status == PHAuthorizationStatusAuthorized)
            {
                [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
                    
                    if([PHAssetResourceCreationOptions class])
                    {
                        PHAssetResourceCreationOptions * options = [[PHAssetResourceCreationOptions alloc]init];
                        options.shouldMoveFile = YES;
                        PHAssetCreationRequest * request = [PHAssetCreationRequest creationRequestForAsset];
                        self.urlForRecording = outputFileURL;
                        [request addResourceWithType:PHAssetResourceTypeVideo fileURL:outputFileURL options:options];
                        
                        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        
                        
                        NSString * documentsDirectory = [paths objectAtIndex:0];
                        
                        NSTimeInterval timeStamp2 = [[NSDate date] timeIntervalSince1970];
                        
                        NSString * toPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%f.mov", timeStamp2]];
                        NSError *error = nil;
                        
                        
                        NSString *fromPath = [outputFileURL relativePath];
                        
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        
                        NSLog(@"error: %@", [error localizedDescription]);
                        NSError *copyItemError;
                        
                        
                        [fileManager copyItemAtPath:fromPath toPath:toPath error:&copyItemError];
                        
                        if (copyItemError)
                        {
                            NSLog(@"%@", [copyItemError localizedDescription]);
                        }
                    } else{
                        
                        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputFileURL];
                    }
                } completionHandler: ^(BOOL success, NSError * error) {
                     if(!success)
                     {
                         NSLog( @"Could not save movie to photo library: %@", error );
                     }
                     cleanup();
                 }];
            } else {
                cleanup();
            }
        }];
    } else {
        cleanup();
    }
    
    dispatch_async(self.sessionQueue, ^{
        self.takePhoto.enabled = ([AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1);
    });
}



-(void)saveImage:(UIImage*)image {
    
    if(image != nil)
    {
        //Getting the documents directory path
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentObject = [paths objectAtIndex:0];
        
        // Creating time stamp and appending it to idString
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        idString = [NSString stringWithFormat:@"%f%@",timeStamp, @".png"];
        
        // Writing image to path
        NSString * path = [documentObject stringByAppendingPathComponent:idString];
        NSData * data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
    }
    
}




-(UIImage*)loadImage
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsObj = [paths objectAtIndex:0];
    NSString * path = [ documentsObj stringByAppendingPathComponent:idString];
    
    UIImage * image = [UIImage imageWithContentsOfFile:path];
    return image;
}



-(void)SaveRecording {
    
}

+(AVCaptureDevice*)deviceWithMediaType:(NSString*)mediaType preferringPosition:(AVCaptureDevicePosition)position {
    
    NSArray * DevicesArray = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice * captureDevices = DevicesArray.firstObject;
    for(AVCaptureDevice * deviceThing in DevicesArray )
    {
        if(deviceThing.position == position)
        {
            captureDevices = deviceThing;
            break;
        }
    }
    return captureDevices;
}


@end
