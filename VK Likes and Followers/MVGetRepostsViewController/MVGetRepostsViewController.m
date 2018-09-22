//
//  MVGetRepostsViewController.m
//  VK Likes and Followers
//
//  Created by whoami on 7/8/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVGetRepostsViewController.h"
#import "SWRevealViewController.h"
#import "MVPost.h"
#import "MVPostTableViewCell.h"
#import "MVPresentPostViewController.h"

#import <VKApi.h>
#import <UIImageView+WebCache.h>
#import <SVProgressHUD.h>

@interface MVGetRepostsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UITableView *postsTableView;

@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation MVGetRepostsViewController


#pragma mark - Transitions -

- (IBAction)getCoinsButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"MoneySegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"DetailSegue"]) {
        MVPresentPostViewController *vc = (MVPresentPostViewController *)segue.destinationViewController;
        vc.image = [(MVPostTableViewCell *)[self.postsTableView cellForRowAtIndexPath:self.selectedIndexPath] postImage].image;
        vc.postLabelText = [(MVPostTableViewCell *)[self.postsTableView cellForRowAtIndexPath:self.selectedIndexPath] postLabel].text;
        vc.currenctAmountText = [(MVPostTableViewCell *)[self.postsTableView cellForRowAtIndexPath:self.selectedIndexPath] currencyAmount].text;
        vc.VKPostID = [NSString stringWithFormat:@"rd%@_%@",
                       self.posts[self.selectedIndexPath.row][@"from_id"],
                       self.posts[self.selectedIndexPath.row][@"id"]];
    
        vc.title = @"Заказать репосты";
        vc.isLikeVC = NO;
    }
}


#pragma mark - Posts Table View Delegate Implementation -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count > 0 ? self.posts.count : 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GRCell";
    
    MVPostTableViewCell *cell = (MVPostTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.postImage.layer.borderWidth = 0.3;
    
    if (self.posts.count == 0) {
        return cell;
    }
    
    if (self.posts[indexPath.row][@"copy_history"]) {
        NSURL *url = self.posts[indexPath.row][@"copy_history"][0][@"attachments"][0][@"photo"][@"photo_604"];
        [cell.postImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"dog"]];
        cell.postLabel.text = self.posts[indexPath.row][@"copy_history"][0][@"text"];
        cell.currencyAmount.text = [NSString stringWithFormat:@"%@", self.posts[indexPath.row][@"reposts"][@"count"]];
    } else {
        NSURL *url = self.posts[indexPath.row][@"attachments"][0][@"photo"][@"photo_604"];
        [cell.postImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"dog"]];
        cell.postLabel.text = self.posts[indexPath.row][@"text"];
        cell.currencyAmount.text = [NSString stringWithFormat:@"%@", self.posts[indexPath.row][@"reposts"][@"count"]];
    }
    
    if ([cell.postLabel.text isEqualToString:@""]) {
        cell.postLabel.text = @"Этот пост не содержит текста.";
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"DetailSegue" sender:self];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = nil;
}


#pragma mark - VK Interaction -

- (void)initUserVKData {
    VKRequest *wallRequest = [VKRequest requestWithMethod:@"wall.get" parameters:nil];
    [wallRequest executeWithResultBlock:^(VKResponse *response) {
        self.posts = response.json[@"items"];
        [self.postsTableView reloadData];
    } errorBlock:^(NSError *error) {
        
    }];
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
    
    self.postsTableView.delegate = self;
    self.postsTableView.dataSource = self;
    
    [SVProgressHUD show];
    [SVProgressHUD dismissWithDelay:0.2];
    
    [self initUserVKData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
