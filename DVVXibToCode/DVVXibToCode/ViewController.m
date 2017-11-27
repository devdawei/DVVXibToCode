//
//  ViewController.m
//  DVVXibToCode
//
//  Created by dawei on 2017/11/16.
//  Copyright © 2017年 devdawei. All rights reserved.
//

#import "ViewController.h"
#import "Cover.h"

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
    CoverXibType type = CoverXibTypeUIView;
    if ([xibFileTypeComboBoxStringValue isEqualToString:@"UIView"]) {
        type = CoverXibTypeUIView;
    } else if ([xibFileTypeComboBoxStringValue isEqualToString:@"UIViewController"]) {
        type = CoverXibTypeUIViewController;
    } else if ([xibFileTypeComboBoxStringValue isEqualToString:@"UITableViewCell"]) {
        type = CoverXibTypeUITableViewCell;
    } else if ([xibFileTypeComboBoxStringValue isEqualToString:@"UICollectionViewCell"]) {
        type = CoverXibTypeUICollectionViewCell;
    }
    
    Cover *cover = [[Cover alloc] init];
    self.contentTextView.string = [cover coverAtPath:path xibType:type];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
