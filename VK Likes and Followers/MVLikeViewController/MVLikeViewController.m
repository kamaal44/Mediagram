//
//  MVLikeViewController.m
//  VK Likes and Followers
//
//  Created by whoami on 7/8/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVLikeViewController.h"
#import "SWRevealViewController.h"

@interface MVLikeViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@end

@implementation MVLikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
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
