//
//  Multimedia+Create.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/20.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "Multimedia.h"

typedef enum {
	MultimediaTypePicturePNG,
	MultimediaTypePictureJPEG,
	MultimediaTypeVideo,
} MultimediaType;

@interface Multimedia (Create)

/**
 This method creates (also save data to database if needed) a Multimedia with provided server info. The relationships of Contact will be managed by @em Note(Creation). @see ServerCommunicatior.h
 @param multimediaDictionary
 Please use the @e ServerCommunicator.h defined key in @e NSDictionary. This dictionary should at least contain @b ServerMediaFileName to perform @b query; if create or modify is needed, you need to provide all ServerMedia* for creation, or partial ServerMedia* for modification. Note that @b ServerMediaType is now ignored since it's under development.
 @param data
 The real data stored in @e NSData awaiting to save to disk. Psas @b nil if you have handled the file in the -localURL.
 @param context
 Specify in which @e NSManagedObjectContext should be saved.
 @return Returns a new or queried Contact
 */

+ (instancetype)multimediaWithServerInfo:(NSDictionary *)multimediaDictionary
									data:(NSData *)data
				  inManagedObjectContext:(NSManagedObjectContext *)context;

/**
 Use this method to get the @e NSData
 @return the saved-to-disk data
 */
- (NSData *)data;

- (UIImage *)image;

- (NSString *)localURL;

@end
