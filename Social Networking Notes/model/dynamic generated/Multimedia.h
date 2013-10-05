//
//  Multimedia.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/1.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Note;

@interface Multimedia : NSManagedObject

@property (nonatomic, retain) NSString * cloudUrl;
@property (nonatomic, retain) NSString * localUrl;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *whichNotesInclude;
@end

@interface Multimedia (CoreDataGeneratedAccessors)

- (void)addWhichNotesIncludeObject:(Note *)value;
- (void)removeWhichNotesIncludeObject:(Note *)value;
- (void)addWhichNotesInclude:(NSSet *)values;
- (void)removeWhichNotesInclude:(NSSet *)values;

@end
