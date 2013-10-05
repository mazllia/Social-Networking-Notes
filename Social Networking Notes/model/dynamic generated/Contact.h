//
//  Contact.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/1.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FacebookAccount, Note;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSNumber * hasFB;
@property (nonatomic, retain) NSNumber * isVIP;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) FacebookAccount *fbAccount;
@property (nonatomic, retain) NSSet *notesHaveCreated;
@property (nonatomic, retain) NSSet *notesHaveRecieved;
@end

@interface Contact (CoreDataGeneratedAccessors)

- (void)addNotesHaveCreatedObject:(Note *)value;
- (void)removeNotesHaveCreatedObject:(Note *)value;
- (void)addNotesHaveCreated:(NSSet *)values;
- (void)removeNotesHaveCreated:(NSSet *)values;

- (void)addNotesHaveRecievedObject:(Note *)value;
- (void)removeNotesHaveRecievedObject:(Note *)value;
- (void)addNotesHaveRecieved:(NSSet *)values;
- (void)removeNotesHaveRecieved:(NSSet *)values;

@end
