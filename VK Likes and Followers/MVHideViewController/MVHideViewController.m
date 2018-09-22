//
//  MVHideViewController.m
//  VK Likes and Followers
//
//  Created by whoami on 8/8/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVHideViewController.h"
#import "MVHideTableViewCell.h"
#import "MVHidePost.h"

#import <VKSdk.h>
#import <VKApi.h>
#import <NYAlertViewController.h>
#import <Firebase.h>
#import <SafariServices/SafariServices.h>
#import <SVProgressHUD.h>

@interface MVHideViewController ()
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@property (weak, nonatomic) IBOutlet UIButton *moveButton;
@property (weak, nonatomic) IBOutlet UIButton *showButton;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;

@property (weak, nonatomic) IBOutlet UITextField *infoTextField;
@property (weak, nonatomic) IBOutlet UITextField *contributionTextField;

@property (weak, nonatomic) IBOutlet UITableView *friendTableView;

@property (strong, nonatomic) NSString *initialUserCoins;

@property (strong, nonatomic) VKUsersArray *friends;

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (strong, nonatomic) NSString *balance;

@property (nonatomic) NSInteger likes;
@property (nonatomic) NSInteger reposts;

@end

@implementation MVHideViewController

#pragma mark - Friend Table View Delegate Implementation -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friends.count > 0 ? self.friends.count : 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FriendCell";
    
    MVHideTableViewCell *cell = (MVHideTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (self.friends.count > 0) {
        NSString *onlineStatus = [self.friends[indexPath.row].online isEqual: @1] ? @"online" : @"offline";
        
        cell.label.text = [NSString stringWithFormat:@"%@ %@ (%@)", self.friends[indexPath.row].first_name, self.friends[indexPath.row].last_name, onlineStatus];
        cell.VKUserID = [NSString stringWithFormat:@"id%@", self.friends[indexPath.row].id];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.friends.count == 0) {
        return;
    }
    
    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/%@", [(MVHideTableViewCell *)[self.friendTableView cellForRowAtIndexPath:indexPath] VKUserID]]]];
    svc.delegate = self;
    [self presentViewController:svc animated:YES completion:nil];
}

#pragma mark - Button's Appearance -

- (void)configureButtons {
    // 1. Setting the corner radius
    self.moveButton.layer.cornerRadius = 5.0;
    self.showButton.layer.cornerRadius = 5.0;
    self.updateButton.layer.cornerRadius = 5.0;
    
    // 2. Setting the border
    self.moveButton.layer.borderWidth = 1.0;
    self.showButton.layer.borderWidth = 1.0;
    self.updateButton.layer.borderWidth = 1.0;
    
    // 3. Setting the color
    self.moveButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.showButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.updateButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

#pragma mark - Info Button Actions -

- (IBAction)firstInfoButtonTapped:(UIButton *)sender {
    NYAlertViewController *alertViewController = [[NYAlertViewController alloc] init];
    
    // Set a title and message
    alertViewController.title = @"Инфо о странице";
    alertViewController.message = [NSString stringWithFormat:@"Перейти к указанной страничке ВК.\n Стоимость: бесплатно"];
    
    // Customize appearance as desired
    alertViewController.buttonCornerRadius = 20.0f;
    alertViewController.view.tintColor = self.view.tintColor;
    
    alertViewController.titleFont = [UIFont fontWithName:@"AvenirNext-Bold" size:19.0f];
    alertViewController.messageFont = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    alertViewController.buttonTitleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:alertViewController.buttonTitleFont.pointSize];
    alertViewController.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:alertViewController.cancelButtonTitleFont.pointSize];
    alertViewController.cancelButtonColor = [UIColor colorWithRed:78.0 / 255.0 green:118.0 / 255.0 blue:161.0 / 255.0 alpha:1];
    
    alertViewController.swipeDismissalGestureEnabled = YES;
    alertViewController.backgroundTapDismissalGestureEnabled = YES;
    
    // Add alert actions
    [alertViewController addAction:[NYAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(NYAlertAction *action) {
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                          }]];
    
    // Present the alert view controller
    [self presentViewController:alertViewController animated:YES completion:nil];
}

- (IBAction)secondInfoButtonTapped:(UIButton *)sender {
    NYAlertViewController *alertViewController = [[NYAlertViewController alloc] init];
    
    // Set a title and message
    alertViewController.title = @"Вклад пользователя";
    alertViewController.message = [NSString stringWithFormat:@"Получить информацию о действиях пользователя с данным id на странице пользователя, указанной выше.\n Стоимость: 50 монет"];
    
    // Customize appearance as desired
    alertViewController.buttonCornerRadius = 20.0f;
    alertViewController.view.tintColor = self.view.tintColor;
    
    alertViewController.titleFont = [UIFont fontWithName:@"AvenirNext-Bold" size:19.0f];
    alertViewController.messageFont = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    alertViewController.buttonTitleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:alertViewController.buttonTitleFont.pointSize];
    alertViewController.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:alertViewController.cancelButtonTitleFont.pointSize];
    alertViewController.cancelButtonColor = [UIColor colorWithRed:78.0 / 255.0 green:118.0 / 255.0 blue:161.0 / 255.0 alpha:1];
    
    alertViewController.swipeDismissalGestureEnabled = YES;
    alertViewController.backgroundTapDismissalGestureEnabled = YES;
    
    // Add alert actions
    [alertViewController addAction:[NYAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(NYAlertAction *action) {
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                          }]];
    
    // Present the alert view controller
    [self presentViewController:alertViewController animated:YES completion:nil];
}

- (IBAction)thirdInfoButtonTapped:(UIButton *)sender {
    NYAlertViewController *alertViewController = [[NYAlertViewController alloc] init];
    
    // Set a title and message
    alertViewController.title = @"Список друзей";
    alertViewController.message = [NSString stringWithFormat:@"Загрузить список текущих друзей.\n Стоимость: 100 монет"];
    
    // Customize appearance as desired
    alertViewController.buttonCornerRadius = 20.0f;
    alertViewController.view.tintColor = self.view.tintColor;
    
    alertViewController.titleFont = [UIFont fontWithName:@"AvenirNext-Bold" size:19.0f];
    alertViewController.messageFont = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    alertViewController.buttonTitleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:alertViewController.buttonTitleFont.pointSize];
    alertViewController.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:alertViewController.cancelButtonTitleFont.pointSize];
    alertViewController.cancelButtonColor = [UIColor colorWithRed:78.0 / 255.0 green:118.0 / 255.0 blue:161.0 / 255.0 alpha:1];
    
    alertViewController.swipeDismissalGestureEnabled = YES;
    alertViewController.backgroundTapDismissalGestureEnabled = YES;
    
    // Add alert actions
    [alertViewController addAction:[NYAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(NYAlertAction *action) {
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                          }]];
    
    // Present the alert view controller
    [self presentViewController:alertViewController animated:YES completion:nil];
}

#pragma mark - Main methods -

- (IBAction)move:(UIButton *)sender {
    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/%@", self.infoTextField.text]]];
    svc.delegate = self;
    [self presentViewController:svc animated:YES completion:nil];
}

- (IBAction)show:(UIButton *)sender {
    // 1. Update current balance
    NSInteger oldValue = [self.balance intValue];
    NSInteger delta = 50;
    
    // -1. Finish execution
    if (oldValue - delta < 0) {
        [self handleNotEnoughCoins];
        return;
    }
    
    NSString *newValue = [NSString stringWithFormat:@"%ld", oldValue - delta];
    [[[[self.ref child:@"users"] child:self.VKUserID] child:@"coins"] setValue:newValue];
    
    NSMutableArray<MVHidePost *> *posts = [[NSMutableArray alloc] init];
    NSString *userID;
    
    self.likes = 0;
    self.reposts = 0;
    
    if (self.infoTextField.text.length == 0) {
        userID = [NSString stringWithFormat:@"%@", [[VKSdk accessToken] userId]];
    } else {
        if ([[self.infoTextField.text substringToIndex:2] isEqualToString:@"id"]) {
            userID = [self.infoTextField.text substringFromIndex:2];
        } else {
            userID = self.infoTextField.text;
        }
    }
    
    VKRequest *request = [VKRequest requestWithMethod:@"wall.get" parameters:@{VK_API_USER_ID : userID, @"count" : @100}];
    
    [SVProgressHUD show];
    [request executeWithResultBlock:^(VKResponse *response) {
        for (int i = 0; i < [response.json[@"count"] intValue]; ++i) {
            MVHidePost *post = [[MVHidePost alloc] init];
            post.ownerID = [NSString stringWithFormat:@"%@", response.json[@"items"][i][@"owner_id"]];
            post.ID = [NSString stringWithFormat:@"%@", response.json[@"items"][i][@"id"]];
            [posts addObject: post];
        }
        
        NSString *infoUserID;
        if (self.contributionTextField.text.length == 0) {
            infoUserID = [NSString stringWithFormat:@"%@", [[VKSdk accessToken] userId]];
        } else {
            if ([[self.contributionTextField.text substringToIndex:2] isEqualToString:@"id"]) {
                infoUserID = [self.contributionTextField.text substringFromIndex:2];
            } else {
                infoUserID = self.contributionTextField.text;
            }
        }
        
        dispatch_group_t dispatch_group = dispatch_group_create();
        
        for (int i = 0; i < posts.count; ++i) {
            VKRequest *newRequest = [VKRequest requestWithMethod:@"likes.isLiked" parameters:@{VK_API_USER_ID : infoUserID, @"type" : @"post", @"item_id" : posts[i].ID, @"owner_id" : posts[i].ownerID}];
            
            dispatch_group_enter(dispatch_group);
            [newRequest executeWithResultBlock:^(VKResponse *response) {
                self.likes += [response.json[@"liked"] intValue];
                self.reposts += [response.json[@"copied"] intValue];
                dispatch_group_leave(dispatch_group);
            } errorBlock:^(NSError *error) {
                
            }];
        }
        
        dispatch_group_notify(dispatch_group, dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self showInfoAlert];
        });
        
    } errorBlock:^(NSError *error) {
        
    }];
}

- (void)showInfoAlert {
    NYAlertViewController *alertViewController = [[NYAlertViewController alloc] init];
    
    // Set a title and message
    alertViewController.title = @"Полученные результаты";
    alertViewController.message = [NSString stringWithFormat:@"Указанный пользователь совершил %ld лайков и %ld репостов на предоставленной странице", self.likes, self.reposts];
    
    // Customize appearance as desired
    alertViewController.buttonCornerRadius = 20.0f;
    alertViewController.view.tintColor = self.view.tintColor;
    
    alertViewController.titleFont = [UIFont fontWithName:@"AvenirNext-Bold" size:19.0f];
    alertViewController.messageFont = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    alertViewController.buttonTitleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:alertViewController.buttonTitleFont.pointSize];
    alertViewController.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:alertViewController.cancelButtonTitleFont.pointSize];
    alertViewController.cancelButtonColor = [UIColor colorWithRed:78.0 / 255.0 green:118.0 / 255.0 blue:161.0 / 255.0 alpha:1];
    
    alertViewController.swipeDismissalGestureEnabled = YES;
    alertViewController.backgroundTapDismissalGestureEnabled = YES;
    
    // Add alert actions
    [alertViewController addAction:[NYAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(NYAlertAction *action) {
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                          }]];
    
    // Present the alert view controller
    [self presentViewController:alertViewController animated:YES completion:nil];
}

- (IBAction)update:(UIButton *)sender {
    // 1. Update current balance
    NSInteger oldValue = [self.balance intValue];
    NSInteger delta = 100;
    
    // -1. Finish execution
    if (oldValue - delta < 0) {
        [self handleNotEnoughCoins];
        return;
    }
    
    NSString *newValue = [NSString stringWithFormat:@"%ld", oldValue - delta];
    [[[[self.ref child:@"users"] child:self.VKUserID] child:@"coins"] setValue:newValue];
    
    VKRequest *request = [VKRequest requestWithMethod:@"friends.get" parameters:@{@"order" : @"hints", @"fields" : @"domain"}];
    
    [SVProgressHUD show];
    [request executeWithResultBlock:^(VKResponse *response) {
        self.friends = [[VKUsersArray alloc] initWithDictionary:response.json];
        [self.friendTableView reloadData];
        [SVProgressHUD dismiss];
    } errorBlock:^(NSError *error) {
        
    }];
}

- (void)handleNotEnoughCoins {
    NYAlertViewController *alertVC = [[NYAlertViewController alloc] init];
    
    alertVC.title = @"Недостаточно монет!";
    alertVC.titleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:23.0];
    
    alertVC.message = @"Вам следует получить монеты, чтобы заказывать";
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

#pragma mark - DB Interaction  -

- (void)initDBData {
    self.ref = [[FIRDatabase database] reference];
    
    [[self.ref child:@"initial_user_coins"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.initialUserCoins = snapshot.value;
        [[[[self.ref child:@"users"] child:self.VKUserID] child:@"coins"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (![snapshot exists]) {
                FIRDatabaseReference *userRef = [[self.ref child:@"users"] child:self.VKUserID];
                [userRef setValue:@{@"coins" : self.initialUserCoins}];
            }
            [self registerUserCoins];
        } withCancelBlock:^(NSError * _Nonnull error) {
            NSLog(@"%@", error.localizedDescription);
        }];
    }];
    
}

- (void)registerUserCoins {
    [[[[self.ref child:@"users"] child:self.VKUserID] child:@"coins"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:@"black_coins"];
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        
        NSString *balanceString = [NSString stringWithFormat:@"Ваш баланс: %@ ", snapshot.value];
        self.balance = snapshot.value;
        NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] initWithString:balanceString];
        [myString appendAttributedString:attachmentString];
        
        self.balanceLabel.attributedText = myString;
    }];
}

#pragma mark - VK Interaction -

- (void)initVKData {
    self.VKUserID = [NSString stringWithFormat:@"id%@", [[VKSdk accessToken] userId]];
}

#pragma mark - Usability -

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Setting delegates -

- (void)setDelegates {
    self.friendTableView.delegate = self;
    self.friendTableView.dataSource = self;
    self.infoTextField.delegate = self;
    self.contributionTextField.delegate = self;
}

#pragma mark - Log out -

- (IBAction)logOut:(UIBarButtonItem *)sender {
    [VKSdk forceLogout];
    [self performSegueWithIdentifier:@"LogOutSegue" sender:self];
}

#pragma mark - Money -

- (IBAction)moveToPurchaseVC:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"MoneySegue" sender:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDelegates];
    [self configureButtons];
    
    [self initVKData];
    [self initDBData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
