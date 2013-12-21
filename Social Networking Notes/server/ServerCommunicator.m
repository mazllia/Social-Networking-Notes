//
//  ServerCommunicatorViewController.m
//  ServerCommunicator
//
//  Created by JACKY183 on 13/10/16.
//  Copyright (c) 2013年 JACKY183. All rights reserved.
//

#import "ServerCommunicator.h"
#import "FBCommunicator.h"
#import "ServerSynchronizer.h"

#define serverRootURL @"http://people.cs.nctu.edu.tw/~chiangcw/"


// kNoteUID
#define pushSetMultimediaURL @"upload_file.php?"


// kNoteUID, kMediaFileName
#define pullMultimediaURL @"UpLoad/"

#define getFBFriendURL  @"get_fbfriend.php"
#define createAcountURL @"create_account.php"
#define pushNoteURL @"push_note.php"
#define getNoteURL @"get_note.php"
#define askNoteURL @"ask_note.php"
#define pushContactURL @"push_contact.php"
#define getContactURL @"get_contact.php"


#define uploadSynchrousDataURL @"uploadSynchrousDataURL.php"
#define updateFriendlistURL @"update_friendlist.php?"

#define ServerNoteList @"note_list"
#define ServerJSONArrayNameRecieving @"json_note"
#define ServerContactList @"contact_list"

@interface ServerCommunicator ()

@property (nonatomic,strong,readonly)NSString* deviceUID;
@property (nonatomic,strong)NSOperationQueue* operationQueue;
@property (nonatomic,strong)Contact *userContact;

@end

@implementation ServerCommunicator

- (instancetype)initWithDelegate:(id<ServerCommunicatorDelegate>)delegate
				 withUserContact:(Contact *)user
{
	self = [super init];
	if (self) {
		self.delegate = delegate;
		self.userContact = user;
		[self registerUserAccount:user.fbUid];
		self.operationQueue = [[NSOperationQueue alloc] init];
	}
	return self;
}

- (NSString *)deviceUID
{
	return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (Contact *)userContact
{
	return [[ServerSynchronizer sharedSynchronizer]  currentUser];
}

- (void)text_upload_file
{
    NSString *filePath =@"Users/JACKY183/Documents/test.jpg";
    NSData *mydata = [NSData dataWithContentsOfFile:filePath];
    [self uploadFile:@"11260" fileData:mydata filePath:@"Users/JACKY183/Documents/test.jpg" fileName:@"test.jpg"];
}
//NSURLSession upload delegate

//

- (void)uploadFileDelegate:(NSString *)url fileData:(NSData *)paramData filePath:(NSString *)path fileName:(NSString *)Name{
    //self.receivedData=[[NSMutableData alloc] init];
    
    NSLog(@"upload file:%@",Name);
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
    [request setURL:[NSURL URLWithString:url]];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    //進入NSURLConnection Delegate
}

#pragma mark -
#pragma mark NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // 錯誤例外處理
    NSLog(@"didFailWithError");
}

//-------------------------------------------------

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    /*download error handle*/
    if(error)NSLog(@"download error");
}
//nsurlsessiondownload delegate
//-------------------------------------------------
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"Temporary File :%@\n", location);
    NSError *err = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURLRequest *r = [downloadTask currentRequest];
    NSURL *u = [r URL];
    NSString * s = [NSString stringWithFormat:@"%@",u];
    NSString *fileName = [s lastPathComponent];
    NSURL *savePosition =[NSURL URLWithString:[NSString stringWithFormat:@"%@",[self localURL:fileName]]];
    
    //NSLog(@"filename = %@",fileName);
    //NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    //NSURL *docsDirURL = [NSURL fileURLWithPath:[docsDir stringByAppendingPathComponent:@"out1.jpg"]];
    
    if ([fileManager moveItemAtURL:location
                             toURL:savePosition
                             error: &err])
    {
        NSLog(@"File is saved to =%@",savePosition);
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
	// NSLog(@"download error");
}
//-------------------------------------------------------

//test
//-----------------------------------------

- (void)uploadFile:(NSString *)stickyUID fileData:(NSData *)paramData filePath:(NSString *)path fileName:(NSString *)Name{
    //self.receivedData=[[NSMutableData alloc] init];
    
    
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

-(void) downloadFile:(NSString *)stickyUID fileName:(NSString *)fileName {
	
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@/%@",serverRootURL,pullMultimediaURL,stickyUID,fileName]];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:self delegateQueue: self.operationQueue];
    
    NSURLSessionDownloadTask * downloadTask =[ defaultSession downloadTaskWithURL:url];
    [downloadTask resume];
    
}



- (NSString *)registerUserAccount:(NSString *)facebookUID
{
    
    //NSString *facebookUID=@"123456789";
	//NSString *facebookUID = [[FBCommunicator sharedCommunicator] me].id;
	
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",serverRootURL,createAcountURL]];
	
    //開始與server 連線
    
    
    NSString *httpBodyString = [NSString stringWithFormat:@"facebook_uid=%@&deviceUID=%@",facebookUID,self.deviceUID];
    
    NSData *responseData =[self httpPostConnect:url httpBodyString:httpBodyString];
    if(responseData==nil){
        NSLog(@"error");
        return nil;
    }
    else{
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        //NSLog(@"%@",stickyUID);
        if(jsonData==nil)
        {
			NSLog(@"error");
            return nil;
        }
        NSString *contactUID =[jsonData objectForKey:ServerNoteUserUID];
        return contactUID;
    }
}

-(BOOL)pushNotes:(NSArray*)notes contacts:(NSArray *)contacts
{
    Note *note;
    
    //transform notes and contact to json data
    NSMutableArray* notelist = [[NSMutableArray alloc]init];
    for(note in notes)
    {
        [notelist addObject:[self tranformNoteToJson:note]];
    }
    NSData *jsonNotelist = [NSJSONSerialization dataWithJSONObject:notelist options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonNotelistString = [[NSString alloc] initWithData:jsonNotelist encoding:NSUTF8StringEncoding];
    
    NSMutableArray* contactlist = [[NSMutableArray alloc]init];
    for(Contact* contactData in contacts)
    {
        NSString *isVip = [contactData.isVIP stringValue];
				
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
		if(contactData.uid)
			data[ServerContactUID]=contactData.uid;
		if(contactData.fbUid)
			data[ServerContactFbAccountIdentifier]=contactData.fbUid;
		if (contactData.nickName)
			data[ServerContactNickName] = contactData.nickName;
		if (contactData.isVIP)
			data[ServerContactIsVIP] = isVip;
        [contactlist addObject:data];
    }
    NSData *jsonContactlist = [NSJSONSerialization dataWithJSONObject:contactlist options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonContactlistString = [[NSString alloc] initWithData:jsonContactlist encoding:NSUTF8StringEncoding];
    
    //upload note data to server
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",serverRootURL,pushNoteURL]];
    
    NSString *userUID =[self userContact].uid;
    
    NSString *httpBodyString = [NSString stringWithFormat:@"user_uid=%@&deviceUID=%@&json_notelist=%@",userUID,self.deviceUID,jsonNotelistString];
    
    NSData* responseDate =[self httpPostConnect:url httpBodyString:httpBodyString];
    if(responseDate ==nil){
        NSLog(@"error");
		[self getLastestNotes:ServerActionPush];
		[self getContact];
        return false;
    }
    //upload contact data to server
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",serverRootURL,pushContactURL]];
    
    httpBodyString = [NSString stringWithFormat:@"user_uid=%@&deviceUID=%@&json_contactlist=%@",userUID,self.deviceUID,jsonContactlistString];
    
    responseDate=[self httpPostConnect:url httpBodyString:httpBodyString];
    if(responseDate==nil)
    {
		[self getLastestNotes:ServerActionPush];
		[self getContact];
        return false;
    }
    
//    return true;
    [self getLastestNotes:ServerActionPush];
	[self getContact];
	return true;
}

-(NSDictionary *)tranformNoteToJson:(Note *)note
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSString *createTime= [dateFormatter stringFromDate:note.createTime];
    NSString *dueTime = [dateFormatter stringFromDate:note.dueTime];
    
    //handle receiver_uid_list data
    NSMutableArray *receiverData = [[NSMutableArray alloc] init];
    for(Contact * receiver in note.receivers){
        NSMutableDictionary *r =[[NSMutableDictionary alloc] init];
        [r setValue:receiver.uid forKey:@"receiver_uid" ];
        [receiverData addObject:r];
    }
    
    NSMutableArray *mediaFileNameData = [[NSMutableArray alloc] init];
    for(Multimedia* mediaFileName in note.media){
        NSMutableDictionary *f =[[NSMutableDictionary alloc] init];
        [f setValue:mediaFileName.fileName forKey:ServerMediaFileName ];
        //[f setValue:mediaFileName.fileType forKey:ServerMediaType];
        [mediaFileNameData addObject:f];
    }
    NSString* noteSync= [note.synced stringValue];
	
	NSString *tmpNoteUID = [[NSString alloc]init];
	if(note.uid== nil)
	{
		tmpNoteUID =@"-1";
	} else{
		tmpNoteUID = note.uid;
	}
    //tranform to json data
	NSString *read = [note.read stringValue];
	NSString *accepted = [note.accepted stringValue];
	NSString *archived = [note.archived stringValue];
	
    NSDictionary *data = @{
						   ServerNoteUID:tmpNoteUID,
                           ServerNoteSenderUID:note.sender.uid,
                           ServerNoteReceiverList:receiverData,
                           ServerNoteCreateTime:createTime,
                           ServerNoteDueTime:dueTime,
                           ServerMediaFileList:mediaFileNameData,
                           ServerNoteTitle:note.title,
                           ServerNoteLocation:note.location,
                           @"note_sync":noteSync,
                           ServerNoteArchive:archived,
						   ServerNoteRead:read,
						   ServerNoteAccepted:accepted
                           };
    return data;
}



-(BOOL) getLastestNotes
{
    return [self getLastestNotes:ServerActionPull];
}

-(BOOL) getLastestNotes:(ServerAction)action
{
	
	// NSString* userUID =@"28";
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",serverRootURL,getNoteURL]];
    
    NSString *httpBodyString = [NSString stringWithFormat:@"user_uid=%@&deviceUID=%@",[self userContact].uid,self.deviceUID];
    NSLog(@"%@",httpBodyString);
    //開始與server 連線
    
    NSData *responseData =[self httpPostConnect:url httpBodyString:httpBodyString];
    if(responseData)
    {
        NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        NSString* jsonString =[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",jsonString);
        //NSLog(@"%@",stickyUID);
        if(jsonData==nil)
        {
			[self.delegate serverCommunicatorNotesSynced:nil fromAction:action];
            return false;
        }
        //start to check file exist
        
        NSDictionary* note;
        for(note in jsonData)
        {
            //NSString *sender = [note objectForKey:ServerNoteSenderUID];
            NSArray* filelist = note[ServerMediaFileList];
            if(note[ServerMediaFileList] ==nil)
            {
                continue;
            }
            NSString* noteUID = note[ServerNoteUID];
            //NSLog(@"%@",filelist);
            NSDictionary* file;
            
            for(file in filelist)
            {
                
                NSString* fileName=file[ServerMediaFileName];
                //NSString *fileURL=[NSString stringWithFormat:@"%@%@%@/%@",serverRootURL,pullMultimediaURL,noteUID,fileName];
                //NSLog(@"%@",fileName);
                NSString* exist = [file objectForKey:@"exist"];
                
                NSString* path = [self localURL:fileName];
                NSURL* u =[NSURL URLWithString:path];
                NSData * fileData = [NSData dataWithContentsOfURL:u];
                
                if (fileData ==nil && [exist isEqualToString:@"1"])
                {
                    //start download file
					[self downloadFile:noteUID fileName:fileName];
                }
                else if(fileData !=nil && [exist isEqualToString:@"0"])
                {
                    //start upload file
                    //[self uploadFile:noteUID fileData:fileData filePath:[self localURL:fileName] fileName:fileName];
                    [self.operationQueue addOperationWithBlock:^{
                        [self uploadFile:noteUID fileData:fileData filePath:[self localURL:fileName] fileName:fileName];
                    }];
                }
            }
            
        }
        
        
        //wait until operationqueue complete
        [self.operationQueue waitUntilAllOperationsAreFinished];
        NSLog(@"all work finish");
        //ask server to send the note
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",serverRootURL,askNoteURL]];
        httpBodyString =[NSString stringWithFormat:@"user_uid=%@&deviceUID=%@&json_notelist=%@",[self userContact].uid,self.deviceUID,jsonString];
        responseData=[self httpPostConnect:url httpBodyString:httpBodyString];
        if(responseData==nil)
        {
			[self.delegate serverCommunicatorNotesSynced:nil fromAction:action];
            return false;
        }
        //this json object is for delegate
        NSMutableArray *jsonDataComplete =[[NSMutableArray alloc]init];
        jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        //NSLog(@"%@",[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding]);
        for(note in jsonData)
        {
            
            //NSString *sender = [note objectForKey:ServerNoteSenderUID];
            NSArray* filelist = note[ServerMediaFileList];
            if(note[ServerMediaFileList]==nil)
            {
				NSDictionary *tmpDictionary=@{ServerNoteUID:note[ServerNoteUID],
											  ServerNoteSenderUID:note[ServerNoteSenderUID],
											  ServerNoteReceiverList:note[ServerNoteReceiverList],
											  ServerNoteCreateTime:note[ServerNoteCreateTime],
											  ServerNoteDueTime:note[ServerNoteDueTime],
											  ServerNoteTitle:note[ServerNoteTitle],
											  ServerNoteLocation:note[ServerNoteLocation],
											  ServerNoteArchive:note[ServerNoteArchive]
											  };
				[jsonDataComplete addObject:tmpDictionary];
                continue;
            }
            NSMutableArray *tmpArray=[[NSMutableArray alloc]init];
            NSDictionary* file;
            for(file in filelist)
            {
                NSMutableDictionary *tmpDictionary=[[NSMutableDictionary alloc]init];
                [tmpDictionary setObject:file[ServerMediaFileName] forKey:ServerMediaFileName];
                NSString* fileName =file[ServerMediaFileName];
                //NSLog(@"%@",fileName);
                NSString* exist = file[@"exist"];
                
                NSString* path = [self localURL:fileName];
                NSURL* u =[NSURL URLWithString:path];
                NSData * fileData = [NSData dataWithContentsOfURL:u];
                
                if([exist isEqualToString:@"1"] && fileData!=nil)
                {
                    //set this file sync to true
                    [tmpDictionary setObject:@YES forKey:ServerMediaSync];
                }
                else
                {
                    //set this file sync to false
                    [tmpDictionary setObject:@NO forKey:ServerMediaSync];
                }
                [tmpArray addObject:tmpDictionary];
                
            }
            NSDictionary *tmpDictionary=@{ServerNoteUID:note[ServerNoteUID],
										  ServerNoteSenderUID:note[ServerNoteSenderUID],
										  ServerNoteReceiverList:note[ServerNoteReceiverList],
										  ServerNoteCreateTime:note[ServerNoteCreateTime],
										  ServerNoteDueTime:note[ServerNoteDueTime],
										  ServerMediaFileList:tmpArray,
										  ServerNoteTitle:note[ServerNoteTitle],
										  ServerNoteLocation:note[ServerNoteLocation],
										  ServerNoteArchive:note[ServerNoteArchive]
										  };
            [jsonDataComplete addObject:tmpDictionary];
        }
        //NSData *json = [NSJSONSerialization dataWithJSONObject:jsonDataComplete options:NSJSONWritingPrettyPrinted error:nil];
        //NSString *jsonStr = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",jsonStr);
        [self.delegate serverCommunicatorNotesSynced:jsonDataComplete fromAction:action];
        return true;
    }
    else{
		[self.delegate serverCommunicatorNotesSynced:nil fromAction:action];
        return false;
    }
}



- (BOOL)getContact

{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",serverRootURL,getContactURL]];
    NSString *httpBodyString = [NSString stringWithFormat:@"user_uid=%@&deviceUID=%@",self.userContact.uid,self.deviceUID];
    //開始與server 連線
    NSData *responseData =[self httpPostConnect:url httpBodyString:httpBodyString];
    if(responseData){
        NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        //NSLog(@"%@",stickyUID);
        if(jsonData==nil)
        {
			[self.delegate serverCommunicatorContactSynced:nil fromAction:ServerActionPush];
            return false;
        }
        [self.delegate serverCommunicatorContactSynced:jsonData fromAction:ServerActionPush];
        return true;
    }
    else{
		[self.delegate serverCommunicatorContactSynced:nil fromAction:ServerActionPush];
        NSLog(@"error");
        return false;
    }
	
}

- (BOOL)getAvailableUsersFromFBFriends
{
	NSString *accessToken = [FBSession activeSession].accessTokenData.accessToken;
	
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",serverRootURL,getFBFriendURL]];
	
	
    NSString *httpBodyString = [NSString stringWithFormat:@"user_uid=%@&deviceUID=%@&access_token=%@&facebook_uid=%@",self.userContact.uid,self.deviceUID,accessToken,self.userContact.fbUid];
	
    //開始與server 連線
    NSData *responseData =[self httpPostConnect:url httpBodyString:httpBodyString];
	NSLog(@"%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
    if(responseData){
        NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
		
        //NSLog(@"%@",stickyUID);
        if(jsonData==nil)
        {
			[self.delegate serverCommunicatorContactSynced:nil fromAction:ServerActionPull];
            return false;
        }
        [self.delegate serverCommunicatorContactSynced:jsonData fromAction:ServerActionPull];
        return true;
    }
    else{
        NSLog(@"error");
		[self.delegate serverCommunicatorContactSynced:nil fromAction:ServerActionPull];
        return false;
		
    }
	
}

- (NSString *)localURL:(NSString *)fileName
{
    NSError *err;
    NSString *documentURL = [[[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&err] absoluteString];
    if (err) {
        [[NSException exceptionWithName:@"Multimedia(Create) localURL Directory" reason:[err localizedDescription] userInfo:nil] raise];
    }
    
    return [documentURL stringByAppendingPathComponent:fileName];
}


- (NSData *)httpPostConnect:(NSURL *)url httpBodyString:(NSString *)httpBodyString
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval: 30.0]; // Will timeout after 30 seconds
    
    [request setHTTPBody:[httpBodyString dataUsingEncoding:NSUTF8StringEncoding]];
    NSError* error;
    NSData *data =[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if(error)
    {
		NSLog(@"%@", [error localizedDescription]);
        return nil;
    }
    else
    {
        return data;
    }
    //NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

- (NSString *)uploadSynchronousData:(NSString*) userUID noteList:(NSArray *)noteList contactList:(NSArray *)contactList
{
    NSMutableArray *noteUidList = [[NSMutableArray alloc] init];
    Note* note;
    for(note in noteList)
    {
        //use json formule
        NSDictionary *data = @{
                               ServerNoteUID:note.uid
                               };
        [noteUidList addObject:data];
    }
    NSMutableArray *contactListData =[[NSMutableArray alloc]init];
    Contact* contact;
    for(contact in contactList)
    {
        
        NSString *isVip = [contact.isVIP stringValue];
        NSDictionary *data = @{
                               ServerContactUID:contact.uid,
                               ServerContactFbAccountIdentifier:contact.fbUid,
                               ServerContactIsVIP:isVip,
                               ServerContactNickName:contact.nickName
                               };
        
        [contactListData addObject:data];
    }
    NSDictionary *jsonSynchronousData =@{ServerNoteList:noteUidList,ServerContactList:contactListData};
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonSynchronousData options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",serverRootURL,uploadSynchrousDataURL]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *httpBodyString = [NSString stringWithFormat:@"uploadSynchrousData=%@&user_uid=%@",jsonString,userUID];
    
    [request setURL:url];
    [request setTimeoutInterval: 2.0]; // Will timeout after 2 seconds
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[httpBodyString dataUsingEncoding:NSUTF8StringEncoding]];
    NSError *error;
    NSData *responseData =[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    if(error == nil ){
        NSLog(@"success");
        NSString *r =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",r);
        return @"1";
    }
    else{
        return @"0";
    }
}

@end
