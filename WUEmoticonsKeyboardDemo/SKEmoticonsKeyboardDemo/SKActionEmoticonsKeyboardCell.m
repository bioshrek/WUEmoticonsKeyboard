//
//  SKActionEmoticonsKeyboardCell.m
//  WUEmoticonsKeyboardDemo
//
//  Created by shrek wang on 11/16/14.
//  Copyright (c) 2014 YuAo. All rights reserved.
//

#import "SKActionEmoticonsKeyboardCell.h"

@implementation SKActionEmoticonsKeyboardCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    view.backgroundColor = [UIColor orangeColor];
    self.backgroundView = view;
    
    UIView *view2 = [[UIView alloc] initWithFrame:self.bounds];
    view2.backgroundColor = [UIColor greenColor];
    self.selectedBackgroundView = view2;
}

@end
