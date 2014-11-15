//
//  SKEmoticonsKeyboardItemGroupView.h
//  WUEmoticonsKeyboardDemo
//
//  Created by shrek wang on 11/15/14.
//  Copyright (c) 2014 YuAo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WUEmoticonsKeyboardKeyItemGroup.h"

@class SKEmoticonsKeyboardItemGroupView;

@protocol SKEmoticonsKeyboardItemGroupViewDelegate <NSObject>

- (void)groupView:(SKEmoticonsKeyboardItemGroupView *)groupView didSelectItemAtIndex:(NSUInteger)index;

@end

@interface SKEmoticonsKeyboardItemGroupView : UIView

@property (nonatomic,strong)        WUEmoticonsKeyboardKeyItemGroup *keyItemGroup;

@property (nonatomic,weak,readonly) UIImageView                     *backgroundImageView;

@property (nonatomic, weak) id<SKEmoticonsKeyboardItemGroupViewDelegate> delegate;

@property (nonatomic, assign) BOOL popupViewWhenCellPressed;  // default: NO

@end
