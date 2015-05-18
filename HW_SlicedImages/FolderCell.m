//
//  FolderCell.m
//  HW_SlicedImages
//
//  Created by Михаил on 15.05.15.
//  Copyright (c) 2015 Михаил. All rights reserved.
//

#import "FolderCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NetManager.h"

@interface FolderCell(){}
@property (nonatomic, weak) IBOutlet UILabel *label;
@end


@implementation FolderCell
-(void)setFolder:(NSDictionary *)folder{
    _folder = folder;
    NSString *fName = folder[@"folder_name"];
    self.label.text = fName;
}
@end
