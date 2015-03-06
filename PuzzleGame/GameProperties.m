//
//  GameProperties.m
//  PuzzleGame
//
//  Created by Гена on 27.02.15.
//  Copyright (c) 2015 fix. All rights reserved.
//

#import "GameProperties.h"
#import "Game.h"

@interface GameProperties ()

@end

@implementation GameProperties

- (GameProperties *)initWithRows: (CGFloat)rows
                         Columns: (CGFloat)columns
                   ElementHeight: (CGFloat)height
                           Width: (CGFloat)width
                       ImageName: (NSString *)name;
{
    GameProperties *properties = [GameProperties new];
    properties.rowsCount = rows;
    properties.columnsCount = columns;
    properties.elemHieght = height;
    properties.elemWidth = width;
    properties.imageName = name;
    return properties;
}

- (GameProperties *)initPropertiesWithImageNamed: (NSString *)imageName
{
    for (NSDictionary *dict in [Game sharedInstance].getDataArray) {
        if ([imageName isEqual:dict[@"folder_name"]]) {
            return [self initWithRows:[dict[@"rows_count"] floatValue] Columns:[dict[@"columns_count"] floatValue] ElementHeight:[dict[@"elem_height"] floatValue] Width:[dict[@"elem_width"] floatValue] ImageName:imageName];
        }
    }
    return nil;
}

@end
