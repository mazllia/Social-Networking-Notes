//
//  Multimedia.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/11/22.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Note;

@interface Multimedia : NSManagedObject

@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSNumber * synced;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *whichNotesInclude;
@end

@interface Multimedia (CoreDataGeneratedAccessors)

- (void)addWhichNotesIncludeObject:(Note *)value;
- (void)removeWhichNotesIncludeObject:(Note *)value;
- (void)addWhichNotesInclude:(NSSet *)values;
- (void)removeWhichNotesInclude:(NSSet *)values;

@end
