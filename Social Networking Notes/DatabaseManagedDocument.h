//
//  DatabaseManagedDocument.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/9/16.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DatabaseManagedDocumentNotificationReady @"DatabaseManagedDocumentNotificationReady"

@class Contact;
@interface DatabaseManagedDocument : UIManagedDocument

- (id)initWithFileURL:(NSURL *)url;

// Singleton
+ (instancetype)sharedDatabase;
+ (instancetype)allocWithZone:(NSZone *)zone;
@end
