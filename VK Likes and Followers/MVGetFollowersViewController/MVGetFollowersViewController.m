//
//  MVGetFollowersViewController.m
//  VK Likes and Followers
//
//  Created by whoami on 7/8/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVGetFollowersViewController.h"
#import "SWRevealViewController.h"
#import "MVExchangeTableViewCell.h"
#import "MVLinguisticAdapter.h"

#import <VKSdk.h>
#import <SdWebImage/UIImageView+WebCache.h>
#import <Firebase.h>
#import <NYAlertViewController.h>
#import <SVProgressHUD.h>

@interface MVGetFollowersViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIView *attributeView;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSString *VKUserID;
@property (strong, nonatomic) NSString *coins;
@property (strong, nonatomic) NSString *added;
@property (strong, nonatomic) NSString *purchased;
@property (strong, nonatomic) NSMutableDictionary *gain;

@end

@implementation MVGetFollowersViewController


#pragma mark - Offers -

- (IBAction)offersButtonTapped:(UIButton *)sender {
    // 1. Update current balance
    NSInteger oldValue = [self.coins intValue];
    NSInteger delta = [sender.titleLabel.text intValue];
    
    // -1. Finish execution
    if (oldValue - delta < 0) {
        [self handleNotEnoughCoins];
        return;
    }
    
    NSString *newValue = [NSString stringWithFormat:@"%ld", oldValue - delta];
    [[[[self.ref child:@"users"] child:self.VKUserID] child:@"coins"] setValue:newValue];
    
    
    // 2. Create task
    NSString *purchasedAmount = self.gain[sender.titleLabel.text];
    [[[self.ref child:@"follower_tasks"] child:self.VKUserID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (![snapshot exists]) {
            FIRDatabaseReference *taskRef = [[self.ref child:@"follower_tasks"] child:self.VKUserID];
            [taskRef setValue:@{@"added" : @"0",
                                @"purchased" : purchasedAmount}];
        } else {
            FIRDatabaseReference *purchasedRef = [[[self.ref child:@"follower_tasks"] child:self.VKUserID] child:@"purchased"];
            
            NSInteger oldValue = [self.purchased intValue];
            NSInteger delta = [purchasedAmount intValue];
            NSString *newValue = [NSString stringWithFormat:@"%ld", oldValue + delta];
            
            [purchasedRef setValue:newValue];
        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    
    // 3. Create active task
    [[[self.ref child:@"active_tasks"] child:self.VKUserID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (![snapshot exists]) {
            FIRDatabaseReference *activeTaskRef = [[self.ref child:@"active_tasks"] child:self.VKUserID];
            [activeTaskRef setValue:@"follower"];
        }
    }];
    
    // 4. Show alert
    [self handleCompletedOffer];
}

- (void)handleCompletedOffer {
    NYAlertViewController *alertVC = [[NYAlertViewController alloc] init];
    
    alertVC.title = @"Получилось!";
    alertVC.titleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:23.0];
    
    alertVC.message = @"Теперь дождитесь выполнения Вашего заказа";
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

#pragma mark - Transitions -

- (IBAction)getCoinsButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"MoneySegue" sender:self];
}


#pragma mark - Offers Table View Delegate Implementation -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.offers.count > 0 ? self.offers.count : 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"OfferCell";
    
    MVExchangeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (self.offers.count == 0) {
        cell.serviceImage.image = [UIImage imageNamed:@"black_follower"];
        cell.exchangeButton.layer.cornerRadius = cell.exchangeButton
        .bounds.size.height / 7;
        cell.layer.cornerRadius = cell.frame.size.height / 4;
        cell.layer.shadowRadius = cell.frame.size.height / 12;
        cell.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        cell.layer.shadowOffset = CGSizeMake(5.0, 5.0);
        return cell;
    }
    
    cell.serviceImage.image = [UIImage imageNamed:@"black_follower"];
    
    cell.offer.text = self.offers[indexPath.row].offerText;
    [cell.exchangeButton setTitle:self.offers[indexPath.row].cost forState:UIControlStateNormal];
    cell.exchangeButton.layer.cornerRadius = cell.exchangeButton
    .bounds.size.height / 7;
    cell.layer.cornerRadius = cell.frame.size.height / 4;
    cell.layer.shadowRadius = cell.frame.size.height / 12;
    cell.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    cell.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    
    return cell;
}


#pragma mark - Reveal Transition Implementation -

- (void)configureRevealVC {
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}


#pragma mark - VK Interaction -

- (void)initUserVKData {
    VKRequest *usersRequest = [[VKApi users] get:@{VK_API_FIELDS : @[@"counters", @"photo_400_orig"]}];
    
    [usersRequest executeWithResultBlock:^(VKResponse *response) {
        VKUser *user = [[VKUser alloc] initWithDictionary:response.json[0]];
        self.VKUserID = [NSString stringWithFormat:@"id%@", user.id];
        [self.photo sd_setImageWithURL:[NSURL URLWithString:[user photo_400_orig]] placeholderImage:[UIImage imageNamed:@"dog"]];
        self.followersLabel.text = [NSString stringWithFormat:@"%@", [[user counters] followers]];
        [self initUserDBData];
    } errorBlock:^(NSError *error) {
    }];
}


#pragma mark - Firebase Database Interaction -

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
    
    // 3. Setting up offers
    [[self.ref child:@"followers_offers"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.offers = [[NSMutableArray alloc] initWithCapacity:snapshot.childrenCount];
        self.gain = [[NSMutableDictionary alloc] initWithCapacity:snapshot.childrenCount];
        
        for (FIRDataSnapshot *child in snapshot.children) {
            MVOffer *offer = [[MVOffer alloc] init];
            
            offer.offerText = [MVLinguisticAdapter adapt:@"подписчик" with:child.value];
            // offer.offerText = [NSString stringWithFormat:@"%@ подписчиков", child.value];
            offer.cost = child.key;
            
            [self.offers addObject:offer];
            [self.gain setObject:child.value forKey:child.key];
        }
        
        [self.tableView reloadData];
    }];
    
    // 4. Registering observer for followers
    [[[self.ref child:@"follower_tasks"] child:self.VKUserID] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.exists) {
            self.added = [snapshot childSnapshotForPath:@"added"].value;
            self.purchased = [snapshot childSnapshotForPath:@"purchased"].value;
            self.status.text = [NSString stringWithFormat:@"Добавлено подписчиков: %@/%@", self.added, self.purchased];
        }
    }];
}


#pragma mark - Profile Photo Enhancement -

- (void)configureImage {
    self.attributeView.layer.cornerRadius = self.attributeView.bounds.size.height / 2;
    self.photo.layer.cornerRadius = 15.0;
    self.photo.layer.borderWidth = 2.0;
    self.photo.layer.borderColor = [UIColor whiteColor].CGColor;
    self.photo.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.photo.layer.shadowOffset = CGSizeMake(4, 4);
    self.photo.layer.shadowRadius = 5.0;
}


#pragma mark - View Controller methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureRevealVC];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [SVProgressHUD show];
    [SVProgressHUD dismissWithDelay:0.2];
    
    [self initUserVKData];
    [self configureImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
