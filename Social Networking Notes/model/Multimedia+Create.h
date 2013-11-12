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
 This method creates (save to database) a Multimedia to you with provided server info. You should @b never use this method to perform @b query; use @e Note's relationship instead. The relationships of Contact will be managed by @em Note(Creation). @see ServerCommunicatior.h
 @param multimediaDictionary
 Please use the @e ServerCommunicator.h defined key in @e NSDictionary.
 @param data
 The real data stored in @e NSData awaiting to save to disk. Psas @b nill to perform query only.
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

- (NSString *)localURL;

@end
