//
//  ViewController.m
//  DVVXibToCode
//
//  Created by dawei on 2017/11/16.
//  Copyright © 2017年 devdawei. All rights reserved.
//

#import "ViewController.h"
#import "DVVXibToCodeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    [DVVXibToCodeViewController showFromViewController:self];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
