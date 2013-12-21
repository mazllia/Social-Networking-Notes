//
//  Multimedia+QuickLook.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/12/9.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "Multimedia+QuickLook.h"

@implementation Multimedia (QuickLook)

- (NSURL *)previewItemURL
{
	NSError *err;
	NSURL *url = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&err];
	if (err)
		[[NSException exceptionWithName:@"Multimedia(QuickLook) error" reason:err.localizedDescription userInfo:nil] raise];
	return [url URLByAppendingPathComponent:self.fileName];
}

@end
