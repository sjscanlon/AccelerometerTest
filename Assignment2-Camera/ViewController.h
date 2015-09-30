//
//  ViewController.h
//  Assignment2-Camera
//
//  Copyright (c) 2015 CMPE161. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface ViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

//Outlet and action for the button
@property (weak, nonatomic) IBOutlet UIButton *displayCirclesButton;
@property (weak, nonatomic) IBOutlet UIButton *displayLinesButton;

- (IBAction)displayCirclesAction:(id)sender;
- (IBAction)displayLinesAction: (id)sender;

@property (nonatomic) AVCaptureSession *captureSession;
@property UIImageView *imageView;
@property size_t height;
@property size_t width;
@property Boolean displayCircles;
@property Boolean displayLines;
@property NSSet *touches;
@property UIEvent *event;
@property(nonatomic, readonly) UIEventSubtype subtype;


@end

