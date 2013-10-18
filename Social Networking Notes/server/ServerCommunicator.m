//
//  ServerFetcher.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/9/16.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "ServerCommunicator.h"
#import "Contact.h"
#import "Multimedia.h"
#import "Note+Create.h"
// Server
#define serverRootURL [NSURL URLWithString:@"http://people.cs.nctu.edu.tw/~chiangcw/"]

// kSenderUID, kRecieverUID, kDueTime, kTitle, kMediaFileName
#define pushURL @"create_sticky.php?"
// kNoteUID
#define pushSetMultimediaURL @"upload.php?"

// kRecieverUID
#define pullURL @"receive_sticky.php?"
// kNoteUID
#define pullInitMultimediaURL @"ask_upload_file.php?"
// kNoteUID, kMediaFileName
#define pullMultimediaURL @"UpLoad/%@/%@"

#define kSenderUID @"sender_uid"
#define kRecieverUID @"reciever_uid"
#define kNoteUID @"sticky_uid"
#define kDueTime @"alert_time"
#define kTitle @"context"
#define kMediaFileName @"file_name"

@implementation ServerCommunicator

- (NSString *)pushNotes:(Note *)note toRecivers:(NSArray *)recievers

{

    NSString *createTime= [NSString stringWithFormat:@"%@",note.createTime];

    NSString *dueTime = [NSString stringWithFormat:@"%@",note.dueTime];
    return [self serverCreateWithSender:note.sender.uid
                    receiverUIDs:recievers
                      createTime:createTime
                         dueTime:dueTime
                      mediaFiles:note.media
                         context:note.title
                        location:note.location];
}

- (NSArray *)serverGetNotesForUser:(NSString *)userID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@=%@",serverRootURL,pullURL,kRecieverUID,userID]];
    NSLog(@"%@",url);
    
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
                            location:(NSString*) location{

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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@=%@",serverRootURL,pushSetMultimediaURL,kNoteUID,stickyUID]];
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

-(void) downloadFile:(NSString *)stickyUID fileName:(NSString *)fileName fileSaveProsition:(NSURL *) SaveProsition{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@/%@",serverRootURL,pullMultimediaURL,stickyUID,fileName]];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:self delegateQueue: [NSOperationQueue mainQueue]];

    NSURLSessionDownloadTask * downloadTask =[ defaultSession downloadTaskWithURL:url];
    self.SaveProsition = SaveProsition;
    [downloadTask resume];
}

//NSURLSessionDwonloadDelegate
//-------------------
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"Temporary File :%@\n", location);
    NSError *err = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager moveItemAtURL:location
                             toURL:self.SaveProsition
                             error: &err])

    {
        NSLog(@"File is saved to =%@",self.SaveProsition);
    }
    else
    {
        NSLog(@"failed to move: %@",[err userInfo]);
    }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite

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
@end
