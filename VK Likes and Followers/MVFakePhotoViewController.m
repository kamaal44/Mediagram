//
//  MVFakePhotoViewController.m
//  VK Likes and Followers
//
//  Created by whoami on 9/3/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVFakePhotoViewController.h"
#import "SWRevealViewController.h"
#import "MVPhotoCollectionViewCell.h"
#import "MVPhoto.h"

#import <VKSdk.h>
#import <UIImageView+WebCache.h>
#import <SVProgressHUD.h>
#import <Firebase.h>
#import <NYAlertViewController.h>

@interface MVFakePhotoViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@property (strong, nonatomic) NSArray<MVPhoto *> *photos;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSMutableArray<VKPhoto *> *photoArray;
@property (nonatomic, strong) FIRDatabaseReference *ref;
@property (nonatomic, strong) NSString *coins;

@end

@implementation MVFakePhotoViewController

#pragma mark - Transitions - 

- (IBAction)coinsButtonTapped:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"MoneySegue" sender:self];
}


#pragma mark - Photo Collection View Delegate Implementation -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MVPhotoCollectionViewCell *cell = (MVPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 0.5;
    
    self.selectedIndexPath = indexPath;
    
    NYAlertViewController *alertVC = [[NYAlertViewController alloc] init];
    
    alertVC.title = @"Просмотр фотографии";
    alertVC.titleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:23.0];
    
    alertVC.message = @"Вы желаете потратить 20 монет на просмотр фотографии в сети?";
    alertVC.messageFont = [UIFont fontWithName:@"AvenirNext-Regular" size:17.0];
    
    alertVC.cancelButtonColor = [UIColor colorWithRed:78.0 / 255.0 green:118.0 / 255.0 blue:161.0 / 255.0 alpha:1];
    
    
    NYAlertAction *okAction = [NYAlertAction actionWithTitle:@"ОК"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(NYAlertAction *action) {
                                                         NSInteger oldValue = [self.coins intValue];
                                                         NSInteger delta = 20;
                                                         
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
                                                             [self openSafariWebView];
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
    
    alertVC.message = @"Вам следует получить монеты, чтобы переходить к нужной фотографии.";
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


- (void)openSafariWebView {
    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[(MVPhotoCollectionViewCell *)[self.photoCollectionView cellForItemAtIndexPath:self.selectedIndexPath] sourceURL]]];
    svc.delegate = self;
    [self presentViewController:svc animated:YES completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    MVPhotoCollectionViewCell *cell = (MVPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    cell.photo.alpha = 1;
    cell.alpha = 1;
    
    self.selectedIndexPath = nil;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PVCell";
    
    MVPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell.photo sd_setImageWithURL:[NSURL URLWithString:self.photoArray[indexPath.row].photo_604] placeholderImage:[UIImage imageNamed:@"dog"]];
    
    cell.likeNumber.text = [NSString stringWithFormat:@"%@", self.photoArray[indexPath.row].fields[@"likes"][@"count"]];
    cell.layer.borderWidth = 0.3;
    cell.sourceURL = [NSString stringWithFormat:@"https://vk.com/photo%@_%@", self.photoArray[indexPath.row].owner_id, self.photoArray[indexPath.row].id];
    
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    printf("%f", self.view.frame.size.width);
    CGSize size = CGSizeMake(floor((self.view.frame.size.width - 1) / 3), floor((self.view.frame.size.width - 1) / 3 * 139 / 115));
    
    return size;
}


#pragma mark - VK Interaction -

- (void)initUserVKData {
    self.VKUserID = [NSString stringWithFormat:@"id%@", [[VKSdk accessToken] userId]];
    self.photoArray = [[NSMutableArray alloc] init];
    [SVProgressHUD show];
    
    dispatch_group_t dispatch_group = dispatch_group_create();
    dispatch_group_enter(dispatch_group);
    
    VKRequest *photosReq = [VKRequest requestWithMethod:@"fave.getPhotos" parameters:nil];
    [photosReq executeWithResultBlock:^(VKResponse *response) {
        VKPhotoArray *buffer = [[VKPhotoArray alloc] initWithDictionary:response.json];
        for (id photo in buffer) {
            [self.photoArray addObject:photo];
        }
        [self.photoCollectionView reloadData];
        dispatch_group_leave(dispatch_group);
    } errorBlock:^(NSError *error) {
        
    }];
    
    dispatch_group_notify(dispatch_group, dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
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

#pragma mark - Photo Collection View Appearance -

- (void)configureCollectionViewBackground {
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tg"]];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    self.photoCollectionView.backgroundView = imgView;
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

#pragma mark - View Controller methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureRevealVC];
    
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    
    [self initUserVKData];
    [self initUserDBData];
    [self configureCollectionViewBackground];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
