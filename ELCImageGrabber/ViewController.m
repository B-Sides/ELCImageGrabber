//
//  ViewController.m
//  ELCImageGrabber
//
//  Created by Christopher Schepman on 10/12/11.
//  Copyright (c) 2011 ELC Technologies. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize imageCountLabel, imageCountSlider;
@synthesize spinner;
@synthesize mainImageView;
@synthesize goButton, stopButton;
@synthesize imageUrls;

int MAX_IMAGES = 10;
bool KEEP_DOWNLOADING = YES;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (IBAction)imageCountSliderValueChanged:(id)sender 
{
    MAX_IMAGES = (int)imageCountSlider.value;
    imageCountLabel.text = [NSString stringWithFormat:@"%d", MAX_IMAGES];
}

- (IBAction)cancelDownloads:(id)sender
{
    KEEP_DOWNLOADING = NO;
    [spinner stopAnimating];
    mainImageView.image = nil;
    imageCountSlider.enabled = YES;
    goButton.enabled = YES;
    stopButton.enabled = NO;
}

- (void)getImageUrls 
{
    NSMutableArray *urls = [NSMutableArray array];

    //google image api has an 8 page max, with 8 images per page, so 64 image max per search term
    int urls_grabbed = 0;
    for (int i = 0; i < 8; i++) {
        if (urls_grabbed < MAX_IMAGES) {
            NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=cute+kitten&rsz=8&start=%d", i * 8]];
            NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL];
            
            id json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
            for (id result in [[json objectForKey:@"responseData"] objectForKey:@"results"]) {
                [urls addObject:[NSURL URLWithString:[result objectForKey:@"url"]]];
            }
            
            urls_grabbed++;
        }        
    }
    
    self.imageUrls = [NSArray arrayWithArray:urls];
}

- (void)downloadImages
{
    dispatch_queue_t image_queue = dispatch_queue_create("com.elctech.image_queue", NULL);

    int downloaded = 0;
    for (NSURL *url in self.imageUrls) {
        dispatch_async(image_queue, ^{
            if (KEEP_DOWNLOADING) {
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                UIImageWriteToSavedPhotosAlbum(image, self, nil, NULL);
                
                //back on the main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (KEEP_DOWNLOADING) {
                        mainImageView.image = image; 
                    }
                    
                    if (downloaded == MAX_IMAGES) {
                        [self cancelDownloads:nil];
                    }
                    
                });
            }
        });
        
        downloaded++;

    }
    
    dispatch_release(image_queue);
    
}

- (IBAction)grabImages:(id)sender
{
    KEEP_DOWNLOADING = YES;
    [spinner startAnimating];
    imageCountSlider.enabled = NO;
    goButton.enabled = NO;
    stopButton.enabled = YES;
    
    dispatch_queue_t urls_queue = dispatch_queue_create("com.elctech.image_queue", NULL);
    
    dispatch_async(urls_queue, ^{
        [self getImageUrls];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self downloadImages];
        });
    });
    
    
    dispatch_release(urls_queue);
}


@end
