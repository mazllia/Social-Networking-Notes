//
//  SortingViewController.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/9/5.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

typedef enum {
	SNSortingStyleDueDate = 0,
	SNSortingStyleNewest,
	SNSortingStyleExpired,
	SNSortingStyleAccept,
	SNSortingStyleDeclined,
	SNSortingStyleUndecided
} SNSortingStyle;

@protocol SortingViewControllerDelegate <NSObject>
- (void)sortingViewControllerDismissWithSortingStyle:(SNSortingStyle)sortingStyle;

@end

@interface SortingViewController : UITableViewController
@property (nonatomic) SNSortingStyle selectedSortingStyle;
@property (weak, nonatomic) id <SortingViewControllerDelegate> delegate;

@end