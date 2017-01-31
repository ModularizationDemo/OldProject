//
//  SXNewsDetailViewModel.m
//  SXNews
//
//  Created by dongshangxian on 16/3/8.
//  Copyright © 2016年 ShangxianDante. All rights reserved.
//

#import "SXNewsDetailViewModel.h"
#import "SXDetailImgEntity.h"
#import "SXNewsDetailReplyEntity.h"
#import <HLNetworking/HLNetworking.h>

@interface SXNewsDetailViewModel ()

@end

@implementation SXNewsDetailViewModel

- (instancetype)init
{
    if (self = [super init]) {
        [self setupRACCommand];
    }
    return self;
}

- (void)setupRACCommand
{
    @weakify(self);
    _fetchNewsDetailCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [self requestForNewsDetailSuccess:^(NSDictionary *result) {
                
                self.detailModel = [SXNewsDetailEntity detailWithDict:result[self.newsModel.docid]];
                if (self.newsModel.boardid.length < 1) {
                    self.newsModel.boardid = self.detailModel.replyBoard;
                }
                self.newsModel.replyCount = @(self.detailModel.replyCount);
                
                self.sameNews = [SXSimilarNewsEntity objectArrayWithKeyValuesArray:result[self.newsModel.docid][@"relative_sys"]];
                self.keywordSearch = result[self.newsModel.docid][@"keyword_search"];
                
                CGFloat count =  [self.newsModel.replyCount intValue];
                if (count > 10000) {
                    self.replyCountBtnTitle = [NSString stringWithFormat:@"%.1f万跟帖",count/10000];
                }else{
                    self.replyCountBtnTitle = [NSString stringWithFormat:@"%.0f跟帖",count];
                }
                [subscriber sendNext:self.replyCountBtnTitle];
                [subscriber sendCompleted];
            } failure:^(NSError *error) {
                [subscriber sendError:error];
            }];
            return nil;
        }];
    }];
    
    _fetchHotFeedbackCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [self requestForFeedbackSuccess:^(NSDictionary *responseObject) {
                if (responseObject[@"hotPosts"] != [NSNull null]) {
                    NSArray *dictarray = responseObject[@"hotPosts"];
                    NSMutableArray *temReplyModels = [NSMutableArray array];
                    for (int i = 0; i < dictarray.count; i++) {
                        NSDictionary *dict = dictarray[i][@"1"];
                        SXNewsDetailReplyEntity *replyModel = [[SXNewsDetailReplyEntity alloc]init];
                        replyModel.name = dict[@"n"];
                        if (replyModel.name == nil) {
                            replyModel.name = @"火星网友";
                        }
                        replyModel.address = dict[@"f"];
                        replyModel.say = dict[@"b"];
                        replyModel.suppose = dict[@"v"];
                        replyModel.icon = dict[@"timg"];
                        replyModel.rtime = dict[@"t"];
                        [temReplyModels addObject:replyModel];
                    }
                    self.replyModels = temReplyModels;
                    [subscriber sendNext:temReplyModels];
                    [subscriber sendCompleted];
                }
            } failure:^(NSError *error) {
                [subscriber sendError:error];
            }];
            return nil;
        }];
    }];
}

#pragma mark - **************** 下面相当于service的代码
- (void)requestForNewsDetailSuccess:(void (^)(NSDictionary *result))success
                         failure:(void (^)(NSError *error))failure{
    NSString *url = [NSString stringWithFormat:@"http://c.m.163.com/nc/article/%@/full.html",self.newsModel.docid];
    [[HLAPIRequest request]
     .setMethod(GET)
     .setCustomURL(url)
     .success(^(id response){
        success(response);
    })
     .failure(^(NSError *error){
        failure(error);
    })
     start];
}

- (void)requestForFeedbackSuccess:(void (^)(NSDictionary *result))success
                          failure:(void (^)(NSError *error))failure{
    NSString *url = [NSString stringWithFormat:@"http://comment.api.163.com/api/json/post/list/new/hot/%@/%@/0/10/10/2/2",self.newsModel.boardid,self.newsModel.docid];

    [[HLAPIRequest request]
     .setMethod(GET)
     .setCustomURL(url)
     .success(^(id response){
        if (response) {
            success(response);
        }
    })
     .failure(^(NSError *error){
        failure(error);
    })
     start];
}

#pragma mark - **************** 业务逻辑
- (NSString *)getHtmlString
{
    NSMutableString *html = [NSMutableString string];
    [html appendString:@"<html>"];
    [html appendString:@"<head>"];
    [html appendFormat:@"<link rel=\"stylesheet\" href=\"%@\">",[[NSBundle mainBundle] URLForResource:@"SXDetails.css" withExtension:nil]];
    [html appendString:@"</head>"];
    
    [html appendString:@"<body style=\"background:#f6f6f6\">"];
    [html appendString:[self getBodyString]];
    [html appendString:@"</body>"];
    
    [html appendString:@"</html>"];
    
    return html;
}

- (NSString *)getBodyString
{
    NSMutableString *body = [NSMutableString string];
    [body appendFormat:@"<div class=\"title\">%@</div>",self.detailModel.title];
    [body appendFormat:@"<div class=\"time\">%@</div>",self.detailModel.ptime];
    if (self.detailModel.body != nil) {
        [body appendString:self.detailModel.body];
    }
    for (SXDetailImgEntity *detailImgModel in self.detailModel.img) {
        NSMutableString *imgHtml = [NSMutableString string];
        // 设置img的div
        [imgHtml appendString:@"<div class=\"img-parent\">"];
        NSArray *pixel = [detailImgModel.pixel componentsSeparatedByString:@"*"];
        CGFloat width = [[pixel firstObject]floatValue];
        CGFloat height = [[pixel lastObject]floatValue];
        // 判断是否超过最大宽度
        CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width * 0.96;
        if (width > maxWidth) {
            height = maxWidth / width * height;
            width = maxWidth;
        }
        
        NSString *onload = @"this.onclick = function() {"
        "  window.location.href = 'sx://github.com/dsxNiubility?src=' +this.src+'&top=' + this.getBoundingClientRect().top + '&whscale=' + this.clientWidth/this.clientHeight ;"
        "};";
        [imgHtml appendFormat:@"<img onload=\"%@\" width=\"%f\" height=\"%f\" src=\"%@\">",onload,width,height,detailImgModel.src];
        [imgHtml appendString:@"</div>"];
        [body replaceOccurrencesOfString:detailImgModel.ref withString:imgHtml options:NSCaseInsensitiveSearch range:NSMakeRange(0, body.length)];
    }
    return body;
}

@end
