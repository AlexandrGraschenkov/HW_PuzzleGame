//
//  NetManager.h
//  HW_SlicedImages
//
//  Created by Михаил on 15.05.15.
//  Copyright (c) 2015 Михаил. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetManager : NSObject

+(instancetype)sharedInstance;
-(void)getNames:(void(^)(NSArray *, NSError *))completeion;
@end
