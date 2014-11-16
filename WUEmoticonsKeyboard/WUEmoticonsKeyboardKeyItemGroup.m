//
//  WUEmoticonsKeyboardKeyItemGroup.m
//  WeicoUI
//
//  Created by YuAo on 1/24/13.
//  Copyright (c) 2013 微酷奥(北京)科技有限公司. All rights reserved.
//

#import "WUEmoticonsKeyboardKeyItemGroup.h"
#import "WUEmoticonsKeyboardKeyCell.h"
#import "WUEmoticonsKeyboardKeysPageFlowLayout.h"

@implementation WUEmoticonsKeyboardKeyItemGroup
@synthesize keyItemCellClass = _keyItemCellClass;

- (Class)keyItemCellClass {
    if (!_keyItemCellClass) {
        _keyItemCellClass = [WUEmoticonsKeyboardKeyCell class];
    }
    return _keyItemCellClass;
}

- (UICollectionViewLayout *)keyItemsLayout {
    if (!_keyItemsLayout) {
        _keyItemsLayout = [WUEmoticonsKeyboardKeysPageFlowLayout defaultLayoutForUIInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
    }
    return _keyItemsLayout;
}

- (void)setKeyItemCellClass:(Class)keyItemCellClass {
    if ([keyItemCellClass isSubclassOfClass:[WUEmoticonsKeyboardKeyCell class]]) {
        _keyItemCellClass = keyItemCellClass;
    }else{
        NSAssert(NO, @"WUEmoticonsKeyboardKeyItemGroup: Setting keyItemCellClass - keyItemCellClass must be a subclass of WUEmoticonsKeyboardKeyCell.class");
    }
}

@end
