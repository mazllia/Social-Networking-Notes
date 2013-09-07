//
//  SortingViewController.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/9/5.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "SortingViewController.h"

@interface SortingViewController ()

@end

@implementation SortingViewController

#pragma mark - Table view delegate

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self currentSelectedCell].accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL isSameCellSelected = [indexPath isEqual:[NSIndexPath indexPathForRow:self.selectedSortingStyle inSection:0]];
	
	if (!isSameCellSelected) {
		[self currentSelectedCell].accessoryType = UITableViewCellAccessoryNone;
		self.selectedSortingStyle = indexPath.row;
		[self currentSelectedCell].accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
	[self.delegate sortingViewControllerDismissWithSortingStyle:self.selectedSortingStyle];
}

- (UITableViewCell *)currentSelectedCell
{
	return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedSortingStyle inSection:0]];
}

@end
