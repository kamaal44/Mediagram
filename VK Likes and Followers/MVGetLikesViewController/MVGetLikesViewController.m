//
//  MVGetLikesViewController.m
//  VK Likes and Followers
//
//  Created by whoami on 7/8/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVGetLikesViewController.h"
#import "SWRevealViewController.h"
#import <HMSegmentedControl.h>

@interface MVGetLikesViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIView *photoContainer;
@property (weak, nonatomic) IBOutlet UIView *postContainer;
@property (weak, nonatomic) IBOutlet UIView *additionalView;

@property (strong, nonatomic) HMSegmentedControl *segmentedControl;
@end


@implementation MVGetLikesViewController


#pragma mark - Transitions -

- (IBAction)getCoinsButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"MoneySegue" sender:self];
}


#pragma mark - Segmented Control Configuration -

- (void)configureSegmentedControl {
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Фото", @"Посты"]];
    self.segmentedControl.borderWidth = 1;
    self.segmentedControl.borderType = HMSegmentedControlBorderTypeBottom | HMSegmentedControlBorderTypeLeft | HMSegmentedControlBorderTypeRight;
    self.segmentedControl.selectionIndicatorHeight = 1;
    self.segmentedControl.borderColor = [UIColor colorWithRed:78.0 / 255.0 green:118.0 / 255.0 blue:161.0 / 255.0 alpha:1];
    self.segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:78.0 / 255.0 green:118.0 / 255.0 blue:161.0 / 255.0 alpha:1.0];
    self.segmentedControl.selectionIndicatorBoxColor = [UIColor colorWithRed:78.0 / 255.0 green:118.0 / 255.0 blue:161.0 / 255.0 alpha:0.5];
    self.segmentedControl.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Regular" size:18]};
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    self.segmentedControl.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
    self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [self.segmentedControl addTarget:self action:@selector(segmentedControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    [self.additionalView addSubview:self.segmentedControl];
}

- (void)segmentedControlDidChangeValue: (HMSegmentedControl *)segmentedControl {
    if (segmentedControl.selectedSegmentIndex == 1) {
        [UIView animateWithDuration:0.5 animations:^{
            self.photoContainer.alpha = 1.0;
            self.postContainer.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.photoContainer.alpha = 0.0;
            self.postContainer.alpha = 1.0;
        }];
    }
}


#pragma mark - Reveal VC Configuration -

- (void)configureRevealVC {
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

#pragma mark - View Controller methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureRevealVC];
    [self configureSegmentedControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
