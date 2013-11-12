//
//  Note+Create.h
//
//	1. Parse the JSON objects
//	2. Insert them into NSManagedObjectContext
//

#import "Note.h"

@interface Note (Create)

/**
 This method queries or creates (save to database) a Note to you with provided server info. For @e creation, you must assign property @b uid. @see ServerCommunicatior.h
 @param noteDictionary
 Please use the @e ServerCommunicator.h defined key in @e NSDictionary. This dictionary should at least contain @b ServerNoteUID to perform @b query; if @b creation is needed, you need to provide all @b ServerNote* in @e ServerCommunicator.h.
 @param sender
 A @e Contact specifying who send this Note
 @param receivers
 Array of @e Contact specifying who receives this Note
 @param media
 @b Optional parameter. Ordered set of @e Multimedia specifying the sequence and the multimedia contained in this Note
 @param context
 Specify in which @e NSManagedObjectContext should be saved.
 @return Returns a new or queried Note;@b nil if the necessary information is not set appropriate.
 */
+ (instancetype)noteWithServerInfo:(NSDictionary *)noteDictionary
							sender:(Contact *)sender
						 receivers:(NSArray *)receivers
							 media:(NSArray *)media
			inManagedObjectContext:(NSManagedObjectContext *)context;

@end
