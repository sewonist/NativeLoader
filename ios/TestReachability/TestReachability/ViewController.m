//
//  ViewController.m
//  TestReachability
//
//  Created by sewonist on 13. 1. 25..
//  Copyright (c) 2013년 sewonist. All rights reserved.
//

#import "NetworkInfoiOSLibrary.h"
#import "ViewController.h"
#import "Reachability.h"
#include <arpa/inet.h>
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ViewController

@synthesize textIP, textPORT;

- (IBAction)checkAddress
{
    int port = [textPORT.text intValue];

    [textIP resignFirstResponder];
    [textPORT resignFirstResponder];
    
    /*
    NSMutableArray * _subnetAddress = [NSMutableArray arrayWithArray:[textIP.text componentsSeparatedByString:@"."]];
    NSString * _base = [[NSString alloc] initWithFormat:@"%@.%@.%@.",
             [_subnetAddress objectAtIndex:0],
             [_subnetAddress objectAtIndex:1],
             [_subnetAddress objectAtIndex:2]];
    
    NSLog(@"%@", _base);
    */
    NSString *string1 = @"Apple";
    NSString *string2 = [NSString stringWithString:string1];
    NSLog(@"%p, %p", string1, string2);
    
    NSLog(@"size : %ld", sizeof(string1));
    [self changeObjectPointedBy:&string1];
    
    NSLog(@"%@, %@",string1, string2);
    NSLog(@"%p, %p",string1, string2);
    
    [portchecker check:textIP.text withPort:port ];
    
    
    // [self check:textIP.text withPort:port];
}

-(void)changeObjectPointedBy:(id*)p{
    *p = @"Orange";
}

-(UIImage *) getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    
    result = [UIImage imageWithData:data];
    
    return result;
}

-(void)imageLoad
{
    UIImage * imageFromURL = [self getImageFromURL:@"http://project.itpointlab.com/wants_p/wp-content/uploads/2013/02/coupon008.png"];
    
    [self performSelectorOnMainThread:@selector(didLoadImageInBackground:) withObject:imageFromURL waitUntilDone:YES];

}

- (void)didLoadImageInBackground:(UIImage *)image {
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
    
}

-(void)sdWebImageload
{
    
    //[self cancle];
    NSURL *pathURL = [NSURL URLWithString:@"http://project.itpointlab.com/wants_p/wp-content/uploads/2013/02/coupon008.png"];
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:pathURL
                                                        options:0
                                                       progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         // progression tracking code
     }
                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
     {
         if (image && finished)
         {
             NSString* aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             
             [self.view addSubview:[[UIImageView alloc] initWithImage:image]];
         }
     }];
}

-(IBAction)cancleCheck
{
    [self sdWebImageload];
}


#pragma mark -
#pragma mark PortChecker Methods

- (void) check:(NSString *)subnet withPort:(int)port {
    NSLog(@"Start port check");
    _target = 0;
    _subnet = subnet;
    _port = port;
    
    NSMutableArray *_subnetAddress = [NSMutableArray arrayWithArray:[subnet componentsSeparatedByString:@"."]]; // [192, 168, 0, x]
    NSString *test  = [NSString stringWithFormat:@"%@.%@.%@.",
                       [_subnetAddress objectAtIndex:0],
                       [_subnetAddress objectAtIndex:1],
                       [_subnetAddress objectAtIndex:2]];
    NSLog(@"test : %@", test);
    
    
    // reset ableAddressList
    [_ableAddressList removeAllObjects];
    
    [self check];
}

-(void) check {
    // reset socket
    if(_socket!=nil){
        [_socket setDelegate:nil];
        [_socket release];
        _socket = nil;
    }
    
    if(_target<10){
        _target = _target + 1;
        
        NSString *subnet = [NSString stringWithString:_subnet];
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[subnet componentsSeparatedByString:@"."]]; // [192, 168, 0, x]
        [arr replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%d", _target]];
        _address = [arr componentsJoinedByString:@"."];
        
        NSLog(@"Process port check at %@", _address);
        
        _socket = [[AsyncSocket alloc] initWithDelegate:self];
        [_socket connectToHost:_address onPort:_port withTimeout:.3 error:nil];
        
    } else {
        NSLog(@"Complete port check");
        
        for(NSString *st in _ableAddressList) {
            NSLog(@"address : %@", st);
        }
    }
}

-(void) cancle {
    if(_socket!=nil){
        [_socket setDelegate:nil];
        [_socket release];
        _socket = nil;
    }
}

#pragma mark -
#pragma mark AsyncSocket Methods

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
	NSLog(@"Disconnecting. Error: %@", [err localizedDescription]);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    /*
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Result"
                          message: @"Disconnected."
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    */
    NSLog(@"Disconnected To %@:%i.", _address, _port);
	
    [self check];
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock {
	NSLog(@"onSocketWillConnect:");
	return YES;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    /*
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Result"
                          message: [NSString stringWithFormat:@"Connected To %@:%i.", host, port ]
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    */
	NSLog(@"*** Connected To %@:%i. ***", _address, _port);
    
    [_ableAddressList addObject:[NSString stringWithFormat: @"%@",_address]];
    
    [self check];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
	/**
	 * Convert data to a string for logging.
	 *
	 * http://stackoverflow.com/questions/550405/convert-nsdata-bytes-to-nsstring
	 */
	NSString *string = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
	NSLog(@"Received Data (Tag: %i): %@", tag, string);
	[string release];
}

- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(CFIndex)partialLength tag:(long)tag {
	NSLog(@"onSocket:didReadPartialDataOfLength:%i tag:%i", partialLength, tag);
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
	NSLog(@"onSocket:didWriteDataWithTag:%i", tag);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _ableAddressList = [[NSMutableArray alloc] init];
    
    portchecker = [[PortChecker alloc] initWithDelegate:self widthStart:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
