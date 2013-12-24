//
//  NoteDetailTVC.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/12/3.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "FriendTVC.h"

@class Note;

@interface NoteDetailTVC : UITableViewController<FriendTVCDelegate, QLPreviewControllerDataSource>

@property (nonatomic, strong) Note *note;

@end
