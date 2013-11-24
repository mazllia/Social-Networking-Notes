//
//  Note.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/11/23.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact, Multimedia;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSNumber * accepted;
@property (nonatomic, retain) NSNumber * archived;
@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSDate * dueTime;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSNumber * synced;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSOrderedSet *media;
@property (nonatomic, retain) NSSet *receivers;
@property (nonatomic, retain) Contact *sender;
@end

@interface Note (CoreDataGeneratedAccessors)

- (void)insertObject:(Multimedia *)value inMediaAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMediaAtIndex:(NSUInteger)idx;
- (void)insertMedia:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMediaAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMediaAtIndex:(NSUInteger)idx withObject:(Multimedia *)value;
- (void)replaceMediaAtIndexes:(NSIndexSet *)indexes withMedia:(NSArray *)values;
- (void)addMediaObject:(Multimedia *)value;
- (void)removeMediaObject:(Multimedia *)value;
- (void)addMedia:(NSOrderedSet *)values;
- (void)removeMedia:(NSOrderedSet *)values;
- (void)addReceiversObject:(Contact *)value;
- (void)removeReceiversObject:(Contact *)value;
- (void)addReceivers:(NSSet *)values;
- (void)removeReceivers:(NSSet *)values;

@end
