//
//  Target_Detail.m
//  SXNews
//
//  Created by wangshiyu13 on 2017/1/27.
//  Copyright © 2017年 ShangxianDante. All rights reserved.
//

#import "Target_Detail.h"
#import "SXDetailPage.h"
#import "SXNewsEntity.h"

@implementation Target_Detail
- (UIViewController *)Action_aViewController:(NSDictionary *)params {
    SXNewsEntity *model = [[SXNewsEntity alloc]init];
    model.docid = params[@"docid"];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SXDetailPage" bundle:nil];
    SXDetailPage *devc = sb.instantiateInitialViewController;
    devc.newsModel = model;
    return devc;
}
@end
