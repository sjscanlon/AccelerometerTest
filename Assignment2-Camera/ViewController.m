//
//  ViewController.m
//  Assignment2-Camera
//
//  Copyright (c) 2015 CMPE161. All rights reserved.
//

#import "ViewController.h"

/*
    Information:
        Frameworks added:
        AVFoundation Framework --> AVCaptureDevice
 */
@interface ViewController ()
@end

@implementation ViewController


CGPoint location;
CGPoint lineLocationOne;
CGPoint lineLocationTwo;
CGRect rect;
int counter = 0;
int shakeIt = 0;
int createCircle = 0;
int createLine = 0;
BOOL itsHappening = false;
BOOL locOneStored = false;
//CGPoint oldLocation;
//int x = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Initialize other variables here
    _displayCircles = false;
    _displayLines = false;
    
    //Initialize AVCaptureDevice
    [self initCapture];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initCapture {
    
    AVCaptureDevice     *theDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput
                                          deviceInputWithDevice:theDevice
                                          error:nil];
    /*We setupt the output*/
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    /*While a frame is processes in -captureOutput:didOutputSampleBuffer:fromConnection: delegate methods no other frames are added in the queue.
     If you don't want this behaviour set the property to NO */
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    //We create a serial queue to handle the processing of our frames
    dispatch_queue_t queue;
    queue = dispatch_queue_create("cameraQueue", NULL);
    [captureOutput setSampleBufferDelegate:self queue:queue];
    
    // Set the video output to store frame in YpCbCr planar so we can access the brightness in contiguios memory
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    // choice is kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange or RGBA
    
    NSNumber* value = [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] ;
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    
    //And we create a capture session
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    //We add input and output
    [self.captureSession addInput:captureInput];
    [self.captureSession addOutput:captureOutput];
    
    //Initialize and add imageview
    self.imageView = [[UIImageView alloc] init];
    self.imageView.frame = CGRectMake(0, 0, 320,450);//You need to change to the correct size
    
    //Add subviews to master view
    //The order is important in order to view the button
    [self.view addSubview:self.imageView];
    [self.view addSubview:_displayCirclesButton];
    
    //Once startRunning is called the camera will start capturing frames
    [self.captureSession startRunning];
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    /*Lock the image buffer*/
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    // Get the pixel buffer width and height
    self.width = CVPixelBufferGetWidth(imageBuffer);
    self.height = CVPixelBufferGetHeight(imageBuffer);
    
    //See the values of the image buffer
    //NSLog(@"Self width: %zu",self.width);
    //NSLog(@"Self height: %zu",self.height);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, self.width, self.height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    
    //Here is where you draw other 2D objects
    //Draw a circle if allowed
        
    [self touchesBegan:_touches withEvent:_event];
    if ( createCircle == 1) {
        [self drawCircle:context theLocation:location];
    }
    if ( createLine == 1 ) {
//        UIBezierPath *path = [UIBezierPath bezierPath];
//        [path moveToPoint:CGPointMake(lineLocationOne.x, lineLocationOne.y)];
//        [path addLineToPoint:CGPointMake(lineLocationTwo.x, lineLocationTwo.y)];
//        
//        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
//        shapeLayer.path = [path CGPath];
//        shapeLayer.strokeColor = [[UIColor blueColor] CGColor];
//        shapeLayer.lineWidth = 3.0;
//        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
//        shapeLayer.shouldRasterize = NO;
//        [self.view.layer addSublayer:shapeLayer];
//        //shapeLayer.shouldRasterize = NO;
//        createLine = 0;
        [self drawRect:context];
        

    }
    
        //Draw a circle in the middle of the screen
//        CGPoint location;
//        location.x = 220; location.y = 160;
//        [self drawCircle:context theLocation:location];
//        
//        location.x = 240; location.y = 160;
//        [self drawCircle:context theLocation:location];
//        
//        location.x = 260; location.y = 160;
//        [self drawCircle:context theLocation:location];
    
    
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    // UIImage *image = [UIImage imageWithCGImage:quartzImage];
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:(CGFloat)1 orientation:UIImageOrientationRight];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    //notice we use this selector to call our setter method 'setImg' Since only the main thread can update this
    [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
    
    //shaking stuff
    if ( shakeIt == 1 ) {
        _displayCircles = false;
        _displayLines = false;
    }
    [self motionEnded:_subtype withEvent:_event];
    if ( itsHappening == true) {
        [self viewDidAppear:itsHappening];
        shakeIt = 0;
    }
}


-(void)drawCircle:(CGContextRef)context theLocation:(CGPoint)location {
    
    //                  CGRectMake(x-origin, y-origin, width, height)
    rect = CGRectMake(location.y, location.x, 40.0, 40.0);
    CGContextSetRGBStrokeColor(context, 0.863, 0.078, 0.235, 1.0);
    CGContextSetRGBFillColor(context, 0.863, 0.078, 0.235, 0.5);
    CGContextSetLineWidth(context, 0.5);
    CGContextFillEllipseInRect (context, rect);
    createCircle = 0;
}

- (void)drawRect:(CGContextRef)context {
    
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 2.0f);
    
    CGContextMoveToPoint(context, lineLocationOne.y, lineLocationOne.x); //start at this point
    
    CGContextAddLineToPoint(context, lineLocationTwo.y, lineLocationTwo.x); //draw to this point
    
    // and now draw the Path!
    CGContextStrokePath(context);
}

//-(void)drawRect {
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path moveToPoint:CGPointMake(lineLocationOne.x, lineLocationOne.y)];
//    [path addLineToPoint:CGPointMake(lineLocationTwo.x, lineLocationTwo.y)];
//    
//    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
//    shapeLayer.path = [path CGPath];
//    shapeLayer.strokeColor = [[UIColor blueColor] CGColor];
//    shapeLayer.lineWidth = 3.0;
//    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
//    
//    [self.view addSubview:self.imageView];
//    locOneStored = false;
//
//}

//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
//    CGContextSetLineWidth(context, 3.0);
//    CGContextMoveToPoint(context, lineLocationOne.x, lineLocationOne.y);
//    CGContextAddLineToPoint(context, lineLocationTwo.x, lineLocationTwo.y);
//    CGContextDrawPath(context, kCGPathStroke);
//    
//    [self.view addSubview:self.imageView];
//    
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSUInteger tapCount = [touch tapCount];
    //NSLog ( @"%d", counter );
    NSLog ( @"%d", createLine );
    if (_displayCircles) {
        if (tapCount == 1) {
            CGPoint locationTwo = [touch locationInView:touch.view];
            location = locationTwo;
            NSLog(@"location-%f,%f", location.x,location.y);
            tapCount = 0;
        }
    }
    if(_displayLines) {
        if ( tapCount == 1 ) {
            if ( counter == 0 ) {
                createLine = 0;
                CGPoint locationTwo = [touch locationInView:touch.view];
                lineLocationOne = locationTwo;
                NSLog(@"location-%f,%f", location.x,location.y);
                counter++;
            } else if ( counter == 1 ) {
                CGPoint locationTwo = [touch locationInView:touch.view];
                lineLocationTwo = locationTwo;
                NSLog(@"location-%f,%f", location.x,location.y);
                counter = 0;
                createLine++;
            }
        }
    }
    if (_displayCircles) {
        createCircle = 1;
    }
    
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];
    itsHappening = false;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake)
    {
        itsHappening = true;
        shakeIt = 1;
        _subtype = 0;
        createLine = 0;
    }
}

- (IBAction)displayCirclesAction:(id)sender {
    _displayCircles = !_displayCircles;
    _displayLines = false;
    createLine = 0;
}

- (IBAction)displayLinesAction: (id)sender {
    _displayLines = !_displayLines;
    _displayCircles = false;
}
@end
