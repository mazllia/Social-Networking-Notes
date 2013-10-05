//
//  FacebookAccount.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/1.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface FacebookAccount : NSManagedObject

@property (nonatomic, retain) NSString * biography;
@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSData * coverImage;
@property (nonatomic, retain) NSString * devices;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * pictureImage;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) Contact *snAccount;

@end
