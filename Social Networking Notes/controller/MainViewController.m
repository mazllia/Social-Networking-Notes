//
//  MainViewController.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/9/5.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "MainViewController.h"
#import "SortingViewController.h"

@interface MainViewController () <SortingViewControllerDelegate>
@property (nonatomic) SNSortingStyle sortingStyle;

- (void)updateNavigationControllerTitle;
@end

@implementation MainViewController

- (void)setSortingStyle:(SNSortingStyle)sortingStyle
{
	if (_sortingStyle != sortingStyle) {
		_sortingStyle = sortingStyle;
		[self updateNavigationControllerTitle];
	}
}

- (void)updateTableViewContent
{
	[self.tableView setNeedsDisplay];
}

- (void)updateNavigationControllerTitle
{
	NSString *newTitle;
	switch (self.sortingStyle) {
		case SNSortingStyleDueDate:
			newTitle = @"Due Date";
			break;
		case SNSortingStyleNewest:
			newTitle = @"Newest";
			break;
		case SNSortingStyleDeclined:
			newTitle = @"Decliened";
			break;
		case SNSortingStyleAccept:
			newTitle = @"Accepted";
			break;
		case SNSortingStyleExpired:
			newTitle = @"Expired";
			break;
		case SNSortingStyleUndecided:
			newTitle = @"Undecided";
			break;
		default:
			[[[UIAlertView alloc] initWithTitle:@"Error" message:@"MainViewController updateNavigationControllerTitle fail" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil] show];
			break;
	}
	[self.navigationItem setTitle:newTitle];
}

#pragma mark - UIStoryBoard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"showSortingMethod"]) {
		SortingViewController *sortingViewController = (SortingViewController *)segue.destinationViewController;
		sortingViewController.selectedSortingStyle = self.sortingStyle;
		sortingViewController.delegate = self;
	}
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.sortingStyle = SNSortingStyleExpired;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Sorting view controller delegete

- (void)sortingViewControllerDismissWithSortingStyle:(SNSortingStyle)sortingStyle
{
	self.sortingStyle = sortingStyle;
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
