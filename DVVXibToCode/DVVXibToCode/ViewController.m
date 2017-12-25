//
//  ViewController.m
//  DVVXibToCode
//
//  Created by dawei on 2017/11/16.
//  Copyright © 2017年 devdawei. All rights reserved.
//

#import "ViewController.h"
#import "DVVCover.h"

@interface ViewController ()

@property (weak) IBOutlet NSTextField *xibFilePathTextField;
@property (weak) IBOutlet NSComboBox *xibFileTypeComboBox;
@property (weak) IBOutlet NSButton *coverButton;
@property (unsafe_unretained) IBOutlet NSTextView *contentTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (IBAction)coverButtonAction:(NSButton *)sender {
    
    NSString *path = self.xibFilePathTextField.stringValue;
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

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
