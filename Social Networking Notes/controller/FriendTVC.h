//
//  FriendTVC.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/12/3.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "CoreDataTableViewController.h"

@class FriendTVC;
@protocol FriendTVCDelegate <NSObject>
@required
- (void)friendTVC:(FriendTVC *)friendTVC didSelectContacts:(NSArray *)contacts;
@end

@interface FriendTVC : CoreDataTableViewController

@property (nonatomic, weak) id<FriendTVCDelegate> selectDelegate;
- (void)finishSelectContacts;

@end
