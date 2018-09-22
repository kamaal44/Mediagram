//
//  MVPhotoViewController.m
//  VK Likes and Followers
//
//  Created by whoami on 7/14/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVPhotoViewController.h"
#import "MVPhoto.h"
#import "MVPhotoCollectionViewCell.h"
#import "MVPresentPhotoViewController.h"

#import <VKSdk.h>
#import <UIImageView+WebCache.h>
#import <SVProgressHUD.h>

@interface MVPhotoViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (strong, nonatomic) NSArray<MVPhoto *> *photos;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSMutableArray<VKPhoto *> *photoArray;

@end

@implementation MVPhotoViewController


#pragma mark - Transitions -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"PhotoSegue"]) {
        MVPresentPhotoViewController *vc = (MVPresentPhotoViewController *)segue.destinationViewController;
        vc.pathToPhoto = self.photoArray[self.selectedIndexPath.row].photo_604;
        vc.labelText = [NSString stringWithFormat:@"%@", self.photoArray[self.selectedIndexPath.row].fields[@"likes"][@"count"]];
        vc.VKPhotoID = [NSString stringWithFormat:@"pd%@_%@", self.photoArray[self.selectedIndexPath.row].owner_id, self.photoArray[self.selectedIndexPath.row].id];
        vc.title = @"Заказать лайки";
    }
}


#pragma mark - Photo Collection View Delegate Implementation -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MVPhotoCollectionViewCell *cell = (MVPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 0.5;
    
    self.selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"PhotoSegue" sender:self];
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
    
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
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
    self.photoArray = [[NSMutableArray alloc] init];
    dispatch_group_t dispatch_group = dispatch_group_create();
    
    VKRequest *photosReq = [VKRequest requestWithMethod:@"photos.get" parameters:@{VK_API_EXTENDED : @1, VK_API_ALBUM_ID : @"profile", VK_API_COUNT : @15, @"rev" : @1}];
    
    dispatch_group_enter(dispatch_group);
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
        VKRequest *photosReq = [VKRequest requestWithMethod:@"photos.get" parameters:@{VK_API_EXTENDED : @1, VK_API_ALBUM_ID : @"wall", VK_API_COUNT : @25, @"rev" : @1}];
        
        [photosReq executeWithResultBlock:^(VKResponse *response) {
            VKPhotoArray *buffer = [[VKPhotoArray alloc] initWithDictionary:response.json];
            for (id photo in buffer) {
                [self.photoArray addObject:photo];
            }
            [self.photoCollectionView reloadData];
        } errorBlock:^(NSError *error) {
            
        }];
    });
}


#pragma mark - Photo Collection View Appearance -

- (void)configureCollectionViewBackground {
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tg"]];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    self.photoCollectionView.backgroundView = imgView;
}


#pragma mark - View Controller methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    
    [SVProgressHUD show];
    [SVProgressHUD dismissWithDelay:0.2];
    
    [self initUserVKData];
    [self configureCollectionViewBackground];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
