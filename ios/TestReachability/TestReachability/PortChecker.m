#import "PortChecker.h"

@implementation PortChecker

static NSString *OPEN = @"open";
static NSString *COMPLETE = @"complete";
static NSString *CHANGE = @"change";
static NSString *CANCEL = @"cancel";

id _delegate;

#pragma mark - Constructor

- (id)initWithDelegate:(id)delegate widthStart:(int)start
{
    self = [super init];
    if( self )
    {
        _delegate = delegate;
        _start = start;
        _ableAddress = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - PortChecker Methods

- (void) check:(NSString *)subnet withPort:(int)port {
    NSLog(@"Start port check");
    _target = _start;
    _subnetAddress = [NSMutableArray arrayWithArray:[subnet componentsSeparatedByString:@"."]];
    
    if(_subnet!=nil){
        [_subnet release];
        _subnet = nil;
    }
    _subnet = [[NSString alloc] initWithFormat:@"%@.%@.%@.",
               [_subnetAddress objectAtIndex:0],
               [_subnetAddress objectAtIndex:1],
               [_subnetAddress objectAtIndex:2]];
    
    _port = port;
    
    // reset ableAddressList
    [_ableAddress removeAllObjects];
    
    [self check];
}

-(void) check {
    // reset socket
    if(_socket!=nil){
        [_socket setDelegate:nil];
        [_socket release];
        _socket = nil;
    }
    
    if(_address!=nil){
        [_address release];
        _address = nil;
    }
    
    if(_target<_start+50 && _target<254){
        _target = _target + 1;
        _address = [[NSString alloc] initWithFormat:@"%@%d", _subnet, _target];
        
        NSLog(@"Process port check at %@", _address);
        
        _socket = [[AsyncSocket alloc] initWithDelegate:self];
        [_socket connectToHost:_address onPort:_port withTimeout:.65 error:nil];
        
    } else {
        NSLog(@"Complete port check");
        for(NSString *st in _ableAddress) {
            NSLog(@"address : %@", st);
        }
    }
}

-(void) cancel {
    if(_socket!=nil){
        [_socket setDelegate:nil];
        [_socket release];
        _socket = nil;
    }
}


-(NSMutableArray *) getAbleAddress {
    return _ableAddress;
}

#pragma mark -
#pragma mark AsyncSocket Methods

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
	NSLog(@"Disconnecting. Error: %@", [err localizedDescription]);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    NSLog(@"Disconnected To %@:%i.", _address, _port);
	
    [self check];
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock {
	NSLog(@"onSocketWillConnect:");
	return YES;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
	NSLog(@"*** Connected To %@:%i. ***", _address, _port);
    [_ableAddress addObject:[NSString stringWithFormat: @"%@",_address]];
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

@end

/*


#import "PortChecker.h"

@implementation PortChecker

static NSString *OPEN = @"open";
static NSString *COMPLETE = @"complete";
static NSString *CHANGE = @"change";
static NSString *CANCEL = @"cancel";

#pragma mark - Constructor

// start [0, 50, 100, 150, 200, 250]
- (id)initWithStart:(int) start
{
    self = [super init];
    if( self )
    {
        _start = start;
        _ableAddress = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark PortChecker Methods

- (void) check:(NSString *)subnet withPort:(int)port {
    NSLog(@"Start port check");
    DISPATCH_STATUS_EVENT(_context, "", [OPEN UTF8String]);
    
    _target = _start;
    _subnetAddress = [NSMutableArray arrayWithArray:[subnet componentsSeparatedByString:@"."]];
    
    if(_subnet!=nil){
        [_subnet release];
        _subnet = nil;
    }
    _subnet = [[NSString alloc] initWithFormat:@"%@.%@.%@.",
               [_subnetAddress objectAtIndex:0],
               [_subnetAddress objectAtIndex:1],
               [_subnetAddress objectAtIndex:2]];
    
    _port = port;
    
    // reset ableAddressList
    [_ableAddress removeAllObjects];
    
    [self check];
}

-(void) check {
    // reset socket
    if(_socket!=nil){
        [_socket setDelegate:nil];
        [_socket release];
        _socket = nil;
    }
    
    if(_address!=nil){
        [_address release];
        _address = nil;
    }
    
    if(_target<_start+50 && _target<254){
        _target = _target + 1;
        _address = [[NSString alloc] initWithFormat:@"%@%d", _subnet, _target];
        
        NSLog(@"Process port check at %@", _address);
        
        _socket = [[AsyncSocket alloc] initWithDelegate:self];
        [_socket connectToHost:_address onPort:_port withTimeout:.65 error:nil];
        
    } else {
        NSLog(@"Complete port check");
        DISPATCH_STATUS_EVENT(_context, "", [COMPLETE UTF8String]);
        
        for(NSString *st in _ableAddress) {
            NSLog(@"address : %@", st);
        }
    }
}

-(void) cancel {
    if(_socket!=nil){
        [_socket setDelegate:nil];
        [_socket release];
        _socket = nil;
    }
    DISPATCH_STATUS_EVENT(_context, "", [CANCEL UTF8String]);
}


-(NSMutableArray *) getAbleAddress {
    return _ableAddress;
}

#pragma mark -
#pragma mark AsyncSocket Methods

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
	NSLog(@"Disconnecting. Error: %@", [err localizedDescription]);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    NSLog(@"Disconnected To %@:%i.", _address, _port);
	
    [self check];
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock {
	NSLog(@"onSocketWillConnect:");
	return YES;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
	NSLog(@"*** Connected To %@:%i. ***", _address, _port);
    [_ableAddress addObject:[NSString stringWithFormat: @"%@",_address]];
    DISPATCH_STATUS_EVENT(_context, "", [CHANGE UTF8String]);
    
    [self check];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
	
	 * Convert data to a string for logging.
	 *
	 * http://stackoverflow.com/questions/550405/convert-nsdata-bytes-to-nsstring
	 
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

@end
*/