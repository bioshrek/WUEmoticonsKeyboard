//
//  SKEmoticonsControlView.m
//  WUEmoticonsKeyboardDemo
//
//  Created by shrek wang on 11/8/14.
//  Copyright (c) 2014 YuAo. All rights reserved.
//

#import "SKEmoticonsControlView.h"

#import "SKEmoticonsKeyboardItemGroupView.h"

// constants: layout constants
static CGFloat const kToolbarHeight = 45.0f;
static CGFloat const kGroupViewPortraitOrientationHeight = 171.0f;
static CGFloat const kGroupViewLandscapeOrientationHeight = 125.0f;

@interface SKEmoticonsControlView () <SKEmoticonsKeyboardItemGroupViewDelegate>

@property (weak, nonatomic) SKEmoticonsKeyboardItemGroupView *currentKeyItemGroupView;
@property (nonatomic,strong) NSArray *keyItemGroupViews;


@end

@implementation SKEmoticonsControlView

#pragma mark - life cycle

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    // toolbar
    UIView *toolbar = [self createToolbar];
    [self addSubview:toolbar];
    self.toolbar = toolbar;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat groupViewHeight = [self groupViewHeight];
    
    // self
    CGRect bounds = CGRectMake(0,
                               0,
                               CGRectGetWidth(self.superview.bounds),
                               groupViewHeight + 1 + kToolbarHeight);
    self.bounds = bounds;
    
    // toolbar
    self.toolbar.frame = CGRectMake(0, groupViewHeight + 1, CGRectGetWidth(bounds), kToolbarHeight);
    CGSize toolbarSize = self.toolbar.bounds.size;
    
    // left button
    [self.leftButton sizeToFit];
    CGSize leftButtonSize = self.leftButton.bounds.size;
    self.leftButton.center = CGPointMake(leftButtonSize.width / 2, toolbarSize.height / 2);
    
    // right button
    [self.rightButton sizeToFit];
    CGSize rightButtonSize = self.rightButton.bounds.size;
    self.rightButton.center = CGPointMake(toolbarSize.width - rightButtonSize.width / 2,
                                          toolbarSize.height / 2);
    
    // segment button
    self.segmentedControl.frame = CGRectMake(0, 0, toolbarSize.width - leftButtonSize.width - rightButtonSize.width - 2, leftButtonSize.height);
    self.segmentedControl.center = CGPointMake(toolbarSize.width / 2, toolbarSize.height / 2);
    
    // keyItemGroupView
    self.currentKeyItemGroupView.frame = [self rectForKeyItemGroupViewWithHeight:groupViewHeight];
}

- (CGRect)rectForKeyItemGroupViewWithHeight:(CGFloat)height
{
    return CGRectMake(0, 0, CGRectGetWidth(self.superview.bounds), height);
}

- (CGFloat)groupViewHeight
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    return (UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation) ? kGroupViewLandscapeOrientationHeight : kGroupViewPortraitOrientationHeight;
}

- (UIView *)createToolbar
{
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectZero];
    
    // left button
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    [toolbar addSubview:leftButton];
    self.leftButton = leftButton;
    
    // middle segment control
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectZero];
    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [toolbar addSubview:segmentedControl];
    self.segmentedControl = segmentedControl;
    
    // right button
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [toolbar addSubview:rightButton];
    self.rightButton = rightButton;
    
    return toolbar;
}

#pragma mark - segment control

- (void)setKeyItemGroups:(NSArray *)keyItemGroups {
    _keyItemGroups = [keyItemGroups copy];
    [self reloadKeyItemGroupViews];
    [self reloadToolbar];
    [self selectSegmentAtIndex:0];
}

- (void)reloadKeyItemGroupViews {
    self.keyItemGroupViews = nil;
    NSMutableArray *keyItemGroupViews = [NSMutableArray array];
    [self.keyItemGroups enumerateObjectsUsingBlock:^(WUEmoticonsKeyboardKeyItemGroup *keyItemGroup, NSUInteger idx, BOOL *stop) {
        SKEmoticonsKeyboardItemGroupView *keyItemGroupView = [[SKEmoticonsKeyboardItemGroupView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), [self groupViewHeight])];
        keyItemGroupView.keyItemGroup = keyItemGroup;
        keyItemGroupView.delegate = self;
        keyItemGroupView.popupViewWhenCellPressed = keyItemGroup.popupViewWhenKeyCellPressed;
        keyItemGroupView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [keyItemGroupViews addObject:keyItemGroupView];
    }];
    self.keyItemGroupViews = keyItemGroupViews;
}

- (void)reloadToolbar
{
    [self.segmentedControl removeAllSegments];
    [self.keyItemGroups enumerateObjectsUsingBlock:^(WUEmoticonsKeyboardKeyItemGroup *keyItemGroup, NSUInteger idx, BOOL *stop) {
        if (keyItemGroup.image) {
            [self.segmentedControl insertSegmentWithImage:keyItemGroup.image atIndex:self.segmentedControl.numberOfSegments animated:NO];
        }else{
            [self.segmentedControl insertSegmentWithTitle:keyItemGroup.title atIndex:self.segmentedControl.numberOfSegments animated:NO];
        }
    }];
    if (self.segmentedControl.numberOfSegments) {
        self.segmentedControl.selectedSegmentIndex = 0;
        [self segmentedControlValueChanged:self.segmentedControl];
    }
    
    if (self.keyItemGroups.count > 1) {
        self.segmentedControl.hidden = NO;
    } else {
        self.segmentedControl.hidden = YES;
    }
}

- (void)selectSegmentAtIndex:(NSUInteger)index
{
    NSUInteger numberOfSegments = [self.segmentedControl numberOfSegments];
    if (index < numberOfSegments) {
        [self.segmentedControl setSelectedSegmentIndex:index];
    }
}

- (void)segmentedControlValueChanged:(UISegmentedControl *)sender {
    // apply selected style
    [self.keyItemGroups enumerateObjectsUsingBlock:^(WUEmoticonsKeyboardKeyItemGroup *keyItemGroup, NSUInteger idx, BOOL *stop) {
        if (keyItemGroup.image) {
            if (keyItemGroup.selectedImage && (NSInteger)idx == self.segmentedControl.selectedSegmentIndex) {
                [self.segmentedControl setImage:keyItemGroup.selectedImage forSegmentAtIndex:idx];
            } else {
                [self.segmentedControl setImage:keyItemGroup.image forSegmentAtIndex:idx];
            }
        } else {
            [self.segmentedControl setTitle:keyItemGroup.title forSegmentAtIndex:idx];
        }
    }];
    
    SKEmoticonsKeyboardItemGroupView *newView = self.keyItemGroupViews[self.segmentedControl.selectedSegmentIndex];
    self.currentKeyItemGroupView = newView;
}

- (void)setCurrentKeyItemGroupView:(SKEmoticonsKeyboardItemGroupView *)currentKeyItemGroupView
{
    if (_currentKeyItemGroupView) {
        [_currentKeyItemGroupView removeFromSuperview];
    }
    
    _currentKeyItemGroupView = currentKeyItemGroupView;
    
    self.currentKeyItemGroupView.frame = [self rectForKeyItemGroupViewWithHeight:[self groupViewHeight]];
    [self addSubview:currentKeyItemGroupView];
}

#pragma mark - SKEmoticonsKeyboardItemGroupView Delegate

- (void)groupView:(SKEmoticonsKeyboardItemGroupView *)groupView didSelectItemAtIndex:(NSUInteger)index
{
    NSUInteger groupIndex = [self.keyItemGroupViews indexOfObject:groupView];
    if (NSNotFound != groupIndex) {
        [self.delegate keyItemTappedInGroupIndex:groupIndex itemIndex:index];
    }
}

@end
