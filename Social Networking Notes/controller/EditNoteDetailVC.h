//
//  EditNoteDetailVC.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/12/25.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Note;
@interface EditNoteDetailVC : UIViewController<UITextFieldDelegate>

@property (nonatomic, strong) Note *note;

@end
