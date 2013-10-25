//
//  ServerFetcher.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/9/16.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "ServerCommunicator.h"
#import "AccountStore.h"
#import "Contact+Create.h"
#import "Multimedia.h"
#import "Note+Create.h"
// Server
#define serverRootURL [NSURL URLWithString:@"http://people.cs.nctu.edu.tw/~chiangcw/"]

#define pushURL @"create_sticky.php?"
#define modifyURL @"modify_sticky.php?"
#define pushSetMultimediaURL @"upload.php?"

#define pullURL @"receive_sticky.php?"
#define vipContentURL @"vip_content.php?"
#define pullInitMultimediaURL @"ask_upload_file.php?"
#define pullMultimediaURL @"UpLoad/"

#define noteStateURL @"check_notestate.php?"
#define toReadURL @"already_read.php?"
#define setVIPURL @"set_vip.php?"
#define cancelVIPURL @"cancel_vip.php?"

#define createAcountURL @"create_account.php?"
#define askToBeFriendURL @"ask_friend.php?"
#define receiveAskToBeFriendURL @"receive_friendAsk.php?"
#define replyAskToBeFriendURL @"reply_askFriend.php?"
#define receiveReplyAskToBeFriendURL @"receive_friendAskReply.php?"
#define getContactListURL @"contact_list.php?"


@implementation ServerCommunicator
- (NSString *)pushNotes:(Note *)note toReceivers:(NSArray *)receivers

{
	
    NSString *createTime= [NSString stringWithFormat:@"%@",note.createTime];
	
    NSString *dueTime = [NSString stringWithFormat:@"%@",note.dueTime];
    return [self serverCreateWithSender:note.sender.uid
						   receiverUIDs:receivers
							 createTime:createTime
								dueTime:dueTime
							 mediaFiles:note.media
								context:note.title
							   location:note.location];
}

- (BOOL)modifySendedNote:(Note *)note noteUID:(NSString *)noteUID toReceivers:(NSArray *)receivers

{
    NSString *createTime= [NSString stringWithFormat:@"%@",note.createTime];
    NSString *dueTime = [NSString stringWithFormat:@"%@",note.dueTime];
    return [self modifySendedNote:note.sender.uid
					 receiverUIDs:receivers
					   createTime:createTime
						  dueTime:dueTime
					   mediaFiles:note.media
						  context:note.title
						 location:note.location
						  noteUID:noteUID];
}

- (NSArray *)serverGetNotesForUser:(NSString *)userID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@=%@",serverRootURL,pullURL,ServerNoteReceiverUID ,userID]];
    NSLog(@"%@",url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval: 2.0]; // Will timeout after 2 seconds
    NSURLResponse *response;
    NSError *error;
    NSData *responseData =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error != nil){
        NSLog(@"error");
        return nil;
    } else{
        NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        return jsonData;
    }
}

- (NSArray *)getVipList:(NSString *)userUID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@=%@",serverRootURL,vipContentURL,kUserUID,userUID]];
    NSLog(@"%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval: 2.0]; // Will timeout after 2 seconds
    NSURLResponse *response;
    NSError *error;
    NSData *responseData =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error != nil){
        NSLog(@"error");
        return nil;
    } else{
        NSString *r =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",r);
        
        NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        
        return jsonData;
    }
}

/**
 Push(1)
 @return NoteUID
 @em BUG
 Need decision: how the note uid passes
 */
- (NSString *)serverCreateWithSender:(NSString *)senderUID
                        receiverUIDs:(NSArray *)receiverUIDs
                          createTime:(NSString *)createTime
                             dueTime:(NSString *)dueTime
                          mediaFiles:(NSOrderedSet *)mediaFiles                                 context:(NSString *)context
                            location:(NSString*) location
{
	
    //handle receiver_uid_list data
	
    NSMutableArray *receiverData = [[NSMutableArray alloc] init];
    for(NSString * receiver in receiverUIDs){
        NSMutableDictionary *r =[[NSMutableDictionary alloc] init];
        [r setValue:receiver forKey:@"receiver_uid" ];
        [receiverData addObject:r];
		
    }
	
    
    NSMutableArray *mediaFileNameData = [[NSMutableArray alloc] init];
    for(Multimedia* mediaFileName in mediaFiles){
        NSMutableDictionary *f =[[NSMutableDictionary alloc] init];
        NSString *fileName = [mediaFileName.localUrl lastPathComponent];
        [f setValue:fileName forKey:@"file_name" ];
        [mediaFileNameData addObject:f];
    }
	
    //tranform to json data
	
    NSDictionary *data = @{
						   @"sender_uid":senderUID,
						   @"receiver_uid_list":receiverData,
						   @"send_time":createTime,
						   @"alert_time":dueTime,
						   @"file_name_list":mediaFileNameData,
						   @"context":context,
						   @"location":location
						   };
	
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	
    NSString *str =[NSString stringWithFormat:@"%@%@json_note=%@",serverRootURL,pushURL,jsonString];
    NSString* str2 =[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:str2];
	
    
	
    //開始與server 連線
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval: 2.0]; // Will timeout after 2 seconds
    NSURLResponse *response;
    NSError *error;
    NSData *responseData =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error != nil){
        NSLog(@"error");
        return nil;
    }
    else{
        NSString *stickyUID=[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",stickyUID);
        return stickyUID;
    }
}
//

- (BOOL)modifySendedNote:(NSString *)senderUID
			receiverUIDs:(NSArray *)receiverUIDs
			  createTime:(NSString *)createTime
				 dueTime:(NSString *)dueTime
			  mediaFiles:(NSOrderedSet *)mediaFiles                                 context:(NSString *)context
				location:(NSString*) location
				 noteUID:(NSString *)noteUID{
    //handle receiver_uid_list data
    NSMutableArray *receiverData = [[NSMutableArray alloc] init];
    for(NSString * receiver in receiverUIDs){
        NSMutableDictionary *r =[[NSMutableDictionary alloc] init];
        [r setValue:receiver forKey:@"receiver_uid" ];
        [receiverData addObject:r];
    }
	
    NSMutableArray *mediaFileNameData = [[NSMutableArray alloc] init];
    for(Multimedia* mediaFileName in mediaFiles){
        NSMutableDictionary *f =[[NSMutableDictionary alloc] init];
        NSString *fileName = [mediaFileName.localUrl lastPathComponent];
        [f setValue:fileName forKey:@"file_name" ];
        [mediaFileNameData addObject:f];
    }
    //tranform to json data
	
    NSDictionary *data = @{
                           @"sender_uid":senderUID,
                           @"receiver_uid_list":receiverData,
                           @"send_time":createTime,
                           @"alert_time":dueTime,
                           @"file_name_list":mediaFileNameData,
                           @"context":context,
                           @"location":location
                           };
	
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *str =[NSString stringWithFormat:@"%@%@json_note=%@&%@=%@",serverRootURL,modifyURL,jsonString,ServerNoteUID,noteUID];
    NSString* str2 =[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:str2];
	
    //開始與server 連線
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval: 2.0]; // Will timeout after 2 seconds
    NSURLResponse *response;
    NSError *error;
    NSData *responseData =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseInformation=[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",responseInformation);
    if(error == nil && [responseInformation isEqualToString:@"success"]){
        NSLog(@"success");
        return 1;
    }
    else{
        //NSString *stickyUID=[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",stickyUID);
        NSLog(@"error");
        return 0;
    }
}
//
//
- (void)uploadFile:(NSString *)stickyUID fileData:(NSData *)paramData filePath:(NSString *)path fileName:(NSString *)Name{
	
    self.receivedData=[[NSMutableData alloc] init];
	
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
	
    NSString *boundary = @"0xKhTmLbOuNdArY";//NSURLConnection is very sensitive to format.
											// set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
	
    // add params (all params are strings)
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"path"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n",path] dataUsingEncoding:NSUTF8StringEncoding]];
	
    // add image data
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",@"File",Name] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:paramData];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	
    // set URL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@=%@",serverRootURL,pushSetMultimediaURL,ServerNoteUID,stickyUID]];
    NSLog(@"%@",url);
    [request setURL:url];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    //進入NSURLConnection Delegate
}

//#pragma mark -

#pragma mark NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // store data
    NSLog(@"didReceiveResponse");
    [self.receivedData setLength:0];      //通常在這裡會先清空回傳值的暫存
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
    NSLog(@"didReceiveData");
    [self.receivedData appendData:data];    //可能多次收到多次回傳值，把新的回傳值加在原有回傳值後面
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
    // 錯誤例外處理
    NSLog(@"didFailWithError");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // disconnect
    NSString *checkData=[NSString stringWithFormat:@"%@",[[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding]];
    NSLog(@"%@",checkData);
}

//-----------------------------------------------------------------

- (void)downloadFile:(NSString *)stickyUID fileName:(NSString *)fileName fileSaveProsition:(NSURL *) saveProsition{
	
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@/%@",serverRootURL,pullMultimediaURL,stickyUID,fileName]];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:self delegateQueue: [NSOperationQueue mainQueue]];
	
    NSURLSessionDownloadTask * downloadTask =[ defaultSession downloadTaskWithURL:url];
    self.saveProsition = saveProsition;
    [downloadTask resume];
}

//NSURLSessionDwonloadDelegate
//-------------------
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"Temporary File :%@\n", location);
    NSError *err = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
	
    if ([fileManager moveItemAtURL:location
                             toURL:self.saveProsition
                             error: &err]) {
        NSLog(@"File is saved to =%@",self.saveProsition);
    } else {
        NSLog(@"failed to move: %@",[err userInfo]);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite

{
    //You can get progress here
    NSLog(@"Received: %lld bytes (Downloaded: %lld bytes)  Expected: %lld bytes.\n",
          bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes

{
    NSLog(@"download error");
}
//--------
-(NSString *) checkNoteState:(NSString *)noteUID receiverUID:(NSString *)receiverUID

{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@=%@&%@=%@",serverRootURL,noteStateURL,ServerNoteUID,noteUID,ServerNoteReceiverUID,receiverUID]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval: 2.0]; // Will timeout after 2 seconds
    NSURLResponse *response;
    NSError *error;
    NSData *responseData =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseInformation=[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",responseInformation);
    if(error == nil ){
        //NSLog(@"success");
        return responseInformation;
    }
    else{
        return nil;
    }
}

- (BOOL)updateNoteStateToRead:(NSString *)noteUID userUID:(NSString *)userUID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@=%@&%@=%@",serverRootURL,toReadURL,ServerNoteUID,noteUID,ServerNoteReceiverUID,userUID]];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval: 2.0]; // Will timeout after 2 seconds
    NSURLResponse *response;
    NSError *error;
    NSData *responseData =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseInformation=[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",responseInformation);
    if(error == nil && [responseInformation isEqualToString:@"success"]){
        return 1;
    }
    else{
		
        return 0;
    }
}

- (BOOL)setSomenoeToVip:(NSString *)userUID someoneYouLove:(NSString *)LoveUID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@=%@&%@=%@",serverRootURL,setVIPURL,kUserUID,userUID,ServerNoteReceiverUID,LoveUID]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval: 2.0]; // Will timeout after 2 seconds
    NSURLResponse *response;
    NSError *error;
    NSData *responseData =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseInformation=[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",responseInformation);
    if(error == nil && [responseInformation isEqualToString:@"success"]){
        //NSLog(@"success");
        return 1;
    }
    else{
        return 0;
    }
}

- (BOOL)cancelSomeoneVip:(NSString *)userUID someoneYouLoveBefore:(NSString *)LoveUID

{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@=%@&%@=%@",serverRootURL,cancelVIPURL,kUserUID,userUID,ServerNoteReceiverUID,LoveUID]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval: 2.0]; // Will timeout after 2 seconds
    NSURLResponse *response;
    NSError *error;
    NSData *responseData =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseInformation=[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",responseInformation);
    if(error == nil && [responseInformation isEqualToString:@"success"]){
        //NSLog(@"success");
        return 1;
    }
    else{
        return 0;
    }
}

- (NSString *)createAccount:(Contact *)account
{
    NSDictionary *data =@{
        ServerContactNickName:account.nickName
        };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSString *str =[NSString stringWithFormat:@"%@%@json_account=%@",serverRootURL,createAcountURL,jsonString];
    NSString* str2 =[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:str2];

    //開始與server 連線
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval: 2.0]; // Will timeout after 2 seconds
    NSURLResponse *response;
    NSError *error;
    NSData *responseData =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error != nil){
        NSLog(@"error");
        return nil;
    } else{
        NSString *contactUID=[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",stickyUID);
        return contactUID;
    }
}

- (NSArray *)getContactList:(NSString *)userUID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@=%@",serverRootURL,getContactListURL,ServerNoteUserUID,userUID]];
    NSLog(@"%@",url);
    //開始與server 連線
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval: 2.0]; // Will timeout after 2 seconds
    NSURLResponse *response;
    NSError *error;
    NSData *responseData =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    if(error == nil ){
        NSLog(@"success");
        NSString *r =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",r);
        NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        return jsonData;
    } else{
        return Nil;
    }
}


- (NSString *)sendTheRequestToBeFriend:(NSString *)senderUID receiver:(NSString *)receiverUID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@=%@&%@=%@",serverRootURL,askToBeFriendURL,ServerNoteSenderUID,senderUID,ServerNoteReceiverUID,receiverUID]];
    NSLog(@"%@",url);

    //開始與server 連線
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval: 2.0]; // Will timeout after 2 seconds
    NSURLResponse *response;
    NSError *error;
    NSData *responseData =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *r=[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    if(error == nil && [r isEqualToString:@"success"]){
        NSLog(@"success");
        return @"success";
    } else{
        return Nil;
    }
}

- (NSArray *)receiveTheRequestToBeFriend:(NSString *)userUID

{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@=%@",serverRootURL,receiveAskToBeFriendURL,ServerNoteUserUID,userUID]];
    NSLog(@"%@",url);
    //開始與server 連線
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval: 2.0]; // Will timeout after 2 seconds
    NSURLResponse *response;
    NSError *error;
    NSData *responseData =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if(error == nil ){
        NSLog(@"success");
        NSString *r =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",r);
        NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        
        return jsonData;
    } else{
        return Nil;
    }
}

- (NSString *)replyTheRequestToBeFriend:(NSString *)userUID senderUID:(NSString *)senderUID reply:(NSString *)reply

{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@=%@&%@=%@&%@=%@",serverRootURL,replyAskToBeFriendURL,ServerNoteUserUID,userUID,ServerNoteSenderUID,senderUID,ServerContactReply,reply]];
    NSLog(@"%@",url);
    //開始與server 連線
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval: 2.0]; // Will timeout after 2 seconds
    NSURLResponse *response;
    NSError *error;
    NSData *responseData =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *r=[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    if(error == nil && [r isEqualToString:@"success"]){
        NSLog(@"success");
        return @"success";
    } else{
        return Nil;
    }
}


- (NSArray *)receiveTheReplyToBeFriend:(NSString *)userUID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@=%@",serverRootURL,receiveReplyAskToBeFriendURL,ServerNoteUserUID,userUID]];
    NSLog(@"%@",url);
    //開始與server 連線
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval: 2.0]; // Will timeout after 2 seconds
    NSURLResponse *response;
    NSError *error;
    NSData *responseData =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if(error == nil ){
        NSLog(@"success");
        NSString *r =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",r);
        
        NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];

        return jsonData;
    } else{
        return Nil;
    }
}

@end
