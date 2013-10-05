//
//  DatabaseManagedDocument.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/9/16.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Contact;
@interface DatabaseManagedDocument : UIManagedDocument
- (void)fetchFromServer;

+ (id)sharedDatabase;
+ (id)allocWithZone:(NSZone *)zone;
@end
