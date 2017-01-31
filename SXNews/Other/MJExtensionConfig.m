//
//  MJExtensionConfig.m
//  SXNews
//
//  Created by dongshangxian on 15/8/10.
//  Copyright (c) 2015年 ShangxianDante. All rights reserved.
//

#import "MJExtensionConfig.h"
#import "SXPhotoSetEntity.h"

@implementation MJExtensionConfig
+ (void)load
{
    // 相当于在Student.m中实现了+replacedKeyFromPropertyName方法
    
    [SXPhotoSetEntity setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"photos":@"SXPhotosDetailEntity"
                 };
    }];
}
@end
