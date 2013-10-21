//
//  NSObject+ClassName.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/15.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ClassName)

/**
 Get the class name (e.g. NSArray, NSMutableDictionary) as a NSString
 */
+ (NSString *)className;

/**
 Get the class's superclass name (e.g. NSArray, NSMutableDictionary) as a NSString
 */
+ (NSString *)superClassName;

@end
