//
//  MVPostViewController.m
//  VK Likes and Followers
//
//  Created by whoami on 7/14/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVPostViewController.h"
#import "MVPostTableViewCell.h"
#import "MVPost.h"
#import "MVPresentPostViewController.h"

#import <VKSdk.h>
#import <UIImageView+WebCache.h>
#import <SVProgressHUD.h>

@interface MVPostViewController ()
@property (weak, nonatomic) IBOutlet UITableView *postTableView;
@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@end

@implementation MVPostViewController


#pragma mark - Post Table View Delegate Implementation -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count > 0 ? self.posts.count : 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TVCell";
    
    MVPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.postImage.layer.borderWidth = 0.3;
    
    if (self.posts.count == 0) {
        return cell;
    }
    
    if (self.posts[indexPath.row][@"copy_history"]) {
        NSURL *url = self.posts[indexPath.row][@"copy_history"][0][@"attachments"][0][@"photo"][@"photo_604"];
        [cell.postImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"dog"]];
        cell.postLabel.text = self.posts[indexPath.row][@"copy_history"][0][@"text"];
        cell.currencyAmount.text = [NSString stringWithFormat:@"%@", self.posts[indexPath.row][@"likes"][@"count"]];
    } else {
        NSURL *url = self.posts[indexPath.row][@"attachments"][0][@"photo"][@"photo_604"];
        [cell.postImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"dog"]];
        cell.postLabel.text = self.posts[indexPath.row][@"text"];
        cell.currencyAmount.text = [NSString stringWithFormat:@"%@", self.posts[indexPath.row][@"likes"][@"count"]];
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


#pragma mark - Transitions -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"DetailSegue"]) {
        MVPresentPostViewController *vc = (MVPresentPostViewController *)segue.destinationViewController;
        vc.image = [(MVPostTableViewCell *)[self.postTableView cellForRowAtIndexPath:self.selectedIndexPath] postImage].image;
        vc.postLabelText = [(MVPostTableViewCell *)[self.postTableView cellForRowAtIndexPath:self.selectedIndexPath] postLabel].text;
        vc.currenctAmountText = [(MVPostTableViewCell *)[self.postTableView cellForRowAtIndexPath:self.selectedIndexPath] currencyAmount].text;
        vc.VKPostID = [NSString stringWithFormat:@"ld%@_%@", self.posts[self.selectedIndexPath.row][@"from_id"],
                       self.posts[self.selectedIndexPath.row][@"id"]];
        vc.title = @"Заказать лайки";
        vc.isLikeVC = YES;
    }
}


#pragma mark - VK Interaction -

- (void)initUserVKData {
    VKRequest *wallRequest = [VKRequest requestWithMethod:@"wall.get" parameters:nil];
    [wallRequest executeWithResultBlock:^(VKResponse *response) {
        self.posts = response.json[@"items"];
        [self.postTableView reloadData];
    } errorBlock:^(NSError *error) {
        
    }];
}


#pragma mark - View Controller methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.postTableView.delegate = self;
    self.postTableView.dataSource = self;
    
    [SVProgressHUD show];
    [SVProgressHUD dismissWithDelay:0.2];
    
    [self initUserVKData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
