//
//  SXNewsDetailBottomCell.h
//  SXNews
//
//  Created by dongshangxian on 16/1/29.
//  Copyright © 2016年 ShangxianDante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SXSimilarNewsEntity.h"

@class SXNewsDetailReplyEntity;

@interface SXNewsDetailBottomCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *sectionHeaderLbl;

@property(nonatomic,strong)SXNewsDetailReplyEntity *replyModel;

@property(nonatomic,strong)SXSimilarNewsEntity *sameNewsEntity;

@property(nonatomic,assign)BOOL iSCloseing;

+ (instancetype)theShareCell;

+ (instancetype)theSectionHeaderCell;

+ (instancetype)theSectionBottomCell;

+ (instancetype)theHotReplyCellWithTableView:(UITableView *)tableView;

+ (instancetype)theContactNewsCell;

+ (instancetype)theCloseCell;

+ (instancetype)theKeywordCell;

@end
