//
//  MVMenuViewController.m
//  VK Likes and Followers
//
//  Created by whoami on 7/8/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVMenuViewController.h"
#import "MVTableViewCell.h"
#import "MVLoginViewController.h"
#import "MVPurchaseViewController.h"
#import "MVTaskPerformer.h"

#import <VKSdk.h>
#import <UIImageView+WebCache.h>
#import <Firebase.h>
#import <NYAlertViewController.h>

@interface MVMenuViewController ()

@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;
@property (weak, nonatomic) IBOutlet UILabel *coinsNumber;
@property (weak, nonatomic) IBOutlet UILabel *profileName;

@property (strong, nonatomic) NSString *initialUserCoins;
@property (strong, nonatomic) NSString *VKUserID;
@property (strong, nonatomic) NSArray *menuItems;

@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

@implementation MVMenuViewController


#pragma mark - Transitions -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SegueToLoginVC"]) {
        MVLoginViewController *vc = (MVLoginViewController *)segue.destinationViewController;
        vc.afterSegue = YES;
    }
}


#pragma mark - Menu Table View Delegate Implementation -

// Three sections: "Order", "Get coins" and "Additional"
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Заказать";
    } else if (section == 1) {
        return @"Получить монеты";
    } else if (section == 2) {
        return @"Дополнительно";
    } else {
        return @"What??";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 3;
    } else if (section == 2) {
        return 2;
    } else {
        return -1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"Cell";
    
    MVTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.cellLabel.text = @"Лайки";
        cell.cellLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
        cell.cellLabel.textColor = [UIColor blackColor];
        cell.blackImageName = @"black_like_plus";
        cell.whiteImageName = @"white_like_plus";
        cell.cellImageView.image = [UIImage imageNamed:cell.blackImageName];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        cell.cellLabel.text = @"Подписчики";
        cell.cellLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
        cell.cellLabel.textColor = [UIColor blackColor];
        cell.blackImageName = @"black_follower_plus";
        cell.whiteImageName = @"white_follower_plus";
        cell.cellImageView.image = [UIImage imageNamed:cell.blackImageName];
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        cell.cellLabel.text = @"Репосты";
        cell.cellLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
        cell.cellLabel.textColor = [UIColor blackColor];
        cell.blackImageName = @"black_repost_plus";
        cell.whiteImageName = @"white_repost_plus";
        cell.cellImageView.image = [UIImage imageNamed:cell.blackImageName];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        cell.cellLabel.text = @"Купить монеты";
        cell.cellLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
        cell.cellLabel.textColor = [UIColor blackColor];
        cell.blackImageName = @"black_cart";
        cell.whiteImageName = @"white_cart";
        cell.cellImageView.image = [UIImage imageNamed:cell.blackImageName];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        cell.cellLabel.text = @"Выполнить задания";
        cell.cellLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
        cell.cellLabel.textColor = [UIColor blackColor];
        cell.blackImageName = @"black_tasks";
        cell.whiteImageName = @"white_tasks";
        cell.cellImageView.image = [UIImage imageNamed:cell.blackImageName];
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        cell.cellLabel.text = @"Смотреть видео";
        cell.cellLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
        cell.cellLabel.textColor = [UIColor blackColor];
        cell.blackImageName = @"black_ad";
        cell.whiteImageName = @"white_ad";
        cell.cellImageView.image = [UIImage imageNamed:cell.blackImageName];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        cell.cellLabel.text = @"Написать нам";
        cell.cellLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
        cell.cellLabel.textColor = [UIColor blackColor];
        cell.blackImageName = @"black_mail";
        cell.whiteImageName = @"white_mail";
        cell.cellImageView.image = [UIImage imageNamed:cell.blackImageName];
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        cell.cellLabel.text = @"Выйти";
        cell.cellLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
        cell.cellLabel.textColor = [UIColor blackColor];
        cell.blackImageName = @"black_exit";
        cell.whiteImageName = @"white_exit";
        cell.cellImageView.image = [UIImage imageNamed:cell.blackImageName];
    } else {
        // what???
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MVTableViewCell *cell = [self.menuTableView cellForRowAtIndexPath:indexPath];
    
    cell.cellLabel.textColor = [UIColor whiteColor];
    cell.cellImageView.image = [UIImage imageNamed:cell.whiteImageName];
    cell.contentView.backgroundColor = [UIColor colorWithRed:78.0 / 255.0 green:118.0 / 255.0 blue:161.0 / 255.0 alpha:1];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"get_likes" sender:self];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        [self performSegueWithIdentifier:@"get_followers" sender:self];
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        [self performSegueWithIdentifier:@"get_reposts" sender:self];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"buy_coins" sender:self];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        [self performSegueWithIdentifier:@"tasks" sender:self];
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        [self performSegueWithIdentifier:@"ad" sender:self];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        [self composeMail];
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        [VKSdk forceLogout];
        [self performSegueWithIdentifier:@"SegueToLoginVC" sender:self];
    } else {
        // what???
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    MVTableViewCell *cell = [self.menuTableView cellForRowAtIndexPath:indexPath];
    
    cell.cellLabel.textColor = [UIColor blackColor];
    cell.cellImageView.image = [UIImage imageNamed:cell.blackImageName];
    cell.contentView.backgroundColor = [UIColor whiteColor];
}


#pragma mark - Profile Photo Enhancement -

// Adds some visual effects
- (void)configureProfilePhoto {
    [self.profilePhoto.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.profilePhoto.layer setBorderWidth:1.0];
    [self.profilePhoto.layer setCornerRadius:self.profilePhoto.frame.size.height / 2];
    [self.profilePhoto.layer setMasksToBounds:YES];
}


#pragma mark - VK Interaction -

// Loads Profile Photo and Username
- (void)initUserVKData {
    VKRequest *usersRequest = [[VKApi users] get:@{VK_API_FIELDS : @[@"counters", @"photo_400_orig"]}];
    
    [usersRequest executeWithResultBlock:^(VKResponse *response) {
        VKUser *user = [[VKUser alloc] initWithDictionary:response.json[0]];
        self.VKUserID = [NSString stringWithFormat:@"id%@", user.id];
        self.profileName.text = [NSString stringWithFormat:@"%@ %@", user.first_name, user.last_name];
        [self.profilePhoto sd_setImageWithURL:[NSURL URLWithString:user.photo_400_orig] placeholderImage:[UIImage imageNamed:@"dog"]];
        [MVTaskPerformer beginPerformingTasksWithVKUserID:self.VKUserID];
        [self initUserDBData];
    } errorBlock:^(NSError *error) {
    }];
}


#pragma mark - Firebase Database Interaction -

// Loads Coin Amount
- (void)initUserDBData {
    self.ref = [[FIRDatabase database] reference];
    
    [[self.ref child:@"initial_user_coins"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.initialUserCoins = snapshot.value;
        [[[[self.ref child:@"users"] child:self.VKUserID] child:@"coins"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (![snapshot exists]) {
                FIRDatabaseReference *userRef = [[self.ref child:@"users"] child:self.VKUserID];
                [userRef setValue:@{@"coins" : self.initialUserCoins}];
                self.coinsNumber.text = self.initialUserCoins;
            } else {
                self.coinsNumber.text = snapshot.value;
            }
            [self checkForDailyBonus];
        } withCancelBlock:^(NSError * _Nonnull error) {
            NSLog(@"%@", error.localizedDescription);
        }];
    }];
}


#pragma mark - Mail Interaction -

- (void)composeMail {
    NSString *emailTitle = @"Обращение в службу поддержки";

    NSArray *toRecipents = [NSArray arrayWithObject:@"mountainviewer@yahoo.com"];
    
    MFMailComposeViewController *mailComposeVC = [[MFMailComposeViewController alloc] init];
    mailComposeVC.mailComposeDelegate = self;
    [mailComposeVC setSubject:emailTitle];
    [mailComposeVC setToRecipients:toRecipents];
    
    [self presentViewController:mailComposeVC animated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Daily Bonus -

- (void)checkForDailyBonus {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];
    
    NSInteger dayLastVisited = [[NSUserDefaults standardUserDefaults] integerForKey:@"day"];
    NSInteger monthLastVisited = [[NSUserDefaults standardUserDefaults] integerForKey:@"month"];
    NSInteger yearLastVisited = [[NSUserDefaults standardUserDefaults] integerForKey:@"year"];
    
    if (day != dayLastVisited || month != monthLastVisited || year != yearLastVisited) {
        [self updateBalance];
        [self showAlert];
        [[NSUserDefaults standardUserDefaults] setInteger:day forKey:@"day"];
        [[NSUserDefaults standardUserDefaults] setInteger:month forKey:@"month"];
        [[NSUserDefaults standardUserDefaults] setInteger:year forKey:@"year"];
    }
}

- (void)updateBalance {
    NSInteger oldValue = [self.coinsNumber.text intValue];
    NSInteger delta = [@"50" intValue];
    NSString *newValue = [NSString stringWithFormat:@"%ld", oldValue + delta];
    
    [[[[self.ref child:@"users"] child: self.VKUserID] child:@"coins"] setValue:newValue];
}

- (void)showAlert {
    NYAlertViewController *alertVC = [[NYAlertViewController alloc] init];
    
    alertVC.title = @"Так держать!";
    alertVC.titleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:23.0];
    
    alertVC.message = @"Вы получили 50 монет за посещение сегодня";
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

#pragma mark - View Controller Required methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    
    [self configureProfilePhoto];
    [self initUserVKData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
