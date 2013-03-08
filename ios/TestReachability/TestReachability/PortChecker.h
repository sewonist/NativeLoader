#include <stdio.h>
#include <sys/types.h>
#include <ifaddrs.h>
#include <netinet/in.h>
#include <string.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <sys/sockio.h>
#include <sys/ioctl.h>
#include <netdb.h>
#include <sys/sysctl.h>
#include <net/ethernet.h>
#include <net/if_dl.h>
#include <err.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/socket.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "Reachability.h"
#import "AsyncSocket.h"


@interface PortChecker : NSObject {
    AsyncSocket *_socket;
    NSMutableArray *_ableAddress;
    NSMutableArray *_subnetAddress;
    int _start;
    int _target;
    int _port;
    NSString *_subnet;
    NSString *_address;
}

- (id)initWithDelegate:(id)delegate widthStart:(int)start;
- (void) check:(NSString *)address withPort:(int)port;
- (void) cancel;
- (NSMutableArray *) getAbleAddress;

@end