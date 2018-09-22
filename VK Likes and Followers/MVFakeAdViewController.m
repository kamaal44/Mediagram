//
//  MVFakeAdViewController.m
//  VK Likes and Followers
//
//  Created by whoami on 9/4/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVFakeAdViewController.h"
#import "SWRevealViewController.h"

#import <NYAlertViewController.h>
#import <VKApi.h>
#import <Firebase.h>

@interface MVFakeAdViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *gainLabel;
@property (weak, nonatomic) IBOutlet UIButton *watchAdButton;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSString *VKUserID;
@property (strong, nonatomic) NSString *balance;
@property (strong, nonatomic) NSString *gain;

@end

@implementation MVFakeAdViewController

#pragma mark - Transitions -

- (IBAction)coinsButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"MoneySegue" sender:self];
}


#pragma mark - Actions -

- (IBAction)watchAdButtonTapped:(id)sender {
    [self showAd];
}

- (void)showAd {
    VungleSDK* sdk = [VungleSDK sharedSDK];
    NSError *error;
    [sdk playAd:self error:&error];
}

- (void)showAlert {
    NYAlertViewController *alertVC = [[NYAlertViewController alloc] init];
    
    alertVC.title = @"Отлично!";
    alertVC.titleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:23.0];
    
    alertVC.message = @"Вы получили монеты за просмотр рекламы";
    alertVC.messageFont = [UIFont fontWithName:@"AvenirNext-Regular" size:17.0];
    
    alertVC.cancelButtonColor = [UIColor colorWithRed:78.0 / 255.0 green:118.0 / 255.0 blue:161.0 / 255.0 alpha:1];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 106, 128)];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:@"completed"];
    
    alertVC.alertViewContentView = imageView;
    
    NYAlertAction *okAction = [NYAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(NYAlertAction *action) {
                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    
    [alertVC addAction:okAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - Transitions -


- (IBAction)getCoinsButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"MoneySegue" sender:self];
}

#pragma mark - Reveal VC Configuration

- (void)configureRevealVC {
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}


- (void)configureWatchButton {
    self.watchAdButton.layer.cornerRadius = 5.0;
    self.watchAdButton.layer.borderWidth = 1.0;
    self.watchAdButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
}


#pragma mark - VK and DB Interaction -


- (void)initVKData {
    VKRequest *request = [VKRequest requestWithMethod:@"users.get" parameters:nil];
    
    [request executeWithResultBlock:^(VKResponse *response) {
        self.VKUserID = [NSString stringWithFormat:@"id%@", response.json[0][@"id"]];
        [self initDBData];
    } errorBlock:^(NSError *error) {
        
    }];
}

- (void)initDBData {
    self.ref = [[FIRDatabase database] reference];
    
    [self setUpBalance];
    [self setUpReward];
}

- (void)setUpBalance {
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

- (void)setUpReward {
    [[[self.ref child:@"reward"] child:@"video"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:@"black_coins"];
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        
        NSString *rewardString = [NSString stringWithFormat:@"Награда: +%@ ", snapshot.value];
        self.gain = snapshot.value;
        
        NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] initWithString:rewardString];
        
        [myString appendAttributedString:attachmentString];
        self.gainLabel.attributedText = myString;
    }];
}

- (void)updateBalanceLabel {
    NSInteger oldValue = [self.balance intValue];
    NSInteger delta = [self.gain intValue];
    NSString *newValue = [NSString stringWithFormat:@"%ld", oldValue + delta];
    
    [[[[self.ref child:@"users"] child: self.VKUserID] child:@"coins"] setValue:newValue];
}

#pragma mark - Vungle SDK Delegate Implementation -

- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary*)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet {
    [self showAlert];
    [self updateBalanceLabel];
}

#pragma mark - View Controller methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureWatchButton];
    [[VungleSDK sharedSDK] setDelegate:self];
    [self initVKData];
    [self configureRevealVC];
    [self showAd];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
