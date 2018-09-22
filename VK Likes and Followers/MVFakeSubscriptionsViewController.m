//
//  MVFakeSubscriptionsViewController.m
//  VK Likes and Followers
//
//  Created by whoami on 9/4/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVFakeSubscriptionsViewController.h"
#import "SWRevealViewController.h"
#import "MVProfileTableViewCell.h"

#import <VKSdk.h>
#import <SdWebImage/UIImageView+WebCache.h>
#import <Firebase.h>
#import <SVProgressHUD.h>
#import <NYAlertViewController.h>


@interface MVFakeSubscriptionsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UITableView *subscriptionsTableView;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@property (strong, nonatomic) VKUsersArray *subscriptions;
@property (nonatomic, strong) NSString *coins;
@property (nonatomic, strong) FIRDatabaseReference *ref;

@end

@implementation MVFakeSubscriptionsViewController

#pragma mark - Transitions - 

- (IBAction)coinsButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"MoneySegue" sender:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subscriptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    MVProfileTableViewCell *cell = (MVProfileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.profileName.text = [NSString stringWithFormat:@"%@ %@", self.subscriptions[indexPath.row].first_name, self.subscriptions[indexPath.row].last_name];
    cell.status.text = self.subscriptions[indexPath.row].online.intValue > 0 ? @"(online)" : @"(offline)";
    cell.profilePhoto.layer.borderWidth = 1.0;
    cell.profilePhoto.layer.cornerRadius = cell.profilePhoto.bounds.size.height / 2;
    [cell.profilePhoto sd_setImageWithURL:[NSURL URLWithString:self.subscriptions[indexPath.row].photo_400_orig] placeholderImage:[UIImage imageNamed:@"dog"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NYAlertViewController *alertVC = [[NYAlertViewController alloc] init];
    
    alertVC.title = @"Просмотр профиля";
    alertVC.titleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:23.0];
    
    alertVC.message = @"Вы желаете потратить 50 монет на просмотр профиля в сети?";
    alertVC.messageFont = [UIFont fontWithName:@"AvenirNext-Regular" size:17.0];
    
    alertVC.cancelButtonColor = [UIColor colorWithRed:78.0 / 255.0 green:118.0 / 255.0 blue:161.0 / 255.0 alpha:1];
    
    
    NYAlertAction *okAction = [NYAlertAction actionWithTitle:@"ОК"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(NYAlertAction *action) {
                                                         NSInteger oldValue = [self.coins intValue];
                                                         NSInteger delta = 50;
                                                         
                                                         // -1. Finish execution
                                                         if (oldValue - delta < 0) {
                                                             [self dismissViewControllerAnimated:YES completion:^{
                                                                 [self handleNotEnoughCoins];
                                                             }];
                                                             return;
                                                         }
                                                         
                                                         NSString *newValue = [NSString stringWithFormat:@"%ld", oldValue - delta];
                                                         [[[[self.ref child:@"users"] child:self.VKUserID] child:@"coins"] setValue:newValue];
                                                         
                                                         [self dismissViewControllerAnimated:YES completion:^{
                                                             [self openSafariWebViewWithIndex:indexPath.row];
                                                         }];
                                                     }];
    
    NYAlertAction *cancelAction = [NYAlertAction actionWithTitle:@"Отмена"
                                                           style:UIAlertActionStyleCancel handler:^(NYAlertAction *action) {
                                                               [self dismissViewControllerAnimated:YES completion:nil];
                                                           }];
    
    [alertVC addAction:okAction];
    [alertVC addAction:cancelAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)handleNotEnoughCoins {
    NYAlertViewController *alertVC = [[NYAlertViewController alloc] init];
    
    alertVC.title = @"Недостаточно монет!";
    alertVC.titleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:23.0];
    
    alertVC.message = @"Вам следует получить монеты, чтобы перейти к нужному профилю.";
    alertVC.messageFont = [UIFont fontWithName:@"AvenirNext-Regular" size:17.0];
    
    alertVC.cancelButtonColor = [UIColor colorWithRed:78.0 / 255.0 green:118.0 / 255.0 blue:161.0 / 255.0 alpha:1];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 106, 128)];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:@"not_enough"];
    
    alertVC.alertViewContentView = imageView;
    
    NYAlertAction *okAction = [NYAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(NYAlertAction *action) {
                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                         [self performSegueWithIdentifier:@"MoneySegue" sender:self];
                                                     }];
    
    [alertVC addAction:okAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)openSafariWebViewWithIndex:(NSInteger)index {
    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/id%@", self.subscriptions[index].id]]];
    svc.delegate = self;
    [self presentViewController:svc animated:YES completion:nil];
}


- (void)configureRevealVC {
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)initVKData {
    self.VKUserID = [NSString stringWithFormat:@"id%@", [[VKSdk accessToken] userId]];
    VKRequest *request = [VKRequest requestWithMethod:@"friends.getRequests" parameters:@{@"out" : @1}];
    [SVProgressHUD show];
    
    [request executeWithResultBlock:^(VKResponse *response) {
        VKRequest *userRequest = [VKRequest requestWithMethod:@"users.get" parameters:@{@"user_ids" : response.json[@"items"], @"fields" : @[@"photo_400_orig", @"online"]}];
        
        dispatch_group_t dispatch_group = dispatch_group_create();
        
        dispatch_group_enter(dispatch_group);
        [userRequest executeWithResultBlock:^(VKResponse *response) {
            self.subscriptions = [[VKUsersArray alloc] initWithArray:response.json];
            [self.subscriptionsTableView reloadData];
            dispatch_group_leave(dispatch_group);
            
            
        } errorBlock:^(NSError *error) {
            
        }];
        
        dispatch_group_notify(dispatch_group, dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        
    } errorBlock:^(NSError *error) {
        
    }];
    
    
}

#pragma mark - DB Interaction -

- (void) initUserDBData {
    // 1. Initializing reference to database
    self.ref = [[FIRDatabase database] reference];
    
    // 2. Registering observer for balance label
    [[[[self.ref child:@"users"] child:self.VKUserID] child:@"coins"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:@"black_coins"];
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        
        NSString *balanceString = [NSString stringWithFormat:@"Ваш баланс: %@ ", snapshot.value];
        self.coins = snapshot.value;
        
        NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] initWithString:balanceString];
        
        [myString appendAttributedString:attachmentString];
        self.balanceLabel.attributedText = myString;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureRevealVC];
    
    self.subscriptionsTableView.delegate = self;
    self.subscriptionsTableView.dataSource = self;
    
    [self initVKData];
    [self initUserDBData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
