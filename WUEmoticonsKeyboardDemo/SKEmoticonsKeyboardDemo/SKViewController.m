//
//  SKViewController.m
//  SKEmoticonsKeyboardDemo
//
//  Created by shrek wang on 11/9/14.
//  Copyright (c) 2014 YuAo. All rights reserved.
//

#import "SKViewController.h"

#import "SKEmoticonsControlView.h"

#import "WUEmoticonsKeyboardKeysPageFlowLayout.h"
#import "WUDemoKeyboardTextKeyCell.h"
#import "WUDemoKeyboardPressedCellPopupView.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface SKViewController () <SKEmoticonsControlViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *editor;

@property (strong, nonatomic) SKEmoticonsControlView *emoticonKeyboard;

@property (weak, nonatomic) WUDemoKeyboardPressedCellPopupView *pressedKeyCellPopupView;

@end

@implementation SKViewController

#pragma mark - life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.emoticonKeyboard = [self createEmoticonsKeyboard];
    self.emoticonKeyboard.delegate = self;
    
    // install key popup view
    WUDemoKeyboardPressedCellPopupView *pressedKeyCellPopupView;
    pressedKeyCellPopupView = [[WUDemoKeyboardPressedCellPopupView alloc] initWithFrame:CGRectMake(0, 0, 83, 110)];
    pressedKeyCellPopupView.hidden = YES;
    [self.emoticonKeyboard addSubview:pressedKeyCellPopupView];
    self.pressedKeyCellPopupView = pressedKeyCellPopupView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (SKEmoticonsControlView *)createEmoticonsKeyboard
{
    SKEmoticonsControlView *keyboard = [[SKEmoticonsControlView alloc] initWithFrame:CGRectMake(0, 0, 320, 220)];
    keyboard.backgroundColor = [UIColor whiteColor];
    
    //Icon keys
    WUEmoticonsKeyboardKeyItem *loveKey = [[WUEmoticonsKeyboardKeyItem alloc] init];
    loveKey.image = [UIImage imageNamed:@"love"];
    loveKey.textToInput = @"[love]";
    
    WUEmoticonsKeyboardKeyItem *applaudKey = [[WUEmoticonsKeyboardKeyItem alloc] init];
    applaudKey.image = [UIImage imageNamed:@"applaud"];
    applaudKey.textToInput = @"[applaud]";
    
    WUEmoticonsKeyboardKeyItem *weicoKey = [[WUEmoticonsKeyboardKeyItem alloc] init];
    weicoKey.image = [UIImage imageNamed:@"weico"];
    weicoKey.textToInput = @"[weico]";
    
    //Icon key group
    WUEmoticonsKeyboardKeyItemGroup *imageIconsGroup = [[WUEmoticonsKeyboardKeyItemGroup alloc] init];
    imageIconsGroup.keyItems = @[loveKey,applaudKey,weicoKey,loveKey,applaudKey,weicoKey,loveKey,applaudKey,weicoKey,loveKey,applaudKey,weicoKey,loveKey,applaudKey,weicoKey,loveKey,applaudKey,weicoKey,loveKey,applaudKey,weicoKey,loveKey,applaudKey,weicoKey,loveKey,applaudKey,weicoKey,loveKey,applaudKey,weicoKey];
    UIImage *keyboardEmotionImage = [UIImage imageNamed:@"keyboard_emotion"];
    UIImage *keyboardEmotionSelectedImage = [UIImage imageNamed:@"keyboard_emotion_selected"];
    if ([UIImage instancesRespondToSelector:@selector(imageWithRenderingMode:)]) {
        keyboardEmotionImage = [keyboardEmotionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        keyboardEmotionSelectedImage = [keyboardEmotionSelectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    imageIconsGroup.image = keyboardEmotionImage;
//    imageIconsGroup.selectedImage = keyboardEmotionSelectedImage;
    
    //Text keys
    NSArray *textKeys = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EmotionTextKeys" ofType:@"plist"]];
    
    NSMutableArray *textKeyItems = [NSMutableArray array];
    for (NSString *text in textKeys) {
        WUEmoticonsKeyboardKeyItem *keyItem = [[WUEmoticonsKeyboardKeyItem alloc] init];
        keyItem.title = text;
        keyItem.textToInput = text;
        [textKeyItems addObject:keyItem];
    }
    
    //Text key group
    WUEmoticonsKeyboardKeysPageFlowLayout *textIconsLayout = [[WUEmoticonsKeyboardKeysPageFlowLayout alloc] init];
    textIconsLayout.itemSize = CGSizeMake(80, 142/3.0);
    textIconsLayout.itemSpacing = 0;
    textIconsLayout.lineSpacing = 0;
    textIconsLayout.pageContentInsets = UIEdgeInsetsMake(0,0,0,0);
    
    WUEmoticonsKeyboardKeyItemGroup *textIconsGroup = [[WUEmoticonsKeyboardKeyItemGroup alloc] init];
    textIconsGroup.keyItems = textKeyItems;
    textIconsGroup.keyItemsLayout = textIconsLayout;
    textIconsGroup.keyItemCellClass = WUDemoKeyboardTextKeyCell.class;
    
    UIImage *keyboardTextImage = [UIImage imageNamed:@"keyboard_text"];
    UIImage *keyboardTextSelectedImage = [UIImage imageNamed:@"keyboard_text_selected"];
    if ([UIImage instancesRespondToSelector:@selector(imageWithRenderingMode:)]) {
        keyboardTextImage = [keyboardTextImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        keyboardTextSelectedImage = [keyboardTextSelectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    textIconsGroup.image = keyboardTextImage;
//    textIconsGroup.selectedImage = keyboardTextSelectedImage;
    
    //Set keyItemGroups
    keyboard.keyItemGroups = @[imageIconsGroup, textIconsGroup];
    
    //Setup cell popup view
    /*
     [keyboard setKeyItemGroupPressedKeyCellChangedBlock:^(WUEmoticonsKeyboardKeyItemGroup *keyItemGroup, WUEmoticonsKeyboardKeyCell *fromCell, WUEmoticonsKeyboardKeyCell *toCell) {
     [WUDemoKeyboardBuilder sharedEmotionsKeyboardKeyItemGroup:keyItemGroup pressedKeyCellChangedFromCell:fromCell toCell:toCell];
     }];
     */
    
    //Keyboard appearance
    
    //Custom text icons scroll background
    if (textIconsLayout.collectionView) {
        UIView *textGridBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [textIconsLayout collectionViewContentSize].width, [textIconsLayout collectionViewContentSize].height)];
        textGridBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textGridBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"keyboard_grid_bg"]];
        [textIconsLayout.collectionView addSubview:textGridBackgroundView];
    }
    
    //Custom utility keys
    [keyboard.leftButton setImage:[UIImage imageNamed:@"keyboard_switch"] forState:UIControlStateNormal];
    [keyboard.leftButton setImage:[UIImage imageNamed:@"keyboard_switch_pressed"] forState:UIControlStateHighlighted];
    [keyboard.leftButton addTarget:self action:@selector(switchBackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [keyboard.rightButton setImage:[UIImage imageNamed:@"keyboard_del"] forState:UIControlStateNormal];
    [keyboard.rightButton setImage:[UIImage imageNamed:@"keyboard_del_pressed"] forState:UIControlStateHighlighted];
    [keyboard.rightButton addTarget:self action:@selector(backspaceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    keyboard.segmentedControl.tintColor = [UIColor lightGrayColor];
    
    //Keyboard background
    /*
     [keyboard setBackgroundImage:[[UIImage imageNamed:@"keyboard_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
     */
    
    //SegmentedControl
    /*
     [[UISegmentedControl appearanceWhenContainedIn:[WUEmoticonsKeyboard class], nil] setBackgroundImage:[[UIImage imageNamed:@"keyboard_segment_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
     [[UISegmentedControl appearanceWhenContainedIn:[WUEmoticonsKeyboard class], nil] setBackgroundImage:[[UIImage imageNamed:@"keyboard_segment_selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
     [[UISegmentedControl appearanceWhenContainedIn:[WUEmoticonsKeyboard class], nil] setDividerImage:[UIImage imageNamed:@"keyboard_segment_normal_selected"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
     [[UISegmentedControl appearanceWhenContainedIn:[WUEmoticonsKeyboard class], nil] setDividerImage:[UIImage imageNamed:@"keyboard_segment_selected_normal"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
     */
    
    return keyboard;
}

#pragma mark - action

- (IBAction)emojiButtonPressed:(id)sender {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    view.backgroundColor = [UIColor blueColor];
    self.editor.inputView = self.emoticonKeyboard;
    [self.editor reloadInputViews];
    
    if (![self.editor isFirstResponder]) {
        [self.editor becomeFirstResponder];
    }
}

- (void)switchBackButtonPressed:(id)sender
{
    self.editor.inputView = nil;
    [self.editor reloadInputViews];
}

- (void)backspaceButtonPressed:(id)sender
{
    [self.editor deleteBackward];
}

#pragma mark - SKEmoticonsControlDelegate

- (void)keyItemGroup:(WUEmoticonsKeyboardKeyItemGroup *)keyItemGroup keyItemTapped:(WUEmoticonsKeyboardKeyItem *)keyItem
{
    NSTextAttachment *attach = [[NSTextAttachment alloc] initWithData:UIImagePNGRepresentation(keyItem.image) ofType:(__bridge NSString *)kUTTypePNG];
    attach.bounds = CGRectMake(0, 0, 16, 16);
    NSAttributedString *attributedText = [NSAttributedString attributedStringWithAttachment:attach];
    
    // insert attributed text
    NSRange selectedRange = self.editor.selectedRange;
    [self.editor.textStorage beginEditing];
    [self.editor.textStorage replaceCharactersInRange:selectedRange withAttributedString:attributedText];
    self.editor.selectedRange = NSMakeRange(selectedRange.location + [attributedText length], 0);
    [self.editor.textStorage endEditing];
    
}

- (void)keyItemGroup:(WUEmoticonsKeyboardKeyItemGroup *)keyItemGroup pressedKeyCellChangedFrom:(WUEmoticonsKeyboardKeyCell *)fromKeyCell to:(WUEmoticonsKeyboardKeyCell *)toKeyCell
{
    if ([self.emoticonKeyboard.keyItemGroups indexOfObject:keyItemGroup] == 0) {
        [self.emoticonKeyboard bringSubviewToFront:self.pressedKeyCellPopupView];
        if (toKeyCell) {
            self.pressedKeyCellPopupView.keyItem = toKeyCell.keyItem;
            self.pressedKeyCellPopupView.hidden = NO;
            CGRect frame = [self.emoticonKeyboard convertRect:toKeyCell.bounds fromView:toKeyCell];
            self.pressedKeyCellPopupView.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame)-CGRectGetHeight(self.pressedKeyCellPopupView.frame)/2);
        } else {
            self.pressedKeyCellPopupView.hidden = YES;
        }
    }
}


@end
