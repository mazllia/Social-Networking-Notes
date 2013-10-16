//
//  NSObject+ClassName.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/15.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "NSObject+ClassName.h"

@implementation NSObject (ClassName)

+ (NSString *)className
{
	return [[self class] description];
}

+ (NSString *)superClassName
{
	return [[super class] description];
}

@end
