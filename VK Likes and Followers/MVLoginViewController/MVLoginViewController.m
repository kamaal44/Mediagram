//
//  MVLoginViewController.m
//  VK Likes and Followers
//
//  Created by whoami on 5/14/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVLoginViewController.h"
#import "MVMenuViewController.h"

#import <VKSdk.h>
#import <UserNotifications/UserNotifications.h>
#import <Firebase.h>
#import <SVProgressHUD.h>

NSArray *SCOPE;

@interface MVLoginViewController ()

@property (nonatomic) BOOL authorized;
@property (nonatomic) BOOL hide;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (nonatomic) dispatch_group_t dispatch_group;

@end

@implementation MVLoginViewController

- (void)presentAlert:(NSString *) errorMessage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:errorMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)performTransitionToMenuController {
    dispatch_group_notify(self.dispatch_group, dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        if (self.hide) {
            [self performSegueWithIdentifier:@"SegueToFakeRevealVC" sender:self];
        } else {
            [self performSegueWithIdentifier:@"SegueToRevealVC" sender:self];
        }
    });
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [VKSdk authorize:SCOPE];
}

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {
    if (result.token) {
        [self performTransitionToMenuController];
    }
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self presentViewController: controller animated: YES completion: nil];
}

- (void)vkSdkDidDismissViewController:(UIViewController *)controller {
    [VKSdk wakeUpSession:SCOPE completeBlock:^(VKAuthorizationState state, NSError *error) {
        if (state == VKAuthorizationAuthorized) {
            [self performTransitionToMenuController];
        }
    }];
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self];
}

- (void)vkSdkUserAuthorizationFailed {
    [self presentAlert:@"Authorization Failed"];
}

- (IBAction)loginButtonTapped:(id)sender {
    NSLog(@"Tapped login button");
    [VKSdk authorize:SCOPE];
}

- (void)registerLocalNotifications {
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge completionHandler:^(BOOL granted, NSError * _Nullable error) {
        NSLog(@"granted: %d; error:%@\n", granted, error);
    }];
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"Ваши лайки и подписчики ждут Вас!" arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:@"Заходите в приложение прямо сейчас и получайте бесплатные монеты!" arguments:nil];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.hour = 21;
    components.minute = 30;
    
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
    
    // Create the request object.
    UNNotificationRequest *request = [UNNotificationRequest
                                      requestWithIdentifier:@"LNRequest" content:content trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
    
}

- (void)initDBData {
    self.ref = [[FIRDatabase database] reference];
    [SVProgressHUD show];
    
    dispatch_group_enter(self.dispatch_group);
    [[self.ref child:@"hide"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.hide = [snapshot.value intValue];
        dispatch_group_leave(self.dispatch_group);
    }];
}

- (void)wakeUpSession {
    if (!self.afterSegue) {
        dispatch_group_enter(self.dispatch_group);
        [VKSdk wakeUpSession:SCOPE completeBlock:^(VKAuthorizationState state, NSError *error) {
            if (state == VKAuthorizationAuthorized) {
                self.authorized = YES;
                dispatch_group_leave(self.dispatch_group);
                [self performTransitionToMenuController];
            } else if (error) {
                dispatch_group_leave(self.dispatch_group);
                [SVProgressHUD dismiss];
                [self presentAlert:@"Не удаётся войти.\n\n Проверьте соединение и попробуйте снова."];
            } else {
                dispatch_group_leave(self.dispatch_group);
                [SVProgressHUD dismiss];
            }
        }];
    }
}

- (void)viewDidLoad {
    SCOPE = @[VK_PER_FRIENDS, VK_PER_WALL, VK_PER_PHOTOS, VK_PER_NOHTTPS];
    [super viewDidLoad];
    [self registerLocalNotifications];
    
    self.authorized = NO;
    
    VKSdk *sdkInstance = [VKSdk initializeWithAppId: @"6099784"];
    
    [sdkInstance registerDelegate:self];
    [sdkInstance setUiDelegate:self];
    
    
    self.dispatch_group = dispatch_group_create();
    [self initDBData];
    [self wakeUpSession];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
