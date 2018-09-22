//
//  MVIntermediateViewController.m
//  VK Likes and Followers
//
//  Created by whoami on 8/3/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVPerformTasksViewController.h"
#import "MVIntermediateViewController.h"
#import "MVTask.h"

#import <SVProgressHUD.h>
#import <Firebase.h>
#import <VKApi.h>
#import "SWRevealViewController.h"

@interface MVIntermediateViewController ()

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (strong, nonatomic) NSMutableArray<MVTask *> *tasks;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (nonatomic) NSInteger maxNumberOfTasks;
@property (strong, nonatomic) NSString *VKUserID;
@property (strong, nonatomic) NSMutableDictionary *reward;

@end

@implementation MVIntermediateViewController


#pragma mark - VK and DB Interaction -

- (void)initDBData {
    self.ref = [[FIRDatabase database] reference];
}

- (void)loadCoinsInfo {
    [[[[self.ref child:@"users"] child:self.VKUserID] child:@"coins"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:@"black_coins"];
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        
        NSString *balanceString = [NSString stringWithFormat:@"Ваш баланс: %@ ", snapshot.value];

        NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] initWithString:balanceString];
        [myString appendAttributedString:attachmentString];
        
        self.balanceLabel.attributedText = myString;
    }];
}

- (void)getMaxNumberOfTasks {
    [[self.ref child:@"tasks_limit"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.maxNumberOfTasks = [snapshot.value intValue] + 1;
        [self loadTasks];
    }];
}

- (void)loadTasks {
    dispatch_group_t dispatch_group = dispatch_group_create();
    
    dispatch_group_enter(dispatch_group);
    [[[self.ref child:@"active_tasks"] queryLimitedToFirst:self.maxNumberOfTasks] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.tasks = [[NSMutableArray alloc] initWithCapacity:snapshot.childrenCount];
        NSLog(@"%ld", snapshot.childrenCount);
        for (FIRDataSnapshot *child in snapshot.children) {
            MVTask *task = [[MVTask alloc] init];
            
            if ([child.key isEqualToString:@"anchor"]) {
                continue;
            }
            
            task.fullID = child.key;
            task.type = child.value;
            task.userID = [child.key substringFromIndex:2];
            if (![task.type isEqualToString:@"follower"]) {
                NSRange range = [task.userID rangeOfString:@"_"];
                task.itemID = [task.userID substringFromIndex:range.location + 1];
                task.userID = [task.userID substringToIndex:range.location];
            }
            
            [self.tasks addObject:task];
        }
        dispatch_group_leave(dispatch_group);
        // [self getDetailedInfoForTasks];
    }];
    dispatch_group_notify(dispatch_group, dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [self getDetailedInfoForTasks];
    });
}

- (void)getDetailedInfoForTasks {
    VKRequest *userRequest = [VKRequest requestWithMethod:@"users.get" parameters:nil];
    
    [userRequest executeWithResultBlock:^(VKResponse *response) {
        self.VKUserID = [NSString stringWithFormat:@"id%@", response.json[0][@"id"]];
        [self loadCoinsInfo];
    } errorBlock:^(NSError *error) {
        
    }];
    
    [[self.ref child:@"reward"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.reward = [[NSMutableDictionary alloc] initWithCapacity:snapshot.childrenCount];
        
        for (FIRDataSnapshot *child in snapshot.children) {
            [self.reward setObject:child.value forKey:child.key];
        }
    }];
    
    // dispatch_group_t dispatch_group = dispatch_group_create();
    
    
    for (MVTask *task in self.tasks) {
        if ([task.type isEqualToString:@"follower"]) {
            // VK
            VKRequest *usersRequest = [[VKApi users] get:@{VK_API_USER_ID : task.userID,
                                                           VK_API_FIELDS : @"photo_400_orig"
                                                           }];
            // dispatch_group_enter(dispatch_group);
            [usersRequest executeWithResultBlock:^(VKResponse *response) {
                task.photoURL = response.json[0][@"photo_400_orig"];
                // dispatch_group_leave(dispatch_group);
            } errorBlock:^(NSError *error) {
                
            }];
            
            VKRequest *friendsRequest = [VKRequest requestWithMethod:@"friends.areFriends" parameters:@{VK_API_USER_IDS : task.userID}];
            
            // dispatch_group_enter(dispatch_group);
            [friendsRequest executeWithResultBlock:^(VKResponse *response) {
                task.alreadyCompleted = ([response.json[0][@"friend_status"] intValue] == 1) || ([response.json[0][@"friend_status"] intValue] == 3);
                // dispatch_group_leave(dispatch_group);
            } errorBlock:^(NSError *error) {
                
            }];
            
            
            // DB
            [[[self.ref child:@"follower_tasks"] child: task.fullID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                if (snapshot.exists) {
                    task.added = [snapshot childSnapshotForPath:@"added"].value;
                    task.purchased = [snapshot childSnapshotForPath:@"purchased"].value;
                }
            }];
        } else if ([task.type isEqualToString:@"photo_like"]) {
            // VK
            VKRequest *photoRequest = [VKRequest requestWithMethod:@"photos.getById" parameters:@{@"photos" : [task.fullID substringFromIndex:2], VK_API_EXTENDED : @1}];
            
            // dispatch_group_enter(dispatch_group);
            [photoRequest executeWithResultBlock:^(VKResponse *response) {
                task.photoURL = response.json[0][@"photo_604"];
                task.alreadyCompleted = [response.json[0][@"likes"][@"user_likes"] intValue] == 1;
                // dispatch_group_leave(dispatch_group);
            } errorBlock:^(NSError *error) {
                
            }];
            
            // DB
            [[[self.ref child:@"photo_likes_tasks"] child: task.fullID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                if (snapshot.exists) {
                    task.added = [snapshot childSnapshotForPath:@"added"].value;
                    task.purchased = [snapshot childSnapshotForPath:@"purchased"].value;
                }
            }];
        } else if ([task.type isEqualToString:@"post_like"]) {
            // VK
            VKRequest *wallRequest = [VKRequest requestWithMethod:@"wall.getById" parameters:@{@"posts" : [task.fullID substringFromIndex:2], VK_API_EXTENDED : @1}];
            
            // dispatch_group_enter(dispatch_group);
            [wallRequest executeWithResultBlock:^(VKResponse *response) {
                if (response.json[@"copy_history"]) {
                    task.photoURL = response.json[@"items"][0][@"copy_history"][0][@"attachments"][0][@"photo"][@"photo_604"];
                } else {
                    task.photoURL = response.json[@"items"][0][@"attachments"][0][@"photo"][@"photo_604"];
                }
                task.alreadyCompleted = [response.json[@"items"][0][@"likes"][@"user_likes"] intValue] == 1;
                // dispatch_group_leave(dispatch_group);
            } errorBlock:^(NSError *error) {
                
            }];
            
            // DB
            [[[self.ref child:@"post_likes_tasks"] child: task.fullID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                if (snapshot.exists) {
                    task.added = [snapshot childSnapshotForPath:@"added"].value;
                    task.purchased = [snapshot childSnapshotForPath:@"purchased"].value;
                }
            }];
        } else {
            // VK
            VKRequest *wallRequest = [VKRequest requestWithMethod:@"wall.getById" parameters:@{@"posts" : [task.fullID substringFromIndex:2], VK_API_EXTENDED : @1}];
            // dispatch_group_enter(dispatch_group);
            [wallRequest executeWithResultBlock:^(VKResponse *response) {
                if (response.json[@"items"][0][@"copy_history"]) {
                    task.photoURL = response.json[@"items"][0][@"copy_history"][0][@"attachments"][0][@"photo"][@"photo_604"];
                } else {
                    task.photoURL = response.json[@"items"][0][@"attachments"][0][@"photo"][@"photo_604"];
                }
                NSLog(@"A");
                task.alreadyCompleted = [response.json[@"items"][0][@"reposts"][@"user_reposted"] intValue] == 1;
                // dispatch_group_leave(dispatch_group);
            } errorBlock:^(NSError *error) {
                
            }];
            
            [[[self.ref child:@"repost_tasks"] child: task.fullID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                if (snapshot.exists) {
                    task.added = [snapshot childSnapshotForPath:@"added"].value;
                    task.purchased = [snapshot childSnapshotForPath:@"purchased"].value;
                }
            }];
        }
    }
    
    /*dispatch_group_notify(dispatch_group, dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });*/
}

#pragma mark - Transitions -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"tasks"]) {
        MVPerformTasksViewController *vc = segue.destinationViewController;
        vc.tasks = self.tasks;
        vc.VKUserID = self.VKUserID;
        vc.reward = self.reward;
    }
}

- (IBAction)buyCoins:(id)sender {
    [self performSegueWithIdentifier:@"MoneySegue" sender:self];
}


#pragma mark - RevealVC Configuration -

- (void)configureRevealVC {
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

#pragma mark - Action -

- (IBAction)buttonTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:@"tasks" sender:self];
}

#pragma mark - Button Configuration -

- (void)configureButton {
    self.button.layer.cornerRadius = 5.0;
    self.button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.button.layer.borderWidth = 1.0;
}

#pragma mark - View Controller methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureRevealVC];
    [self configureButton];
    [self initDBData];
    [SVProgressHUD show];
    [self getMaxNumberOfTasks];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
