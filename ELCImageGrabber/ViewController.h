//
//  ViewController.h
//  ELCImageGrabber
//
//  Created by Christopher Schepman on 10/12/11.
//  Copyright (c) 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel *imageCountLabel;
@property (nonatomic, retain) IBOutlet UISlider *imageCountSlider;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UIImageView *mainImageView;

@property (nonatomic, retain) IBOutlet UIButton *goButton;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;

@property (nonatomic, retain) NSArray *imageUrls;

- (IBAction)imageCountSliderValueChanged:(id)sender;
- (IBAction)cancelDownloads:(id)sender;

@end
