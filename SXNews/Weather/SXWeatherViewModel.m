//
//  SXWeatherViewModel.m
//  SXNews
//
//  Created by dongshangxian on 16/3/8.
//  Copyright © 2016年 ShangxianDante. All rights reserved.
//

#import "SXWeatherViewModel.h"
#import "SXWeatherEntity.h"
#import <HLNetworking/HLNetworking.h>

@implementation SXWeatherViewModel

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
    _fetchWeatherInfoCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [self requestForWeatherSuccess:^(NSDictionary *result) {
                SXWeatherEntity *weatherModel = [SXWeatherEntity objectWithKeyValues:result];
                self.weatherModel = weatherModel;
                [subscriber sendNext:weatherModel];
            } failure:^(NSError *error) {
                [subscriber sendError:error];
            }];
            return nil;
        }];
    }];
}

- (void)requestForWeatherSuccess:(void (^)(NSDictionary *result))success
                          failure:(void (^)(NSError *error))failure{
    NSString *url = @"http://c.3g.163.com/nc/weather/5YyX5LqsfOWMl%2BS6rA%3D%3D.html";
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

@end
