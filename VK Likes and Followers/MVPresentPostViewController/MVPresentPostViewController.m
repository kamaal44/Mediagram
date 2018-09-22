//
//  MVPresentPostViewController.m
//  VK Likes and Followers
//
//  Created by whoami on 7/16/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVPresentPostViewController.h"
#import "MVExchangeTableViewCell.h"
#import "MVLinguisticAdapter.h"

#import <VKSdk.h>
#import <Firebase.h>
#import <NYAlertViewController.h>
#import <SVProgressHUD.h>

@interface MVPresentPostViewController ()

@property (weak, nonatomic) IBOutlet UIView *attributeView;

@property (strong, nonatomic) NSString *VKUserID;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSString *coins;
@property (strong, nonatomic) NSMutableDictionary *gain;
@property (strong, nonatomic) NSString *added;
@property (strong, nonatomic) NSString *purchased;

@end

@implementation MVPresentPostViewController


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
    if (self.isLikeVC) {
        NSString *purchasedAmount = self.gain[sender.titleLabel.text];
        [[[self.ref child:@"post_likes_tasks"] child:self.VKPostID]
         observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
             if (![snapshot exists]) {
                 FIRDatabaseReference *taskRef = [[self.ref child:@"post_likes_tasks"] child:self.VKPostID];
                 [taskRef setValue:@{@"added" : @"0",
                                     @"purchased" : purchasedAmount}];
             } else {
                 FIRDatabaseReference *purchasedRef = [[[self.ref child:@"post_likes_tasks"] child:self.VKPostID] child:@"purchased"];
                 
                 NSInteger oldValue = [self.purchased intValue];
                 NSInteger delta = [purchasedAmount intValue];
                 NSString *newValue = [NSString stringWithFormat:@"%ld", oldValue + delta];
                 
                 [purchasedRef setValue:newValue];
             }
         } withCancelBlock:^(NSError * _Nonnull error) {
             NSLog(@"%@", error.localizedDescription);
         }];
    } else {
        NSString *purchasedAmount = self.gain[sender.titleLabel.text];
        [[[self.ref child:@"repost_tasks"] child:self.VKPostID]
         observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
             if (![snapshot exists]) {
                 FIRDatabaseReference *taskRef = [[self.ref child:@"repost_tasks"] child:self.VKPostID];
                 [taskRef setValue:@{@"added" : @"0",
                                     @"purchased" : purchasedAmount}];
             } else {
                 FIRDatabaseReference *purchasedRef = [[[self.ref child:@"repost_tasks"] child:self.VKPostID] child:@"purchased"];
                 
                 NSInteger oldValue = [self.purchased intValue];
                 NSInteger delta = [purchasedAmount intValue];
                 NSString *newValue = [NSString stringWithFormat:@"%ld", oldValue + delta];
                 
                 [purchasedRef setValue:newValue];
             }
         } withCancelBlock:^(NSError * _Nonnull error) {
             NSLog(@"%@", error.localizedDescription);
         }];
    }
    
    // 3. Create active task
    if (self.isLikeVC) {
        [[[self.ref child:@"active_tasks"] child:self.VKPostID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (![snapshot exists]) {
                FIRDatabaseReference *activeTaskRef = [[self.ref child:@"active_tasks"] child:self.VKPostID];
                [activeTaskRef setValue:@"post_like"];
            }
        }];
    } else {
        [[[self.ref child:@"active_tasks"] child:self.VKPostID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (![snapshot exists]) {
                FIRDatabaseReference *activeTaskRef = [[self.ref child:@"active_tasks"] child:self.VKPostID];
                [activeTaskRef setValue:@"repost"];
            }
        }];
    }
    
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


#pragma mark - Offers Table View Delegate Implementation -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.offers.count > 0 ? self.offers.count : 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    MVExchangeTableViewCell *cell = [self.exchangeTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (self.offers.count == 0) {
        if (self.isLikeVC) {
            cell.serviceImage.image = [UIImage imageNamed:@"black_like"];
        } else {
            cell.serviceImage.image = [UIImage imageNamed:@"black_repost"];
        }
        cell.exchangeButton.layer.cornerRadius = cell.exchangeButton
        .bounds.size.height / 7;
        cell.layer.cornerRadius = cell.frame.size.height / 4;
        cell.layer.shadowRadius = cell.frame.size.height / 12;
        cell.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        cell.layer.shadowOffset = CGSizeMake(5.0, 5.0);
        return cell;
    }
    
    if (self.isLikeVC) {
        cell.serviceImage.image = [UIImage imageNamed:@"black_like"];
    } else {
        cell.serviceImage.image = [UIImage imageNamed:@"black_repost"];
    }
    
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


#pragma mark - Navigation Items Setup -

- (void)addButtons {
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonAction)];
    
    leftButton.tintColor = [UIColor blackColor];
    leftButton.image = [UIImage imageNamed:@"black_arrow"];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonAction)];
    
    rightButton.tintColor = [UIColor blackColor];
    rightButton.image = [UIImage imageNamed:@"black_coins_plus"];
    
    
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.hidesBackButton = YES;
}


#pragma mark - Post Elements Enhancement -

- (void)configureImageAndLabel {
    self.attributeView.layer.cornerRadius = self.attributeView.bounds.size.height / 2;
    self.postImage.layer.cornerRadius = 15.0;
    self.postImage.layer.borderWidth = 2.0;
    self.postImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.postImage.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.postImage.layer.shadowOffset = CGSizeMake(4, 4);
    self.postImage.layer.shadowRadius = 5.0;
    self.postText.layer.cornerRadius = 7.0;
    self.postText.layer.shadowRadius = 3.0;
    self.postText.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.postText.layer.borderWidth = 0.5;
    self.postText.layer.borderColor = [UIColor colorWithRed:166.0/255.0 green:207.0/255.0 blue:191.0/255.0 alpha:1.0].CGColor;
}


#pragma mark - Initializing Data After Segue -

- (void)initDataAfterSegue {
    self.postText.text = self.postLabelText;
    self.postImage.image = self.image;
    self.currencyAmount.text = self.currenctAmountText;
}


#pragma mark - Registering Swipe Right -

- (void)registerSwipeRight {
    UISwipeGestureRecognizer *swipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
}

- (void)swipeRight:(UISwipeGestureRecognizer*)gestureRecognizer {
    [self leftButtonAction];
}


#pragma mark - Navigation Bar actions -

- (void)leftButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonAction {
    [self performSegueWithIdentifier:@"MoneySegue" sender:self];
}


#pragma mark - VK Interaction -

- (void)initUserVKData {
    VKRequest *usersRequest = [[VKApi users] get];
    
    [usersRequest executeWithResultBlock:^(VKResponse *response) {
        VKUser *user = [[VKUser alloc] initWithDictionary:response.json[0]];
        self.VKUserID = [NSString stringWithFormat:@"id%@", user.id];
        [self initUserDBData];
    } errorBlock:^(NSError *error) {
    }];
}


#pragma mark - Firebase Database Interaction -

- (void)initUserDBData {
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
    if (self.isLikeVC) {
        [[self.ref child:@"post_likes_offers"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            self.offers = [[NSMutableArray alloc] initWithCapacity:snapshot.childrenCount];
            self.gain = [[NSMutableDictionary alloc] initWithCapacity:snapshot.childrenCount];
            
            for (FIRDataSnapshot *child in snapshot.children) {
                MVOffer *offer = [[MVOffer alloc] init];
                
                offer.cost = child.key;
                offer.offerText = [MVLinguisticAdapter adapt:@"лайк" with:child.value];
                //offer.offerText = [NSString stringWithFormat:@"%@ лайков", child.value];
                
                [self.offers addObject:offer];
                [self.gain setObject:child.value forKey:child.key];
            }
            
            [self.exchangeTableView reloadData];
        }];
    } else {
        [[self.ref child:@"reposts_offers"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            self.offers = [[NSMutableArray alloc] initWithCapacity:snapshot.childrenCount];
            self.gain = [[NSMutableDictionary alloc] initWithCapacity:snapshot.childrenCount];
            
            for (FIRDataSnapshot *child in snapshot.children) {
                MVOffer *offer = [[MVOffer alloc] init];
                
                offer.cost = child.key;
                offer.offerText = [MVLinguisticAdapter adapt:@"репост" with:child.value];
                // offer.offerText = [NSString stringWithFormat:@"%@ репостов", child.value];
                
                [self.offers addObject:offer];
                [self.gain setObject:child.value forKey:child.key];
            }
            
            [self.exchangeTableView reloadData];
        }];
    }
    
    // 4. Registering observer for followers
    if (self.isLikeVC) {
        self.currencyImage.image = [UIImage imageNamed:@"white_like"];
        [[[self.ref child:@"post_likes_tasks"] child:self.VKPostID] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot.exists) {
                self.added = [snapshot childSnapshotForPath:@"added"].value;
                self.purchased = [snapshot childSnapshotForPath:@"purchased"].value;
                self.cheatStatus.text = [NSString stringWithFormat:@"Добавлено лайков: %@/%@", self.added, self.purchased];
            }
        }];
    } else {
        self.currencyImage.image = [UIImage imageNamed:@"white_repost"];
        [[[self.ref child:@"repost_tasks"] child:self.VKPostID] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot.exists) {
                self.added = [snapshot childSnapshotForPath:@"added"].value;
                self.purchased = [snapshot childSnapshotForPath:@"purchased"].value;
                self.cheatStatus.text = [NSString stringWithFormat:@"Добавлено репостов: %@/%@", self.added, self.purchased];
            }
        }];
    }
}


#pragma mark - View Controller methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addButtons];
    
    self.exchangeTableView.delegate = self;
    self.exchangeTableView.dataSource = self;
    
    [SVProgressHUD show];
    [SVProgressHUD dismissWithDelay:0.2];
    
    [self initUserVKData];
    
    [self configureImageAndLabel];
    [self initDataAfterSegue];
    [self registerSwipeRight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
