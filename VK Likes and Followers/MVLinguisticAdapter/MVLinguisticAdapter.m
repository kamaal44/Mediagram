//
//  MVLinguisticAdapter.m
//  VK Likes and Followers
//
//  Created by whoami on 8/6/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVLinguisticAdapter.h"

@implementation MVLinguisticAdapter

+ (NSString *)adapt:(NSString *)word with:(NSString *)number {
    NSInteger intValue = [number intValue];
    
    if (intValue == 1) {
        return [NSString stringWithFormat:@"%@ %@", number, word];
    } else if (2 <= intValue && intValue <= 4) {
        return [NSString stringWithFormat:@"%@ %@а", number, word];
    } else {
        return [NSString stringWithFormat:@"%@ %@ов", number, word];
    }
}

@end
