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

#import "SKEmoticonsKeyboardItemGroupView.h"

#import "SKActionEmoticonsKeyboardLayout.h"

#import "SKActionEmoticonsKeyboardCell.h"


#import <MobileCoreServices/MobileCoreServices.h>

@interface SKViewController () <SKEmoticonsControlViewDelegate, SKEmoticonsKeyboardItemGroupViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *editor;

@property (strong, nonatomic) SKEmoticonsControlView *emoticonKeyboard;

@property (nonatomic, strong) WUEmoticonsKeyboardKeyItemGroup *iconKeyItemGroup;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (weak, nonatomic) SKEmoticonsKeyboardItemGroupView *moreActionGroupView;

@property (nonatomic, assign, getter = isEditorFirstResponder) BOOL editorFirstResponder;

@end

@implementation SKViewController

#pragma mark - life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.emoticonKeyboard = [self createEmoticonsKeyboard];
    self.emoticonKeyboard.delegate = self;
    
    SKEmoticonsKeyboardItemGroupView *groupView = [self createMoreActionGroupView];
    [self.view addSubview:groupView];
    groupView.hidden = YES;
    self.moreActionGroupView = groupView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.emoticonKeyboard = nil;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.editor reloadInputViews];
    NSLog(@"did rotate");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"view did appear");
}

- (SKEmoticonsControlView *)createEmoticonsKeyboard
{
    SKEmoticonsControlView *keyboard = [[SKEmoticonsControlView alloc] initWithFrame:CGRectMake(0, 0, 320, 220)];
    
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
    imageIconsGroup.selectedImage = keyboardEmotionSelectedImage;
    imageIconsGroup.popupViewWhenKeyCellPressed = YES;
    self.iconKeyItemGroup = imageIconsGroup;
    
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
    
    //Keyboard appearance
    
    //Custom text icons scroll background
    if (textIconsLayout.collectionView) {
        UIView *textGridBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [textIconsLayout collectionViewContentSize].width, [textIconsLayout collectionViewContentSize].height)];
        textGridBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textGridBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"keyboard_grid_bg"]];
        [textIconsLayout.collectionView addSubview:textGridBackgroundView];
    }
    
    //Custom utility keys
    [keyboard.leftButton setBackgroundColor:[UIColor whiteColor]];
    [keyboard.leftButton setBackgroundImage:[UIImage imageNamed:@"gray-background"] forState:UIControlStateHighlighted];
    [keyboard.leftButton setImage:[UIImage imageNamed:@"keyboard_switch"] forState:UIControlStateNormal];
    [keyboard.leftButton setImage:[UIImage imageNamed:@"keyboard_switch_pressed"] forState:UIControlStateHighlighted];
    [keyboard.leftButton addTarget:self action:@selector(switchBackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [keyboard.rightButton setBackgroundColor:[UIColor whiteColor]];
    [keyboard.rightButton setImage:[UIImage imageNamed:@"keyboard_del"] forState:UIControlStateNormal];
    [keyboard.rightButton setImage:[UIImage imageNamed:@"keyboard_del_pressed"] forState:UIControlStateHighlighted];
    [keyboard.rightButton setBackgroundImage:[UIImage imageNamed:@"gray-background"] forState:UIControlStateHighlighted];
    [keyboard.rightButton addTarget:self action:@selector(backspaceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    keyboard.segmentedControl.tintColor = [UIColor lightGrayColor];
    [keyboard.segmentedControl setBackgroundImage:[UIImage imageNamed:@"white-background"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    keyboard.toolbar.backgroundColor = [UIColor whiteColor];
    keyboard.backgroundColor = [UIColor redColor];
    
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


- (SKEmoticonsKeyboardItemGroupView *)createMoreActionGroupView
{
    // key items
    WUEmoticonsKeyboardKeyItemGroup *keyItemGroup = [[WUEmoticonsKeyboardKeyItemGroup alloc] init];
    keyItemGroup.keyItemCellClass = [SKActionEmoticonsKeyboardCell class];
    
    WUEmoticonsKeyboardKeyItem *photoActionItem = [[WUEmoticonsKeyboardKeyItem alloc] init];
    photoActionItem.image = [UIImage imageNamed:@"photo"];
    
    WUEmoticonsKeyboardKeyItem *videoActionItem = [[WUEmoticonsKeyboardKeyItem alloc] init];
    videoActionItem.image = [UIImage imageNamed:@"video"];
    
    WUEmoticonsKeyboardKeyItem *locationActionItem = [[WUEmoticonsKeyboardKeyItem alloc] init];
    locationActionItem.image = [UIImage imageNamed:@"location"];
    
    keyItemGroup.keyItems = @[photoActionItem, videoActionItem, locationActionItem];
    
    // layout
    SKActionEmoticonsKeyboardLayout *layout = [[SKActionEmoticonsKeyboardLayout alloc] init];
    layout.itemSize = CGSizeMake(64.0f, 64.0f);
    layout.itemSpacing = 30;
    layout.lineSpacing = 20;
    layout.pageContentInsets = UIEdgeInsetsMake(30, 30, 30, 30);
    keyItemGroup.keyItemsLayout = layout;
    
    // group view
    CGRect frameOfToolbar = self.toolbar.frame;
    CGFloat maxYOfToolbar = CGRectGetMaxY(frameOfToolbar);
    SKEmoticonsKeyboardItemGroupView *groupView =
        [[SKEmoticonsKeyboardItemGroupView alloc] initWithFrame:CGRectMake(CGRectGetMinX(frameOfToolbar),
                                                                           maxYOfToolbar,
                                                                           CGRectGetWidth(frameOfToolbar),
                                                                           CGRectGetHeight(self.view.bounds) - maxYOfToolbar)];
    groupView.keyItemGroup = keyItemGroup;
    groupView.delegate = self;
    groupView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    groupView.backgroundColor = [UIColor lightGrayColor];
    return groupView;
}

#pragma mark - action

- (IBAction)emojiButtonPressed:(id)sender {
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

- (IBAction)moreActionButtonPressed:(UIBarButtonItem *)sender {
    if (self.moreActionGroupView.hidden) {
        // backup editor state
        self.editorFirstResponder = [self.editor isFirstResponder];
        [self.editor resignFirstResponder];
        
        // show it
        self.moreActionGroupView.hidden = NO;
    } else {
        // hide it
        self.moreActionGroupView.hidden = YES;
        
        // restore editor state
        if (self.isEditorFirstResponder) {
            [self.editor becomeFirstResponder];
        }
    }
}

#pragma mark - SKEmoticonsControlDelegate

- (void)keyItemTappedInGroupIndex:(NSUInteger)groupIndex itemIndex:(NSUInteger)itemIndex
{
    NSLog(@"index: %d", (int)itemIndex);
    
    if (0 == groupIndex) {
        WUEmoticonsKeyboardKeyItem *keyItem = [self.iconKeyItemGroup.keyItems objectAtIndex:itemIndex];
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
}

#pragma mark - SKemoticonsKeyboardKeyItemGroupView Delegate

- (void)groupView:(SKEmoticonsKeyboardItemGroupView *)groupView didSelectItemAtIndex:(NSUInteger)index
{
    NSLog(@"action %d is clicked.", (int)index);
}

@end
