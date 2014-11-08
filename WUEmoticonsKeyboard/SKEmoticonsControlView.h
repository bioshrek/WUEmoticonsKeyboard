//
//  SKEmoticonsControlView.h
//  WUEmoticonsKeyboardDemo
//
//  Created by shrek wang on 11/8/14.
//  Copyright (c) 2014 YuAo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WUEmoticonsKeyboardKeyItemGroup.h"
#import "WUEmoticonsKeyboardKeyItem.h"
#import "WUEmoticonsKeyboardKeyCell.h"

typedef NS_ENUM(NSInteger, SKEmoticonControlButton) {
    SKEmoticonControlLeftButton = 1,
    SKEmoticonControlRightButton = 2
};

@protocol SKEmoticonsControlViewDelegate <NSObject>

@optional

- (void)keyItemGroup:(WUEmoticonsKeyboardKeyItemGroup *)keyItemGroup
       keyItemTapped:(WUEmoticonsKeyboardKeyItem *)keyItem;

- (void)keyItemGroup:(WUEmoticonsKeyboardKeyItemGroup *)keyItemGroup
pressedKeyCellChangedFrom:(WUEmoticonsKeyboardKeyCell *)fromKeyCell
                  to:(WUEmoticonsKeyboardKeyCell *)toKeyCell;

@end

@interface SKEmoticonsControlView : UIView

@property (nonatomic, strong) NSArray *keyItemGroups;

@property (nonatomic, weak) id<SKEmoticonsControlViewDelegate> delegate;

@property (weak, nonatomic) UIButton *leftButton;
@property (weak, nonatomic) UIButton *rightButton;
@property (weak, nonatomic) UISegmentedControl *segmentedControl;

@end
