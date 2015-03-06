//
//  NetManager.h
//  PuzzleGame
//
//  Created by Гена on 27.02.15.
//  Copyright (c) 2015 fix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetManager : NSObject

+ (instancetype)sharedInstance;

- (void)getTitles:(void(^)(NSArray *, NSError *))completion;

@end