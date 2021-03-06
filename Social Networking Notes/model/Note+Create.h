//
//  Note+Create.h
//
//	1. Parse the JSON objects
//	2. Insert them into NSManagedObjectContext
//

#import "Note.h"

@interface Note (Create)

/**
 This method queries or creates or modify a Note to you with provided server info. For @e creation, you must assign property @b uid. @see ServerCommunicatior.h
 @param noteDictionary
 Please use the @e ServerCommunicator.h defined key in @e NSDictionary. This dictionary should at least contain @b ServerNoteUID to perform @b query; if create or modify is needed, you need to provide all ServerNote* for creation, or partial ServerNote* for modification.
 @param sender
 A @e Contact specifying who send this Note. This parameter is ignored when query. You still need to specify this parameter while modify.
 @param receivers
 Array of @e Contact specifying who receives this Note. This parameter is ignored when query. You still need to specify this parameter while modify.
 @param media
 Ordered set of @e Multimedia specifying the sequence and the multimedia contained in this Note. This parameter is optional; ignored when query.
 @param context
 Specify in which @e NSManagedObjectContext should be saved.
 @return Returns a new or queried Note;@b nil if the necessary information is not set appropriate.
 */
+ (instancetype)noteWithServerInfo:(NSDictionary *)noteDictionary
							sender:(Contact *)sender
						 receivers:(NSArray *)receivers
							 media:(NSArray *)media
			inManagedObjectContext:(NSManagedObjectContext *)context;

/**
 A method insert a Note without uid into Core Data. Create time determined by the time you call this method.
 */
+ (instancetype)noteWithTitle:(NSString *)title
					 location:(NSString *)location
					  dueTime:(NSDate *)dueTime
					receivers:(NSArray *)receivers
						media:(NSArray *)media
	   inManagedObjectContext:(NSManagedObjectContext *)context;

/**
 Check if this Note is synced all the @e Multimedia in the relationship @b media are synced
 */
- (BOOL)allSynced;

/**
 Update only property @b read and @b accept. Usually used when local information is newer than server information, and thus only needs to update receiver's status.
 */
- (instancetype)updateStatusWithServerInfo:(NSDictionary *)noteDictionary
								 receivers:(NSArray *)receivers;

@end
