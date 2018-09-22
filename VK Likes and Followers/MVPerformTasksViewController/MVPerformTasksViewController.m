//
//  MVPerformTasksViewController.m
//  VK Likes and Followers
//
//  Created by whoami on 7/14/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVPerformTasksViewController.h"
#import "SWRevealViewController.h"

#import <Firebase.h>
#import <VKApi.h>
#import <SVProgressHUD.h>
#import "SdWebImage/UIImageView+WebCache.h"
#import <NYAlertViewController.h>

@interface MVPerformTasksViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;
@property (nonatomic) NSInteger index;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (weak, nonatomic) IBOutlet UILabel *taskInfo;
@property (strong, nonatomic) NSDictionary *taskDescription;
@property (strong, nonatomic) NSString *balance;
@property (strong, nonatomic) NSDictionary *actionDescription;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (strong, nonatomic) NSDictionary *tasksStorageMapping;

@end

@implementation MVPerformTasksViewController

#pragma mark - Captcha -

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)registerDelegate {
    VKSdk *sdkInstance = [VKSdk initializeWithAppId: @"6099784"];
    [sdkInstance setUiDelegate:self];
}

#pragma mark - Transitions -

- (IBAction)getCoinsButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"MoneySegue" sender:self];
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


#pragma mark - Task Photo Enhancement -

- (void)configureImageView {
    self.photo.layer.cornerRadius = 15.0;
    self.photo.layer.borderWidth = 2.0;
    self.photo.layer.borderColor = [UIColor whiteColor].CGColor;
    self.photo.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.photo.layer.shadowOffset = CGSizeMake(4, 4);
    self.photo.layer.shadowRadius = 5.0;
}

#pragma mark - Task Actions -

- (IBAction)actionButtonTapped:(UIButton *)sender {
    [SVProgressHUD show];
    [SVProgressHUD dismissWithDelay:0.3];
    
    [self sendVKRequest];
    [self updateData];
}

- (IBAction)skipButtonTapped:(UIButton *)sender {
    [SVProgressHUD show];
    [SVProgressHUD dismissWithDelay:0.2];
    [self handleNextTask];
}

- (void)sendVKRequest {
    if ([self.tasks[self.index].type isEqualToString:@"follower"]) {
        VKRequest *request = [VKRequest requestWithMethod:@"friends.add" parameters:@{@"user_id" : self.tasks[self.index].userID,
                                                                           @"follow" : @1
                                                                           }];
        
        [request executeWithResultBlock:^(VKResponse *response) {
            
        } errorBlock:^(NSError *error) {
            
        }];
    } else if ([self.tasks[self.index].type isEqualToString:@"photo_like"]) {
        VKRequest *request = [VKRequest requestWithMethod:@"likes.add" parameters:@{@"type" : @"photo",
                                                                                    @"owner_id" : self.tasks[self.index].userID,
                                                                                    @"item_id" : self.tasks[self.index].itemID
                                                                                    }];
        
        [request executeWithResultBlock:^(VKResponse *response) {
            
        } errorBlock:^(NSError *error) {
            
        }];
    } else if ([self.tasks[self.index].type isEqualToString:@"post_like"]) {
        VKRequest *request = [VKRequest requestWithMethod:@"likes.add" parameters:@{@"type" : @"post",
                                                                                    @"owner_id" : self.tasks[self.index].userID,
                                                                                    @"item_id" : self.tasks[self.index].itemID
                                                                                    }];
        
        [request executeWithResultBlock:^(VKResponse *response) {
            
        } errorBlock:^(NSError *error) {
            
        }];
    } else {
        NSString *objectID = [@"wall" stringByAppendingString:[self.tasks[self.index].fullID substringFromIndex:2]];
        VKRequest *request = [VKRequest requestWithMethod:@"wall.repost" parameters:@{@"object" : objectID}];
        
        [request executeWithResultBlock:^(VKResponse *response) {
            
        } errorBlock:^(NSError *error) {
            
        }];
    }
}

- (void)applyTask {
    NSString *formattedID = [NSString stringWithFormat:@"id%@", self.tasks[self.index].userID];
    
    if ([self.VKUserID isEqualToString:formattedID] ||
        self.tasks[self.index].alreadyCompleted) {
        [self handleNextTask];
    }
    
    [self.photo sd_setImageWithURL:[NSURL URLWithString:self.tasks[self.index].photoURL] placeholderImage:[UIImage imageNamed:@"dog"]];
    
    self.taskInfo.text = [NSString stringWithFormat:@"Задание: %@", self.taskDescription[self.tasks[self.index].type]];
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"black_coins"];
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSString *rewardString = [NSString stringWithFormat:@"Награда: +%@ ", self.reward[self.tasks[self.index].type]];
    
    NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] initWithString:rewardString];
    
    [myString appendAttributedString:attachmentString];
    self.gainLabel.attributedText = myString;
    
    [self.actionButton setTitle:self.actionDescription[self.tasks[self.index].type] forState:UIControlStateNormal];
}


#pragma mark - DB Interaction -
- (void)initDBData {
    self.ref = [[FIRDatabase database] reference];
    
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

- (void)updateData {
    NSInteger oldValue = [self.balance intValue];
    NSInteger delta = [self.reward[self.tasks[self.index].type] intValue];
    NSString *newValue = [NSString stringWithFormat:@"%ld", oldValue + delta];
    
    [[[[self.ref child:@"users"] child: self.VKUserID] child:@"coins"] setValue:newValue];
    
    [[[self.ref child:self.tasksStorageMapping[self.tasks[self.index].type]] child:self.tasks[self.index].fullID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSInteger oldValue = [(NSString *)[snapshot childSnapshotForPath:@"added"].value intValue];
        
        NSInteger purchased = [(NSString *)[snapshot childSnapshotForPath:@"purchased"].value intValue];
        
        NSString *newValue = [NSString stringWithFormat:@"%ld", oldValue + 1];
        [[[[self.ref child:self.tasksStorageMapping[self.tasks[self.index].type]] child:self.tasks[self.index].fullID] child:@"added"] setValue:newValue];
        
        if (oldValue + 1 == purchased) {
            [[[self.ref child:@"active_tasks"] child:self.tasks[self.index].fullID] removeValue];
        }
        
        [self handleNextTask];
    }];
}

- (void)handleNextTask {
    if (self.index + 1 == self.tasks.count) {
        NYAlertViewController *alertVC = [[NYAlertViewController alloc] init];
        
        alertVC.title = @"Время переключиться!";
        alertVC.titleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:20.0];
        
        alertVC.message = @"Отдохните или просто посмотрите видео";
        alertVC.messageFont = [UIFont fontWithName:@"AvenirNext-Regular" size:17.0];
        
        alertVC.cancelButtonColor = [UIColor colorWithRed:78.0 / 255.0 green:118.0 / 255.0 blue:161.0 / 255.0 alpha:1];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 106, 128)];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageNamed:@"limit"];
        
        alertVC.alertViewContentView = imageView;
        
        NYAlertAction *okAction = [NYAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(NYAlertAction *action) {
                                                             [self dismissViewControllerAnimated:YES completion:nil];
                                                             [self performSegueWithIdentifier:@"AdSegue" sender:self];
                                                         }];
        
        [alertVC addAction:okAction];
        [self presentViewController:alertVC animated:YES completion:nil];
        return;
    }
    
    self.index += 1;
    [self applyTask];
}


#pragma mark - Task Desctiption Configuration -

- (void)configureTaskDescription {
    self.taskDescription = [[NSDictionary alloc] initWithObjectsAndKeys:@"Подписка", @"follower",
                            @"Лайк", @"photo_like",
                            @"Лайк", @"post_like",
                            @"Репост", @"repost", nil];
}

#pragma mark - Action Description Configuration -

- (void)configureActionDescription {
    self.actionDescription = [[NSDictionary alloc] initWithObjectsAndKeys:@"Подписаться", @"follower",
                              @"Лайкнуть", @"photo_like",
                              @"Лайкнуть", @"post_like",
                              @"Поделиться", @"repost", nil];
}

#pragma mark - Task Storage Mapping Configuration -

- (void)configureTaskStorageMapping {
    self.tasksStorageMapping = [[NSDictionary alloc] initWithObjectsAndKeys:@"follower_tasks", @"follower",
                                @"photo_likes_tasks", @"photo_like",
                                @"post_likes_tasks", @"post_like",
                                @"repost_tasks", @"repost", nil];
}

#pragma mark - Button appearance -

- (void)configureButtons {
    self.skipButton.layer.cornerRadius = 5.0;
    self.actionButton.layer.cornerRadius = 5.0;
    
    self.skipButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.actionButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.skipButton.layer.borderWidth = 1.0;
    self.actionButton.layer.borderWidth = 1.0;
}

#pragma mark - Checking for tasks -

- (NSInteger)checkIfTasksExist {
    if (self.tasks.count == 0) {
        [self showNoTasksAlert];
        return 0;
    }
    return 1;
}

- (void)showNoTasksAlert {
    NYAlertViewController *alertVC = [[NYAlertViewController alloc] init];
    
    alertVC.title = @"В данный момент нет задач!";
    alertVC.titleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:20.0];
    
    alertVC.message = @"Но вы всегда можете посмотреть видео, чтобы заработать монет!";
    alertVC.messageFont = [UIFont fontWithName:@"AvenirNext-Regular" size:17.0];
    
    alertVC.cancelButtonColor = [UIColor colorWithRed:78.0 / 255.0 green:118.0 / 255.0 blue:161.0 / 255.0 alpha:1];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 106, 128)];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:@"stars"];
    
    alertVC.alertViewContentView = imageView;
    
    NYAlertAction *okAction = [NYAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(NYAlertAction *action) {
                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                         [self performSegueWithIdentifier:@"AdSegue" sender:self];
                                                     }];
    
    [alertVC addAction:okAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - View Controller methods

- (void)viewDidLoad {
    [super viewDidLoad];
    NSInteger status = [self checkIfTasksExist];
    if (!status) {
        return;
    }
    [self registerDelegate];
    [self configureTaskDescription];
    [self configureActionDescription];
    [self configureTaskStorageMapping];
    [self configureButtons];
    [self configureImageView];
    [self configureRevealVC];
    [self initDBData];
    [self applyTask];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
