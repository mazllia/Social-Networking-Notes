//
//  AppDelegate.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/7/7.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "AppDelegate.h"
#import "AccountStore.h"
#import "DatabaseManagedDocument.h"
#import "Contact.h"

@implementation AppDelegate
{
	DatabaseManagedDocument *_db;
	AccountStore *_userAccount;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Initiate the user
	_userAccount = [AccountStore sharedAccount];
	ACAccountType *fbAccountType = [_userAccount accountTypeWithAccountTypeIdentifier:@"ACAccountTypeIdentifierFacebook"];
	if ([[_userAccount accountsWithAccountType:fbAccountType] count] == 0) {
		[[[UIAlertView alloc] initWithTitle:@"Account Error!"
									message:@"We cannot reach your Facebook account in system preferences, please set it before you use this application."
								   delegate:nil
						  cancelButtonTitle:@"Quit"
						  otherButtonTitles:nil] show];
		[self applicationWillTerminate:[UIApplication sharedApplication]];
	}
	// Initiate the database
	_db = [DatabaseManagedDocument sharedDatabase];
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[_db saveToURL:_db.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:nil];
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[_db saveToURL:_db.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:nil];
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
