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

        [f setValue:mediaFileName.fileName forKey:@"file_name" ];

        [mediaFileNameData addObject:f];

    }

    //tranform to json data

    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];

    [data setValue:senderUID forKey:@"sender_uid" ];

    [data setValue:receiverData forKey:@"receiver_uid_list" ];

    [data setValue:createTime forKey:@"send_time"];

    [data setValue:dueTime forKey:@"alert_time" ];

    [data setValue:mediaFileNameData forKey:@"file_name_list" ];

    [data setValue:context forKey:@"context" ];

    [data setValue:location forKey:@"location" ];

    

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



@end
