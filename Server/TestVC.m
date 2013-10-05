//
//  TestVC.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/5.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "TestVC.h"

@interface TestVC ()
- (IBAction)buttonTapped;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation TestVC

- (IBAction)buttonTapped {
	DatabaseManagedDocument *dmd = [DatabaseManagedDocument new];
}

@end
