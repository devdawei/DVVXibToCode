//
//  DVVXibToCodeViewController.m
//  DVVXibToCode
//
//  Created by dawei on 2017/12/27.
//  Copyright © 2017年 devdawei. All rights reserved.
//

#import "DVVXibToCodeViewController.h"
#import "PureLayout.h"
#import "DVVCover.h"

@interface DVVXibToCodeViewController ()

@property (strong) NSTextField *xibFilePathTextField;
@property (strong) NSComboBox *xibFileTypeComboBox;
@property (strong) NSButton *coverButton;
@property (strong) NSScrollView *contentScrollView;
@property (strong) NSTextView *contentTextView;

@end

@implementation DVVXibToCodeViewController

#pragma mark -

+ (void)showFromViewController:(NSViewController *)viewController {
    
    DVVXibToCodeViewController *xibToCodeVC = [[DVVXibToCodeViewController alloc] init];
    
    NSWindow *window = [NSWindow windowWithContentViewController:xibToCodeVC];
    window.title = @"DVVXibToCode";
    [window setContentSize:CGSizeMake(600, 800)];
    
    NSWindowController *windowController = [[NSWindowController alloc] initWithWindow:window];
    
    [windowController.window makeKeyAndOrderFront:nil];
    [windowController.window center];
    
    [viewController.view.window orderOut:nil];
}

#pragma mark -

- (void)loadView {
    self.view = [[NSView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.xibFilePathTextField = [[NSTextField alloc] init];
    self.xibFilePathTextField.placeholderString = @"Xib File Path";
    
    self.xibFileTypeComboBox = [[NSComboBox alloc] init];
    self.xibFileTypeComboBox.placeholderString = @"Xib File Type";
    NSArray *comboBoxItemsArray = @[
                                    @"UIView",
                                    @"UIViewController",
                                    @"UITableViewCell",
                                    @"UICollectionViewCell",
                                    ];
    [self.xibFileTypeComboBox addItemsWithObjectValues:comboBoxItemsArray];
    
    self.coverButton = [NSButton buttonWithTitle:@"转换" target:self action:@selector(coverButtonClickAction)];
    
    self.contentScrollView = [[NSScrollView alloc] init];
    self.contentScrollView.hasVerticalScroller = YES;
    
    self.contentTextView = [[NSTextView alloc] init];
    self.contentTextView.autoresizingMask = NSViewWidthSizable;
    
    [self.view addSubview:self.xibFilePathTextField];
    [self.view addSubview:self.xibFileTypeComboBox];
    [self.view addSubview:self.coverButton];
    [self.view addSubview:self.contentScrollView];
    self.contentScrollView.documentView = self.contentTextView;
    
    [self.xibFilePathTextField autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    [self.xibFilePathTextField autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [self.xibFilePathTextField autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
    
    [self.xibFileTypeComboBox autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [self.xibFileTypeComboBox autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.xibFilePathTextField withOffset:8];
    [self.xibFileTypeComboBox autoSetDimension:ALDimensionWidth toSize:180];
    
    [self.coverButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
    [self.coverButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.xibFileTypeComboBox];
    [self.coverButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.xibFileTypeComboBox];
    
    [self.contentScrollView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.coverButton withOffset:20];
    [self.contentScrollView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20];
    [self.contentScrollView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [self.contentScrollView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillCloseNotification:) name:NSWindowWillCloseNotification object:nil];
}

#pragma mark -

- (void)windowWillCloseNotification:(NSNotification *)notification {
    
    NSWindow *window = notification.object;
    if ([[NSString stringWithFormat:@"%p", window] isEqualToString:[NSString stringWithFormat:@"%p", self.view.window]]) {
        [NSApp terminate:nil];
    }
}

#pragma mark -

- (void)coverButtonClickAction {
    
    NSString *path = self.xibFilePathTextField.stringValue;
    if (!path || [path isKindOfClass:[NSNull class]] || path.length == 0) {
        return;
    }
    
    NSString *xibFileTypeComboBoxStringValue = self.xibFileTypeComboBox.stringValue;
    DVVCoverXibType type = DVVCoverXibTypeUIView;
    if ([xibFileTypeComboBoxStringValue isEqualToString:@"UIView"]) {
        type = DVVCoverXibTypeUIView;
    } else if ([xibFileTypeComboBoxStringValue isEqualToString:@"UIViewController"]) {
        type = DVVCoverXibTypeUIViewController;
    } else if ([xibFileTypeComboBoxStringValue isEqualToString:@"UITableViewCell"]) {
        type = DVVCoverXibTypeUITableViewCell;
    } else if ([xibFileTypeComboBoxStringValue isEqualToString:@"UICollectionViewCell"]) {
        type = DVVCoverXibTypeUICollectionViewCell;
    }
    
    DVVCover *cover = [[DVVCover alloc] init];
    self.contentTextView.string = [cover coverAtPath:path xibType:type];
}

@end

