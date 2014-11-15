//
//  SKEmoticonsKeyboardItemGroupView.m
//  WUEmoticonsKeyboardDemo
//
//  Created by shrek wang on 11/15/14.
//  Copyright (c) 2014 YuAo. All rights reserved.
//

#import "SKEmoticonsKeyboardItemGroupView.h"

#import "WUEmoticonsKeyboardKeyCell.h"
#import "WUEmoticonsKeyboardKeyItem.h"
#import "WUEmoticonsKeyboardKeyCell.h"
#import "WUKeyboardPressedCellPopupView.h"

CGFloat const SKEmoticonsKeyboardKeyItemGroupViewPageControlHeight = 23;

@interface SKEmoticonsKeyboardItemGroupView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic,weak)              UICollectionView             *collectionView;
@property (nonatomic,weak)              UIPageControl                *pageControl;
@property (nonatomic,weak)              WUEmoticonsKeyboardKeyCell   *lastPressedCell;
@property (nonatomic,weak)              UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic,weak,readwrite)    UIImageView        *backgroundImageView;

@property (nonatomic, weak) WUKeyboardPressedCellPopupView *pressedKeyCellPopupView;

@end

@implementation SKEmoticonsKeyboardItemGroupView

- (void)setKeyItemGroup:(WUEmoticonsKeyboardKeyItemGroup *)keyItemGroup {
    _keyItemGroup = keyItemGroup;
    self.collectionView.collectionViewLayout = self.keyItemGroup.keyItemsLayout;
    [self.collectionView registerClass:self.keyItemGroup.keyItemCellClass forCellWithReuseIdentifier:NSStringFromClass(self.keyItemGroup.keyItemCellClass)];
    [self.collectionView reloadData];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // background view
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:backgroundImageView];
        self.backgroundImageView = backgroundImageView;
        
        // page control
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), SKEmoticonsKeyboardKeyItemGroupViewPageControlHeight)];
        pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        pageControl.userInteractionEnabled = NO;
        pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        [self addSubview:pageControl];
        self.pageControl = pageControl;
        
        // collection view
        UICollectionViewLayout *layout = [[UICollectionViewLayout alloc] init];
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, SKEmoticonsKeyboardKeyItemGroupViewPageControlHeight, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - SKEmoticonsKeyboardKeyItemGroupViewPageControlHeight) collectionViewLayout:layout];
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.pagingEnabled = YES;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        
        // pressed pop up view
        WUKeyboardPressedCellPopupView *pressedKeyCellPopupView;
        pressedKeyCellPopupView = [[WUKeyboardPressedCellPopupView alloc] initWithFrame:CGRectMake(0, 0, 83, 110)];
        pressedKeyCellPopupView.hidden = YES;
        [self addSubview:pressedKeyCellPopupView];
        self.pressedKeyCellPopupView = pressedKeyCellPopupView;
    }
    return self;
}

- (void)setPopupViewWhenCellPressed:(BOOL)popupViewWhenCellPressed
{
    if (NO == _popupViewWhenCellPressed && YES == popupViewWhenCellPressed) {
        // NO -> YES
        [self setupLongPressGestureRecognizer];
        _popupViewWhenCellPressed = popupViewWhenCellPressed;
    } else if (YES == _popupViewWhenCellPressed && NO == popupViewWhenCellPressed) {
        // YES -> NO
        [self removeLongPressGestureRecognizer];
        _popupViewWhenCellPressed = popupViewWhenCellPressed;
    }
}

- (void)setupLongPressGestureRecognizer
{
    if (!self.longPressGestureRecognizer) {
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewLongPress:)];
        longPressGestureRecognizer.minimumPressDuration = 0.2;
        [self.collectionView addGestureRecognizer:longPressGestureRecognizer];
        self.longPressGestureRecognizer = longPressGestureRecognizer;
    }
}

- (void)removeLongPressGestureRecognizer
{
    if (self.longPressGestureRecognizer) {
        [self.collectionView removeGestureRecognizer:self.longPressGestureRecognizer];
    }
}

#pragma mark - Long Press

- (void)collectionViewLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint touchedLocation = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *__block touchedIndexPath = [NSIndexPath indexPathForItem:NSNotFound inSection:NSNotFound];
    [self.collectionView.indexPathsForVisibleItems enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        if (CGRectContainsPoint([[self.collectionView layoutAttributesForItemAtIndexPath:indexPath] frame], touchedLocation)) {
            touchedIndexPath = indexPath;
            *stop = YES;
        }
    }];
    
    if (touchedIndexPath.item == NSNotFound || gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self keyItemCellPressedFrom:self.lastPressedCell to:nil];
        [self.lastPressedCell setSelected:NO];
        self.lastPressedCell = nil;
        
        if (touchedIndexPath.item != NSNotFound) {
            [self.delegate groupView:self didSelectItemAtIndex:touchedIndexPath.item];
        }
    }else{
        [self.lastPressedCell setSelected:NO];
        WUEmoticonsKeyboardKeyCell *pressedCell = (WUEmoticonsKeyboardKeyCell *)[self.collectionView cellForItemAtIndexPath:touchedIndexPath];
        [pressedCell setSelected:YES];
        
        [self keyItemCellPressedFrom:self.lastPressedCell to:pressedCell];
        self.lastPressedCell = pressedCell;
    }
}

- (void)keyItemCellPressedFrom:(WUEmoticonsKeyboardKeyCell *)fromCell to:(WUEmoticonsKeyboardKeyCell *)toCell
{
    [self bringSubviewToFront:self.pressedKeyCellPopupView];
    if (toCell) {
        self.pressedKeyCellPopupView.keyItem = toCell.keyItem;
        self.pressedKeyCellPopupView.hidden = NO;
        CGRect frame = [self convertRect:toCell.bounds fromView:toCell];
        self.pressedKeyCellPopupView.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame)-CGRectGetHeight(self.pressedKeyCellPopupView.frame)/2);
    } else {
        self.pressedKeyCellPopupView.hidden = YES;
    }
}

#pragma mark - CollectionView Datasource

- (void)refreshPageControl {
    self.pageControl.numberOfPages = ceil(self.collectionView.contentSize.width / CGRectGetWidth(self.collectionView.bounds));
    self.pageControl.currentPage = floor(self.collectionView.contentOffset.x / CGRectGetWidth(self.collectionView.bounds));
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self refreshPageControl];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshPageControl];
    });
    return self.keyItemGroup.keyItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WUEmoticonsKeyboardKeyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(self.keyItemGroup.keyItemCellClass) forIndexPath:indexPath];
    cell.keyItem = self.keyItemGroup.keyItems[indexPath.row];
    return cell;
}


#pragma mark - CollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self.delegate groupView:self didSelectItemAtIndex:indexPath.row];
}

@end
