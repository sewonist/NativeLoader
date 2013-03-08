//
//  ViewController.h
//  TestReachability
//
//  Created by sewonist on 13. 1. 25..
//  Copyright (c) 2013년 sewonist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"
#import "NetworkInfoiOSLibrary.h"
#import "PortChecker.h"


@interface ViewController : UIViewController {
    
    IBOutlet UITextField* textIP;
    IBOutlet UITextField* textPORT;
    
    AsyncSocket *_socket;
    NSMutableArray *_ableAddressList;
    int _target;
    int _port;
    const NSString *_subnet;
    NSString *_address;
    
    PortChecker *portchecker;
}

@property (nonatomic, retain) IBOutlet UITextField* textIP;
@property (nonatomic, retain) IBOutlet UITextField* textPORT;

-(IBAction) checkAddress;
-(IBAction) cancleCheck;

@end
