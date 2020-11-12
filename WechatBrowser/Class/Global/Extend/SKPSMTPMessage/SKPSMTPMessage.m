//
//  SKPSMTPMessage.m
//
//  Created by Ian Baird on 10/28/08.
//
//  Copyright (c) 2008 Skorpiostech, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "SKPSMTPMessage.h"
#import <Foundation/NSStream.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <math.h>

#pragma mark - HSK_CFUtilities
void CFStreamCreatePairWithUNIXSocketPair(CFAllocatorRef alloc, CFReadStreamRef *readStream, CFWriteStreamRef *writeStream);
CFIndex CFWriteStreamWriteFully(CFWriteStreamRef outputStream, const uint8_t* buffer, CFIndex length);
void CFStreamCreatePairWithUNIXSocketPair(CFAllocatorRef alloc, CFReadStreamRef *readStream, CFWriteStreamRef *writeStream){
	int sockpair[2];
	int success = socketpair(AF_UNIX, SOCK_STREAM, 0, sockpair);
	if (success < 0) {
		[NSException raise:@"HSK_CFUtilitiesErrorDomain" format:@"Unable to create socket pair, errno: %d", errno];
	}
	CFStreamCreatePairWithSocket(NULL, sockpair[0], readStream, NULL);
	CFReadStreamSetProperty(*readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
	CFStreamCreatePairWithSocket(NULL, sockpair[1], NULL, writeStream);
	CFWriteStreamSetProperty(*writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
}
CFIndex CFWriteStreamWriteFully(CFWriteStreamRef outputStream, const uint8_t* buffer, CFIndex length){
	CFIndex bufferOffset = 0;
	CFIndex bytesWritten;
	
	while (bufferOffset < length)
	{
		if (CFWriteStreamCanAcceptBytes(outputStream))
		{
			bytesWritten = CFWriteStreamWrite(outputStream, &(buffer[bufferOffset]), length - bufferOffset);
			if (bytesWritten < 0)
			{
				// Bail!
				return bytesWritten;
			}
			bufferOffset += bytesWritten;
		}
		else if (CFWriteStreamGetStatus(outputStream) == kCFStreamStatusError)
		{
			return -1;
		}
		else
		{
			// Pump the runloop
			CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.0, true);
		}
	}
	
	return bufferOffset;
}

#pragma mark - NSStream+SKPSMTPExtensions
@interface NSStream (SKPSMTPExtensions)
+ (void)getStreamsToHostNamed:(NSString *)hostName port:(NSInteger)port inputStream:(NSInputStream * __strong *)inputStream outputStream:(NSOutputStream * __strong *)outputStream;
@end
@implementation NSStream (SKPSMTPExtensions)
+ (void)getStreamsToHostNamed:(NSString *)hostName port:(NSInteger)port inputStream:(NSInputStream * __strong *)inputStream outputStream:(NSOutputStream * __strong *)outputStream{
	CFHostRef           host;
	CFReadStreamRef     readStream;
	CFWriteStreamRef    writeStream;
	
	readStream = NULL;
	writeStream = NULL;
	
	host = CFHostCreateWithName(NULL, (__bridge CFStringRef) hostName);
	if (host != NULL)
	{
		(void) CFStreamCreatePairWithSocketToCFHost(NULL, host, (SInt32)port, &readStream, &writeStream);
		CFRelease(host);
	}
	
	if (inputStream == NULL)
	{
		if (readStream != NULL)
		{
			CFRelease(readStream);
		}
	}
	else
	{
		*inputStream = (__bridge NSInputStream *) readStream;
	}
	if (outputStream == NULL)
	{
		if (writeStream != NULL)
		{
			CFRelease(writeStream);
		}
	}
	else
	{
		*outputStream = (__bridge NSOutputStream *) writeStream;
	}
}
@end

#pragma mark - SKPSMTPMessage
NSString *kSKPSMTPPartContentDispositionKey = @"kSKPSMTPPartContentDispositionKey";
NSString *kSKPSMTPPartContentTypeKey = @"kSKPSMTPPartContentTypeKey";
NSString *kSKPSMTPPartMessageKey = @"kSKPSMTPPartMessageKey";
NSString *kSKPSMTPPartContentTransferEncodingKey = @"kSKPSMTPPartContentTransferEncodingKey";

#define SHORT_LIVENESS_TIMEOUT 20.0
#define LONG_LIVENESS_TIMEOUT 60.0

@interface SKPSMTPMessage ()
@property(nonatomic, retain) NSMutableString *inputString;
@property(retain) NSTimer *connectTimer;
@property(retain) NSTimer *watchdogTimer;
- (void)parseBuffer;
- (BOOL)sendParts;
- (void)cleanUpStreams;
- (void)startShortWatchdog;
- (void)stopWatchdog;
- (NSString *)formatAnAddress:(NSString *)address;
- (NSString *)formatAddresses:(NSString *)addresses;
@end

@implementation SKPSMTPMessage
@synthesize login, pass, relayHost, relayPorts, subject, fromEmail, toEmail, parts, requiresAuth, inputString, wantsSecure, \
            delegate, connectTimer, connectTimeout, watchdogTimer, validateSSLChain;
@synthesize ccEmail;
@synthesize bccEmail;

#pragma mark Memory & Lifecycle
- (id)init
{
    static NSArray *defaultPorts = nil;
    
    if (!defaultPorts)
    {
        defaultPorts = [[NSArray alloc] initWithObjects:[NSNumber numberWithShort:25], [NSNumber numberWithShort:465], [NSNumber numberWithShort:587], nil];
    }
    
    if ((self = [super init]))
    {
        // Setup the default ports
        self.relayPorts = defaultPorts;
        
        // setup a default timeout (8 seconds)
        connectTimeout = 8.0; 
        
        // by default, validate the SSL chain
        validateSSLChain = YES;
    }
    
    return self;
}

- (void)dealloc
{
    //NSLog(@"dealloc %@", self);
    self.login = nil;
    self.pass = nil;
    self.relayHost = nil;
    self.relayPorts = nil;
    self.subject = nil;
    self.fromEmail = nil;
    self.toEmail = nil;
	self.ccEmail = nil;
	self.bccEmail = nil;
    self.parts = nil;
    self.inputString = nil;
    
    //[inputStream release];
    inputStream = nil;
    
    //[outputStream release];
    outputStream = nil;
    
    [self.connectTimer invalidate];
    self.connectTimer = nil;
    
    [self stopWatchdog];
    
    //[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    SKPSMTPMessage *smtpMessageCopy = [[[self class] allocWithZone:zone] init];
    smtpMessageCopy.delegate = self.delegate;
    smtpMessageCopy.fromEmail = self.fromEmail;
    smtpMessageCopy.login = self.login;
    smtpMessageCopy.parts = [self.parts copy];
    smtpMessageCopy.pass = self.pass;
    smtpMessageCopy.relayHost = self.relayHost;
    smtpMessageCopy.requiresAuth = self.requiresAuth;
    smtpMessageCopy.subject = self.subject;
    smtpMessageCopy.toEmail = self.toEmail;
    smtpMessageCopy.wantsSecure = self.wantsSecure;
    smtpMessageCopy.validateSSLChain = self.validateSSLChain;
    smtpMessageCopy.ccEmail = self.ccEmail;
    smtpMessageCopy.bccEmail = self.bccEmail;
    
    return smtpMessageCopy;
}

#pragma mark Connection Timers
- (void)startShortWatchdog
{
#ifdef DEBUG
    NSLog(@"*** starting short watchdog ***");
#endif
    self.watchdogTimer = [NSTimer scheduledTimerWithTimeInterval:SHORT_LIVENESS_TIMEOUT target:self selector:@selector(connectionWatchdog:) userInfo:nil repeats:NO];
}

- (void)startLongWatchdog
{
#ifdef DEBUG
	NSLog(@"*** starting long watchdog ***");
#endif
    self.watchdogTimer = [NSTimer scheduledTimerWithTimeInterval:LONG_LIVENESS_TIMEOUT target:self selector:@selector(connectionWatchdog:) userInfo:nil repeats:NO];
}

- (void)stopWatchdog
{
#ifdef DEBUG
	NSLog(@"*** stopping watchdog ***");
#endif
    [self.watchdogTimer invalidate];
    self.watchdogTimer = nil;
}

#pragma mark Watchdog Callback
- (void)connectionWatchdog:(NSTimer *)aTimer
{
    [self cleanUpStreams];
    
    // No hard error if we're wating on a reply
    if (sendState != kSKPSMTPWaitingQuitReply)
    {
        NSError *error = [NSError errorWithDomain:@"SKPSMTPMessageError" 
                                             code:kSKPSMPTErrorConnectionTimeout 
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Timeout sending message.", @"server timeout fail error description"),NSLocalizedDescriptionKey,
                                                   NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
        [delegate messageFailed:self error:error];
    }
    else
    {
        [delegate messageSent:self];
    }
}

#pragma mark Connection Handling
- (BOOL)preflightCheckWithError:(NSError **)error {
    
    CFHostRef host = CFHostCreateWithName(NULL, (__bridge CFStringRef)self.relayHost);
    CFStreamError streamError;
    
    if (!CFHostStartInfoResolution(host, kCFHostAddresses, &streamError)) {
        NSString *errorDomainName;
        switch (streamError.domain) {
            case kCFStreamErrorDomainCustom:
                errorDomainName = @"kCFStreamErrorDomainCustom";
                break;
            case kCFStreamErrorDomainPOSIX:
                errorDomainName = @"kCFStreamErrorDomainPOSIX";
                break;
            case kCFStreamErrorDomainMacOSStatus:
                errorDomainName = @"kCFStreamErrorDomainMacOSStatus";
                break;
            default:
                errorDomainName = [NSString stringWithFormat:@"Generic CFStream Error Domain %ld", streamError.domain];
                break;
        }
        if (error)
            *error = [NSError errorWithDomain:errorDomainName
                                         code:streamError.error
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Error resolving address.", NSLocalizedDescriptionKey,
                                               @"Check your SMTP Host name", NSLocalizedRecoverySuggestionErrorKey, nil]];
        CFRelease(host);
        return NO;
    }
    Boolean hasBeenResolved;
    CFHostGetAddressing(host, &hasBeenResolved);
    if (!hasBeenResolved) {
        if(error)
            *error = [NSError errorWithDomain:@"SKPSMTPMessageError" code:kSKPSMTPErrorNonExistentDomain userInfo:
                      [NSDictionary dictionaryWithObjectsAndKeys:@"Error resolving host.", NSLocalizedDescriptionKey,
                       @"Check your SMTP Host name", NSLocalizedRecoverySuggestionErrorKey, nil]];
        CFRelease(host);
        return NO;
    }
    
    CFRelease(host);
    return YES;
}

- (BOOL)send
{
    NSAssert(sendState == kSKPSMTPIdle, @"Message has already been sent!");
    
    if (requiresAuth)
    {
        NSAssert(login, @"auth requires login");
        NSAssert(pass, @"auth requires pass");
    }
    
    NSAssert(relayHost, @"send requires relayHost");
    NSAssert(subject, @"send requires subject");
    NSAssert(fromEmail, @"send requires fromEmail");
    NSAssert(toEmail, @"send requires toEmail");
    NSAssert(parts, @"send requires parts");
    
    NSError *error = nil;
    if (![self preflightCheckWithError:&error]) {
        [delegate messageFailed:self error:error];
        return NO;
    }
    
    if (![relayPorts count])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate messageFailed:self 
                              error:[NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                        code:kSKPSMTPErrorConnectionFailed 
                                                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Unable to connect to the server.", @"server connection fail error description"),NSLocalizedDescriptionKey,
                                                              NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]]];

        });
        
        return NO;
    }
    
    // Grab the next relay port
    short relayPort = [[relayPorts objectAtIndex:0] shortValue];
    
    // Pop this off the head of the queue.
    self.relayPorts = ([relayPorts count] > 1) ? [relayPorts subarrayWithRange:NSMakeRange(1, [relayPorts count] - 1)] : [NSArray array];
	
#ifdef DEBUG
    NSLog(@"C: Attempting to connect to server at: %@:%d", relayHost, relayPort);
#endif
	
    self.connectTimer = [NSTimer timerWithTimeInterval:connectTimeout target:self selector:@selector(connectionConnectedCheck:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.connectTimer forMode:NSDefaultRunLoopMode];

    [NSStream getStreamsToHostNamed:relayHost port:relayPort inputStream:&inputStream outputStream:&outputStream];
    if ((inputStream != nil) && (outputStream != nil))
    {
        sendState = kSKPSMTPConnecting;
        isSecure = NO;
        
        //[inputStream retain];
        //[outputStream retain];
        
        [inputStream setDelegate:self];
        [outputStream setDelegate:self];
        
        [inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [inputStream open];
        [outputStream open];
        
        self.inputString = [NSMutableString string];
        
        
        
        return YES;
    }
    else
    {
        [self.connectTimer invalidate];
        self.connectTimer = nil;
        
        [delegate messageFailed:self 
                          error:[NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                    code:kSKPSMTPErrorConnectionFailed 
                                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Unable to connect to the server.", @"server connection fail error description"),NSLocalizedDescriptionKey,
                                                          NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]]];
        
        return NO;
    }
}

+ (void)sendEmailTo:(NSString *)to title:(NSString *)title content:(NSString *)content attachment:(NSData*)attachment{
	//配置
	SKPSMTPMessage *msg = [[SKPSMTPMessage alloc] init];
	msg.fromEmail = @"comsystem@yeah.net";
	msg.login = @"comsystem";
	msg.pass = @"ok990909";
	msg.relayHost = @"smtp.yeah.net";
	msg.toEmail = to;
	msg.requiresAuth = YES;
	msg.subject = [NSString stringWithCString:[title UTF8String] encoding:NSUTF8StringEncoding];
	msg.wantsSecure = YES; // smtp.gmail.com doesn't work without TLS!
	//msg.bccEmail = @"bcc@gmail.com";
	//msg.delegate = self;
	// Only do this for self-signed certs!
	// msg.validateSSLChain = NO;
	
	NSMutableArray *parts = [[NSMutableArray alloc]init];
	//正文内容
	NSDictionary *plainPart = @{kSKPSMTPPartContentTypeKey:@"text/plain",
								kSKPSMTPPartMessageKey:[NSString stringWithCString:[content UTF8String] encoding:NSUTF8StringEncoding],
								kSKPSMTPPartContentTransferEncodingKey:@"8bit"};
	[parts addObject:plainPart];
	
	//附件
	if (attachment.length) {
		NSDictionary *format = [SKPSMTPMessage fileMate:attachment];
		NSDictionary *attachmentPart = @{kSKPSMTPPartContentTypeKey:[NSString stringWithFormat:@"%@;\r\n\tx-unix-mode=0644;\r\n\tname=\"attachment.%@\"", format[@"type"], format[@"suffix"]],
										 kSKPSMTPPartContentDispositionKey:[NSString stringWithFormat:@"attachment;\r\n\tfilename=\"attachment.%@\"", format[@"suffix"]],
										 kSKPSMTPPartMessageKey:[attachment encodeBase64ForData],
										 kSKPSMTPPartContentTransferEncodingKey:@"base64"};
		[parts addObject:attachmentPart];
	}
	
	msg.parts = parts;
	[msg send];
}

+ (NSDictionary*)fileMate:(NSData*)data{
	uint8_t c;
	NSDictionary *format = @{@"type":@"text/plain", @"suffix":@"txt"};
	[data getBytes:&c length:1];
	switch (c) {
		case 0xFF:
			format = @{@"type":@"image/jpeg", @"suffix":@"jpg"};
			break;
		case 0x89:
			format = @{@"type":@"image/png", @"suffix":@"png"};
			break;
		case 0x47:
			format = @{@"type":@"image/gif", @"suffix":@"gif"};
			break;
		case 0x49:
		case 0x4D:
			format = @{@"type":@"image/tiff", @"suffix":@"tif"};
			break;
		case 0x42:
			format = @{@"type":@"image/bmp", @"suffix":@"bmp"};
			break;
	}
	return format;
}

#pragma mark NSStreamDelegate
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode{
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
        {
            uint8_t buf[1024];
            memset(buf, 0, sizeof(uint8_t) * 1024);
            NSInteger len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:1024];
            if (len) {
                NSString *tmpStr = [[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding];
                [inputString appendString:tmpStr];
                //[tmpStr release];
                
                [self parseBuffer];
            }
            break;
        }
        case NSStreamEventEndEncountered:
        {
            [self stopWatchdog];
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            //[stream release];
            stream = nil; // stream is ivar, so reinit it
            
            if (sendState != kSKPSMTPMessageSent)
            {
                [delegate messageFailed:self 
                                  error:[NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                            code:kSKPSMTPErrorConnectionInterrupted 
                                                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"The connection to the server was interrupted.", @"server connection interrupted error description"),NSLocalizedDescriptionKey,
                                                                  NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]]];

            }
            
            break;
        }
		default:
			break;
    }
}

- (NSString *)formatAnAddress:(NSString *)address {
	NSString		*formattedAddress;
	NSCharacterSet	*whitespaceCharSet = [NSCharacterSet whitespaceCharacterSet];

	if (([address rangeOfString:@"<"].location == NSNotFound) && ([address rangeOfString:@">"].location == NSNotFound)) {
		formattedAddress = [NSString stringWithFormat:@"RCPT TO:<%@>\r\n", [address stringByTrimmingCharactersInSet:whitespaceCharSet]];									
	}
	else {
		formattedAddress = [NSString stringWithFormat:@"RCPT TO:%@\r\n", [address stringByTrimmingCharactersInSet:whitespaceCharSet]];																		
	}
	
	return(formattedAddress);
}

- (NSString *)formatAddresses:(NSString *)addresses {
	NSCharacterSet	*splitSet = [NSCharacterSet characterSetWithCharactersInString:@";,"];
	NSMutableString	*multipleRcptTo = [NSMutableString string];
	
	if ((addresses != nil) && (![addresses isEqualToString:@""])) {
		if( [addresses rangeOfString:@";"].location != NSNotFound || [addresses rangeOfString:@","].location != NSNotFound ) {
			NSArray *addressParts = [addresses componentsSeparatedByCharactersInSet:splitSet];
						
			for( NSString *address in addressParts ) {
				[multipleRcptTo appendString:[self formatAnAddress:address]];
			}
		}
		else {
			[multipleRcptTo appendString:[self formatAnAddress:addresses]];
		}		
	}
	
	return(multipleRcptTo);
}

- (void)parseBuffer
{
    // Pull out the next line
    NSScanner *scanner = [NSScanner scannerWithString:inputString];
    NSString *tmpLine = nil;
    
    NSError *error = nil;
    BOOL encounteredError = NO;
    BOOL messageSent = NO;
    
    while (![scanner isAtEnd])
    {
        BOOL foundLine = [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet]
                                                 intoString:&tmpLine];
        if (foundLine)
        {
            [self stopWatchdog];
			
#ifdef DEBUG
            NSLog(@"S: %@", tmpLine);
#endif
            switch (sendState)
            {
                case kSKPSMTPConnecting:
                {
                    if ([tmpLine hasPrefix:@"220 "])
                    {
                        
                        sendState = kSKPSMTPWaitingEHLOReply;
                        
						NSString *ehlo = [NSString stringWithFormat:@"EHLO %@\r\n", @"localhost"];
#ifdef DEBUG
                        NSLog(@"C: %@", ehlo);
#endif
                        if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[ehlo UTF8String], [ehlo lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    break;
                }
                case kSKPSMTPWaitingEHLOReply:
                {
                    // Test auth login options
                    if ([tmpLine hasPrefix:@"250-AUTH"])
                    {
                        NSRange testRange;
                        testRange = [tmpLine rangeOfString:@"CRAM-MD5"];
                        if (testRange.location != NSNotFound)
                        {
                            serverAuthCRAMMD5 = YES;
                        }
                        
                        testRange = [tmpLine rangeOfString:@"PLAIN"];
                        if (testRange.location != NSNotFound)
                        {
                            serverAuthPLAIN = YES;
                        }
                        
                        testRange = [tmpLine rangeOfString:@"LOGIN"];
                        if (testRange.location != NSNotFound)
                        {
                            serverAuthLOGIN = YES;
                        }
                        
                        testRange = [tmpLine rangeOfString:@"DIGEST-MD5"];
                        if (testRange.location != NSNotFound)
                        {
                            serverAuthDIGESTMD5 = YES;
                        }
                    }
                    else if ([tmpLine hasPrefix:@"250-8BITMIME"])
                    {
                        server8bitMessages = YES;
                    }
                    else if ([tmpLine hasPrefix:@"250-STARTTLS"] && !isSecure && wantsSecure)
                    {
                        // if we're not already using TLS, start it up
                        sendState = kSKPSMTPWaitingTLSReply;
                        
						NSString *startTLS = @"STARTTLS\r\n";
#ifdef DEBUG
                        NSLog(@"C: %@", startTLS);
#endif
                        if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[startTLS UTF8String], [startTLS lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    else if ([tmpLine hasPrefix:@"250 "])
                    {
                        if (self.requiresAuth)
                        {
                            // Start up auth
                            if (serverAuthPLAIN)
                            {
                                sendState = kSKPSMTPWaitingAuthSuccess;
                                NSString *loginString = [NSString stringWithFormat:@"\000%@\000%@", login, pass];
								NSString *authString = [NSString stringWithFormat:@"AUTH PLAIN %@\r\n", [[loginString dataUsingEncoding:NSUTF8StringEncoding] encodeBase64ForData]];
#ifdef DEBUG
                                NSLog(@"C: %@", authString);
#endif
                                if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[authString UTF8String], [authString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                                {
                                    error =  [outputStream streamError];
                                    encounteredError = YES;
                                }
                                else
                                {
                                    [self startShortWatchdog];
                                }
                            }
                            else if (serverAuthLOGIN)
                            {
                                sendState = kSKPSMTPWaitingLOGINUsernameReply;
								NSString *authString = @"AUTH LOGIN\r\n";
#ifdef DEBUG
                                NSLog(@"C: %@", authString);
#endif
                                if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[authString UTF8String], [authString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                                {
                                    error =  [outputStream streamError];
                                    encounteredError = YES;
                                }
                                else
                                {
                                    [self startShortWatchdog];
                                }
                            }
                            else
                            {
                                error = [NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                            code:kSKPSMTPErrorUnsupportedLogin
                                                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Unsupported login mechanism.", @"server unsupported login fail error description"),NSLocalizedDescriptionKey,
                                                                  NSLocalizedString(@"Your server's security setup is not supported, please contact your system administrator or use a supported email account like MobileMe.", @"server security fail error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
                                         
                                encounteredError = YES;
                            }
                                
                        }
                        else
                        {
                            // Start up send from
                            sendState = kSKPSMTPWaitingFromReply;
                            
							NSString *mailFrom = [NSString stringWithFormat:@"MAIL FROM:<%@>\r\n", fromEmail];
#ifdef DEBUG
                            NSLog(@"C: %@", mailFrom);
#endif
                            if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[mailFrom UTF8String], [mailFrom lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                            {
                                error =  [outputStream streamError];
                                encounteredError = YES;
                            }
                            else
                            {
                                [self startShortWatchdog];
                            }
                        }
                    }
                    break;
                }
                    
                case kSKPSMTPWaitingTLSReply:
                {
                    if ([tmpLine hasPrefix:@"220 "])
                    {
                        
                        // Attempt to use TLSv1
                        CFMutableDictionaryRef sslOptions = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                        
                        CFDictionarySetValue(sslOptions, kCFStreamSSLLevel, kCFStreamSocketSecurityLevelTLSv1);
                        
                        if (!self.validateSSLChain)
                        {
							// Don't validate SSL certs. This is terrible, please complain loudly to your BOFH.
#ifdef DEBUG
                            NSLog(@"WARNING: Will not validate SSL chain!!!");
#endif
							
                            CFDictionarySetValue(sslOptions, kCFStreamSSLValidatesCertificateChain, kCFBooleanFalse);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                            CFDictionarySetValue(sslOptions, kCFStreamSSLAllowsExpiredCertificates, kCFBooleanTrue);
                            CFDictionarySetValue(sslOptions, kCFStreamSSLAllowsExpiredRoots, kCFBooleanTrue);
                            CFDictionarySetValue(sslOptions, kCFStreamSSLAllowsAnyRoot, kCFBooleanTrue);
#pragma clang diagnostic pop
                        }
						
#ifdef DEBUG
                        NSLog(@"Beginning TLSv1...");
#endif
						
                        CFReadStreamSetProperty((CFReadStreamRef)inputStream, kCFStreamPropertySSLSettings, sslOptions);
                        CFWriteStreamSetProperty((CFWriteStreamRef)outputStream, kCFStreamPropertySSLSettings, sslOptions);
                        
                        CFRelease(sslOptions);
                        
                        // restart the connection
                        sendState = kSKPSMTPWaitingEHLOReply;
                        isSecure = YES;
                        
						NSString *ehlo = [NSString stringWithFormat:@"EHLO %@\r\n", @"localhost"];
#ifdef DEBUG
                        NSLog(@"C: %@", ehlo);
#endif
						
                        if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[ehlo UTF8String], [ehlo lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                        
                        /*
                        else
                        {
                            error = [NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                        code:kSKPSMTPErrorTLSFail
                                                    userInfo:[NSDictionary dictionaryWithObject:@"Unable to start TLS" 
                                                                                         forKey:NSLocalizedDescriptionKey]];
                            encounteredError = YES;
                        }
                        */
                    }
                }
                
                case kSKPSMTPWaitingLOGINUsernameReply:
                {
                    if ([tmpLine hasPrefix:@"334 VXNlcm5hbWU6"])
                    {
                        sendState = kSKPSMTPWaitingLOGINPasswordReply;
                        
						NSString *authString = [NSString stringWithFormat:@"%@\r\n", [[login dataUsingEncoding:NSUTF8StringEncoding] encodeBase64ForData]];
#ifdef DEBUG
                        NSLog(@"C: %@", authString);
#endif
                        if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[authString UTF8String], [authString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    break;
                }
                    
                case kSKPSMTPWaitingLOGINPasswordReply:
                {
                    if ([tmpLine hasPrefix:@"334 UGFzc3dvcmQ6"])
                    {
                        sendState = kSKPSMTPWaitingAuthSuccess;
                        
						NSString *authString = [NSString stringWithFormat:@"%@\r\n", [[pass dataUsingEncoding:NSUTF8StringEncoding] encodeBase64ForData]];
#ifdef DEBUG
                        NSLog(@"C: %@", authString);
#endif
                        if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[authString UTF8String], [authString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    break;
                }
                
                case kSKPSMTPWaitingAuthSuccess:
                {
                    if ([tmpLine hasPrefix:@"235 "])
                    {
                        sendState = kSKPSMTPWaitingFromReply;
                        
						NSString *mailFrom = server8bitMessages ? [NSString stringWithFormat:@"MAIL FROM:<%@> BODY=8BITMIME\r\n", fromEmail] : [NSString stringWithFormat:@"MAIL FROM:<%@>\r\n", fromEmail];
#ifdef DEBUG
                        NSLog(@"C: %@", mailFrom);
#endif
                        if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[mailFrom cStringUsingEncoding:NSASCIIStringEncoding], [mailFrom lengthOfBytesUsingEncoding:NSASCIIStringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    else if ([tmpLine hasPrefix:@"535 "])
                    {
                        error =[NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                   code:kSKPSMTPErrorInvalidUserPass 
                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Invalid username or password.", @"server login fail error description"),NSLocalizedDescriptionKey,
                                                         NSLocalizedString(@"Go to Email Preferences in the application and re-enter your username and password.", @"server login error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
                        encounteredError = YES;
                    }
                    break;
                }
                
                case kSKPSMTPWaitingFromReply:
                {
					// toc 2009-02-18 begin changes per mdesaro issue 18 - http://code.google.com/p/skpsmtpmessage/issues/detail?id=18
					// toc 2009-02-18 begin changes to support cc & bcc
					
                    if ([tmpLine hasPrefix:@"250 "]) {
                        sendState = kSKPSMTPWaitingToReply;
                        
						NSMutableString	*multipleRcptTo = [NSMutableString string];
						[multipleRcptTo appendString:[self formatAddresses:toEmail]];
						[multipleRcptTo appendString:[self formatAddresses:ccEmail]];
						[multipleRcptTo appendString:[self formatAddresses:bccEmail]];
						
#ifdef DEBUG
                        NSLog(@"C: %@", multipleRcptTo);
#endif
                        if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[multipleRcptTo UTF8String], [multipleRcptTo lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    break;
                }
                case kSKPSMTPWaitingToReply:
                {
                    if ([tmpLine hasPrefix:@"250 "])
                    {
                        sendState = kSKPSMTPWaitingForEnterMail;
                        
						NSString *dataString = @"DATA\r\n";
#ifdef DEBUG
                        NSLog(@"C: %@", dataString);
#endif
                        if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[dataString UTF8String], [dataString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    else if ([tmpLine hasPrefix:@"530 "])
                    {
                        error =[NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                   code:kSKPSMTPErrorNoRelay 
                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Relay rejected.", @"server relay fail error description"),NSLocalizedDescriptionKey,
                                                        NSLocalizedString(@"Your server probably requires a username and password.", @"server relay fail error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
                        encounteredError = YES;
                    }
                    else if ([tmpLine hasPrefix:@"550 "])
                    {
                        error =[NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                   code:kSKPSMTPErrorInvalidMessage 
                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"To address rejected.", @"server to address fail error description"),NSLocalizedDescriptionKey,
                                                         NSLocalizedString(@"Please re-enter the To: address.", @"server to address fail error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
                        encounteredError = YES;
                    }
                    break;
                }
                case kSKPSMTPWaitingForEnterMail:
                {
                    if ([tmpLine hasPrefix:@"354 "])
                    {
                        sendState = kSKPSMTPWaitingSendSuccess;
                        
                        if (![self sendParts])
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                    }
                    break;
                }
                case kSKPSMTPWaitingSendSuccess:
                {
                    if ([tmpLine hasPrefix:@"250 "])
                    {
                        sendState = kSKPSMTPWaitingQuitReply;
                        
						NSString *quitString = @"QUIT\r\n";
#ifdef DEBUG
                        NSLog(@"C: %@", quitString);
#endif
                        if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[quitString UTF8String], [quitString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
                        {
                            error =  [outputStream streamError];
                            encounteredError = YES;
                        }
                        else
                        {
                            [self startShortWatchdog];
                        }
                    }
                    else if ([tmpLine hasPrefix:@"550 "])
                    {
                        error =[NSError errorWithDomain:@"SKPSMTPMessageError" 
                                                   code:kSKPSMTPErrorInvalidMessage 
                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Failed to logout.", @"server logout fail error description"),NSLocalizedDescriptionKey,
                                                         NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
                        encounteredError = YES;
                    }
                }
                case kSKPSMTPWaitingQuitReply:
                {
                    if ([tmpLine hasPrefix:@"221 "])
                    {
                        sendState = kSKPSMTPMessageSent;
                        
                        messageSent = YES;
                    }
                }
            }
            
        }
        else
        {
            break;
        }
    }
    self.inputString = [[inputString substringFromIndex:[scanner scanLocation]] mutableCopy];
    
    if (messageSent)
    {
        [self cleanUpStreams];
        
        [delegate messageSent:self];
    }
    else if (encounteredError)
    {
        [self cleanUpStreams];
        
        [delegate messageFailed:self error:error];
    }
}

- (BOOL)sendParts
{
    NSMutableString *message = [[NSMutableString alloc] init];
    static NSString *separatorString = @"--SKPSMTPMessage--Separator--Delimiter\r\n";
    
	CFUUIDRef	uuidRef   = CFUUIDCreate(kCFAllocatorDefault);
	NSString	*uuid     = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
	CFRelease(uuidRef);
    
    NSDate *now = [[NSDate alloc] init];
	NSDateFormatter	*dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
	
	[message appendFormat:@"Date: %@\r\n", [dateFormatter stringFromDate:now]];
	[message appendFormat:@"Message-id: <%@@%@>\r\n", [(NSString *)uuid stringByReplacingOccurrencesOfString:@"-" withString:@""], self.relayHost];
	
    //[now release];
    //[dateFormatter release];
    //[uuid release];
    
    [message appendFormat:@"From:%@\r\n", fromEmail];
	
    
	if ((self.toEmail != nil) && (![self.toEmail isEqualToString:@""])) 
    {
		[message appendFormat:@"To:%@\r\n", self.toEmail];		
	}

	if ((self.ccEmail != nil) && (![self.ccEmail isEqualToString:@""])) 
    {
		[message appendFormat:@"Cc:%@\r\n", self.ccEmail];		
	}
    
    [message appendString:@"Content-Type: multipart/mixed; boundary=SKPSMTPMessage--Separator--Delimiter\r\n"];
    [message appendString:@"Mime-Version: 1.0 (SKPSMTPMessage 1.0)\r\n"];
    [message appendFormat:@"Subject:%@\r\n\r\n",subject];
    [message appendString:separatorString];
    
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    //[message release];
	
#ifdef DEBUG
    NSLog(@"C: %s", [messageData bytes]);
#endif
    if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[messageData bytes], [messageData length]) < 0)
    {
        return NO;
    }
    
    message = [[NSMutableString alloc] init];
    
    for (NSDictionary *part in parts)
    {
		if (!part) continue;
        if ([part objectForKey:kSKPSMTPPartContentDispositionKey])
        {
            [message appendFormat:@"Content-Disposition: %@\r\n", [part objectForKey:kSKPSMTPPartContentDispositionKey]];
        }
        [message appendFormat:@"Content-Type: %@\r\n", [part objectForKey:kSKPSMTPPartContentTypeKey]];
        [message appendFormat:@"Content-Transfer-Encoding: %@\r\n\r\n", [part objectForKey:kSKPSMTPPartContentTransferEncodingKey]];
        [message appendString:[part objectForKey:kSKPSMTPPartMessageKey]];
        [message appendString:@"\r\n"];
        [message appendString:separatorString];
    }
    
    [message appendString:@"\r\n.\r\n"];
	
#ifdef DEBUG
    NSLog(@"C: %@", message);
#endif
    if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)outputStream, (const uint8_t *)[message UTF8String], [message lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
    {
        //[message release];
        return NO;
    }
    [self startLongWatchdog];
    //[message release];
    return YES;
}

- (void)connectionConnectedCheck:(NSTimer *)aTimer
{
    if (sendState == kSKPSMTPConnecting)
    {
        [inputStream close];
        [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
        //[inputStream release];
        inputStream = nil;
        
        [outputStream close];
        [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
        //[outputStream release];
        outputStream = nil;
        
        // Try the next port - if we don't have another one to try, this will fail
        sendState = kSKPSMTPIdle;
        [self send];
    }
    
    self.connectTimer = nil;
}

- (void)cleanUpStreams
{
    [inputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSDefaultRunLoopMode];
    //[inputStream release];
    inputStream = nil;
    
    [outputStream close];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                            forMode:NSDefaultRunLoopMode];
    //[outputStream release];
    outputStream = nil;
}

@end

#include <math.h>

extern size_t EstimateBas64EncodedDataSize(size_t inDataSize);
extern size_t EstimateBas64DecodedDataSize(size_t inDataSize);

extern bool Base64EncodeData(const void *inInputData, size_t inInputDataSize, char *outOutputData, size_t *ioOutputDataSize, BOOL wrapped);
extern bool Base64DecodeData(const void *inInputData, size_t inInputDataSize, void *ioOutputData, size_t *ioOutputDataSize);

const UInt8 kBase64EncodeTable[64] = {
	/*  0 */ 'A',	/*  1 */ 'B',	/*  2 */ 'C',	/*  3 */ 'D',
	/*  4 */ 'E',	/*  5 */ 'F',	/*  6 */ 'G',	/*  7 */ 'H',
	/*  8 */ 'I',	/*  9 */ 'J',	/* 10 */ 'K',	/* 11 */ 'L',
	/* 12 */ 'M',	/* 13 */ 'N',	/* 14 */ 'O',	/* 15 */ 'P',
	/* 16 */ 'Q',	/* 17 */ 'R',	/* 18 */ 'S',	/* 19 */ 'T',
	/* 20 */ 'U',	/* 21 */ 'V',	/* 22 */ 'W',	/* 23 */ 'X',
	/* 24 */ 'Y',	/* 25 */ 'Z',	/* 26 */ 'a',	/* 27 */ 'b',
	/* 28 */ 'c',	/* 29 */ 'd',	/* 30 */ 'e',	/* 31 */ 'f',
	/* 32 */ 'g',	/* 33 */ 'h',	/* 34 */ 'i',	/* 35 */ 'j',
	/* 36 */ 'k',	/* 37 */ 'l',	/* 38 */ 'm',	/* 39 */ 'n',
	/* 40 */ 'o',	/* 41 */ 'p',	/* 42 */ 'q',	/* 43 */ 'r',
	/* 44 */ 's',	/* 45 */ 't',	/* 46 */ 'u',	/* 47 */ 'v',
	/* 48 */ 'w',	/* 49 */ 'x',	/* 50 */ 'y',	/* 51 */ 'z',
	/* 52 */ '0',	/* 53 */ '1',	/* 54 */ '2',	/* 55 */ '3',
	/* 56 */ '4',	/* 57 */ '5',	/* 58 */ '6',	/* 59 */ '7',
	/* 60 */ '8',	/* 61 */ '9',	/* 62 */ '+',	/* 63 */ '/'
};

/*
 -1 = Base64 end of data marker.
 -2 = White space (tabs, cr, lf, space)
 -3 = Noise (all non whitespace, non-base64 characters)
 -4 = Dangerous noise
 -5 = Illegal noise (null byte)
 */

const SInt8 kBase64DecodeTable[128] = {
	/* 0x00 */ -5, 	/* 0x01 */ -3, 	/* 0x02 */ -3, 	/* 0x03 */ -3,
	/* 0x04 */ -3, 	/* 0x05 */ -3, 	/* 0x06 */ -3, 	/* 0x07 */ -3,
	/* 0x08 */ -3, 	/* 0x09 */ -2, 	/* 0x0a */ -2, 	/* 0x0b */ -2,
	/* 0x0c */ -2, 	/* 0x0d */ -2, 	/* 0x0e */ -3, 	/* 0x0f */ -3,
	/* 0x10 */ -3, 	/* 0x11 */ -3, 	/* 0x12 */ -3, 	/* 0x13 */ -3,
	/* 0x14 */ -3, 	/* 0x15 */ -3, 	/* 0x16 */ -3, 	/* 0x17 */ -3,
	/* 0x18 */ -3, 	/* 0x19 */ -3, 	/* 0x1a */ -3, 	/* 0x1b */ -3,
	/* 0x1c */ -3, 	/* 0x1d */ -3, 	/* 0x1e */ -3, 	/* 0x1f */ -3,
	/* ' ' */ -2,	/* '!' */ -3,	/* '"' */ -3,	/* '#' */ -3,
	/* '$' */ -3,	/* '%' */ -3,	/* '&' */ -3,	/* ''' */ -3,
	/* '(' */ -3,	/* ')' */ -3,	/* '*' */ -3,	/* '+' */ 62,
	/* ',' */ -3,	/* '-' */ -3,	/* '.' */ -3,	/* '/' */ 63,
	/* '0' */ 52,	/* '1' */ 53,	/* '2' */ 54,	/* '3' */ 55,
	/* '4' */ 56,	/* '5' */ 57,	/* '6' */ 58,	/* '7' */ 59,
	/* '8' */ 60,	/* '9' */ 61,	/* ':' */ -3,	/* ';' */ -3,
	/* '<' */ -3,	/* '=' */ -1,	/* '>' */ -3,	/* '?' */ -3,
	/* '@' */ -3,	/* 'A' */ 0,	/* 'B' */  1,	/* 'C' */  2,
	/* 'D' */  3,	/* 'E' */  4,	/* 'F' */  5,	/* 'G' */  6,
	/* 'H' */  7,	/* 'I' */  8,	/* 'J' */  9,	/* 'K' */ 10,
	/* 'L' */ 11,	/* 'M' */ 12,	/* 'N' */ 13,	/* 'O' */ 14,
	/* 'P' */ 15,	/* 'Q' */ 16,	/* 'R' */ 17,	/* 'S' */ 18,
	/* 'T' */ 19,	/* 'U' */ 20,	/* 'V' */ 21,	/* 'W' */ 22,
	/* 'X' */ 23,	/* 'Y' */ 24,	/* 'Z' */ 25,	/* '[' */ -3,
	/* '\' */ -3,	/* ']' */ -3,	/* '^' */ -3,	/* '_' */ -3,
	/* '`' */ -3,	/* 'a' */ 26,	/* 'b' */ 27,	/* 'c' */ 28,
	/* 'd' */ 29,	/* 'e' */ 30,	/* 'f' */ 31,	/* 'g' */ 32,
	/* 'h' */ 33,	/* 'i' */ 34,	/* 'j' */ 35,	/* 'k' */ 36,
	/* 'l' */ 37,	/* 'm' */ 38,	/* 'n' */ 39,	/* 'o' */ 40,
	/* 'p' */ 41,	/* 'q' */ 42,	/* 'r' */ 43,	/* 's' */ 44,
	/* 't' */ 45,	/* 'u' */ 46,	/* 'v' */ 47,	/* 'w' */ 48,
	/* 'x' */ 49,	/* 'y' */ 50,	/* 'z' */ 51,	/* '{' */ -3,
	/* '|' */ -3,	/* '}' */ -3,	/* '~' */ -3,	/* 0x7f */ -3
};

const UInt8 kBits_00000011 = 0x03;
const UInt8 kBits_00001111 = 0x0F;
const UInt8 kBits_00110000 = 0x30;
const UInt8 kBits_00111100 = 0x3C;
const UInt8 kBits_00111111 = 0x3F;
const UInt8 kBits_11000000 = 0xC0;
const UInt8 kBits_11110000 = 0xF0;
const UInt8 kBits_11111100 = 0xFC;

size_t EstimateBas64EncodedDataSize(size_t inDataSize)
{
	size_t theEncodedDataSize = (int)ceil(inDataSize / 3.0) * 4;
	theEncodedDataSize = theEncodedDataSize / 72 * 74 + theEncodedDataSize % 72;
	return(theEncodedDataSize);
}

size_t EstimateBas64DecodedDataSize(size_t inDataSize)
{
	size_t theDecodedDataSize = (int)ceil(inDataSize / 4.0) * 3;
	//theDecodedDataSize = theDecodedDataSize / 72 * 74 + theDecodedDataSize % 72;
	return(theDecodedDataSize);
}

bool Base64EncodeData(const void *inInputData, size_t inInputDataSize, char *outOutputData, size_t *ioOutputDataSize, BOOL wrapped)
{
	size_t theEncodedDataSize = EstimateBas64EncodedDataSize(inInputDataSize);
	if (*ioOutputDataSize < theEncodedDataSize)
		return(false);
	*ioOutputDataSize = theEncodedDataSize;
	const UInt8 *theInPtr = (const UInt8 *)inInputData;
	UInt32 theInIndex = 0, theOutIndex = 0;
	for (; theInIndex < (inInputDataSize / 3) * 3; theInIndex += 3)
	{
		outOutputData[theOutIndex++] = kBase64EncodeTable[(theInPtr[theInIndex] & kBits_11111100) >> 2];
		outOutputData[theOutIndex++] = kBase64EncodeTable[(theInPtr[theInIndex] & kBits_00000011) << 4 | (theInPtr[theInIndex + 1] & kBits_11110000) >> 4];
		outOutputData[theOutIndex++] = kBase64EncodeTable[(theInPtr[theInIndex + 1] & kBits_00001111) << 2 | (theInPtr[theInIndex + 2] & kBits_11000000) >> 6];
		outOutputData[theOutIndex++] = kBase64EncodeTable[(theInPtr[theInIndex + 2] & kBits_00111111) >> 0];
		if (wrapped && (theOutIndex % 74 == 72))
		{
			outOutputData[theOutIndex++] = '\r';
			outOutputData[theOutIndex++] = '\n';
		}
	}
	const size_t theRemainingBytes = inInputDataSize - theInIndex;
	if (theRemainingBytes == 1)
	{
		outOutputData[theOutIndex++] = kBase64EncodeTable[(theInPtr[theInIndex] & kBits_11111100) >> 2];
		outOutputData[theOutIndex++] = kBase64EncodeTable[(theInPtr[theInIndex] & kBits_00000011) << 4 | (0 & kBits_11110000) >> 4];
		outOutputData[theOutIndex++] = '=';
		outOutputData[theOutIndex++] = '=';
		if (wrapped && (theOutIndex % 74 == 72))
		{
			outOutputData[theOutIndex++] = '\r';
			outOutputData[theOutIndex++] = '\n';
		}
	}
	else if (theRemainingBytes == 2)
	{
		outOutputData[theOutIndex++] = kBase64EncodeTable[(theInPtr[theInIndex] & kBits_11111100) >> 2];
		outOutputData[theOutIndex++] = kBase64EncodeTable[(theInPtr[theInIndex] & kBits_00000011) << 4 | (theInPtr[theInIndex + 1] & kBits_11110000) >> 4];
		outOutputData[theOutIndex++] = kBase64EncodeTable[(theInPtr[theInIndex + 1] & kBits_00001111) << 2 | (0 & kBits_11000000) >> 6];
		outOutputData[theOutIndex++] = '=';
		if (wrapped && (theOutIndex % 74 == 72))
		{
			outOutputData[theOutIndex++] = '\r';
			outOutputData[theOutIndex++] = '\n';
		}
	}
	return(true);
}

bool Base64DecodeData(const void *inInputData, size_t inInputDataSize, void *ioOutputData, size_t *ioOutputDataSize)
{
	memset(ioOutputData, '.', *ioOutputDataSize);
	
	size_t theDecodedDataSize = EstimateBas64DecodedDataSize(inInputDataSize);
	if (*ioOutputDataSize < theDecodedDataSize)
		return(false);
	*ioOutputDataSize = 0;
	const UInt8 *theInPtr = (const UInt8 *)inInputData;
	UInt8 *theOutPtr = (UInt8 *)ioOutputData;
	size_t theInIndex = 0, theOutIndex = 0;
	UInt8 theOutputOctet = '\0';
	size_t theSequence = 0;
	for (; theInIndex < inInputDataSize; )
	{
		SInt8 theSextet = 0;
		
		SInt8 theCurrentInputOctet = theInPtr[theInIndex];
		theSextet = kBase64DecodeTable[theCurrentInputOctet];
		if (theSextet == -1)
			break;
		while (theSextet == -2)
		{
			theCurrentInputOctet = theInPtr[++theInIndex];
			theSextet = kBase64DecodeTable[theCurrentInputOctet];
		}
		while (theSextet == -3)
		{
			theCurrentInputOctet = theInPtr[++theInIndex];
			theSextet = kBase64DecodeTable[theCurrentInputOctet];
		}
		if (theSequence == 0)
		{
			theOutputOctet = (theSextet >= 0 ? theSextet : 0) << 2 & kBits_11111100;
		}
		else if (theSequence == 1)
		{
			theOutputOctet |= (theSextet >- 0 ? theSextet : 0) >> 4 & kBits_00000011;
			theOutPtr[theOutIndex++] = theOutputOctet;
		}
		else if (theSequence == 2)
		{
			theOutputOctet = (theSextet >= 0 ? theSextet : 0) << 4 & kBits_11110000;
		}
		else if (theSequence == 3)
		{
			theOutputOctet |= (theSextet >= 0 ? theSextet : 0) >> 2 & kBits_00001111;
			theOutPtr[theOutIndex++] = theOutputOctet;
		}
		else if (theSequence == 4)
		{
			theOutputOctet = (theSextet >= 0 ? theSextet : 0) << 6 & kBits_11000000;
		}
		else if (theSequence == 5)
		{
			theOutputOctet |= (theSextet >= 0 ? theSextet : 0) >> 0 & kBits_00111111;
			theOutPtr[theOutIndex++] = theOutputOctet;
		}
		theSequence = (theSequence + 1) % 6;
		if (theSequence != 2 && theSequence != 4)
			theInIndex++;
	}
	*ioOutputDataSize = theOutIndex;
	return(true);
}

#pragma mark - NSData+Base64Additions
@implementation NSData (Base64Additions)
+(id)decodeBase64ForString:(NSString *)decodeString
{
	NSData *decodeBuffer = nil;
	// Must be 7-bit clean!
	NSData *tmpData = [decodeString dataUsingEncoding:NSASCIIStringEncoding];
	
	size_t estSize = EstimateBas64DecodedDataSize([tmpData length]);
	uint8_t* outBuffer = calloc(estSize, sizeof(uint8_t));
	
	size_t outBufferLength = estSize;
	if (Base64DecodeData([tmpData bytes], [tmpData length], outBuffer, &outBufferLength))
	{
		decodeBuffer = [NSData dataWithBytesNoCopy:outBuffer length:outBufferLength freeWhenDone:YES];
	}
	else
	{
		free(outBuffer);
		[NSException raise:@"NSData+Base64AdditionsException" format:@"Unable to decode data!"];
	}
	
	return decodeBuffer;
}
+(id)decodeWebSafeBase64ForString:(NSString *)decodeString
{
	return [NSData decodeBase64ForString:[[decodeString stringByReplacingOccurrencesOfString:@"-" withString:@"+"] stringByReplacingOccurrencesOfString:@"_" withString:@"/"]];
}
-(NSString *)encodeBase64ForData
{
	NSString *encodedString = nil;
	
	// Make sure this is nul-terminated.
	size_t outBufferEstLength = EstimateBas64EncodedDataSize([self length]) + 1;
	char *outBuffer = calloc(outBufferEstLength, sizeof(char));
	
	size_t outBufferLength = outBufferEstLength;
	if (Base64EncodeData([self bytes], [self length], outBuffer, &outBufferLength, FALSE))
	{
		encodedString = [NSString stringWithCString:outBuffer encoding:NSASCIIStringEncoding];
	}
	else
	{
		[NSException raise:@"NSData+Base64AdditionsException" format:@"Unable to encode data!"];
	}
	
	free(outBuffer);
	
	return encodedString;
}
-(NSString *)encodeWebSafeBase64ForData
{
	return [[[self encodeBase64ForData] stringByReplacingOccurrencesOfString:@"+" withString:@"-"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
}
-(NSString *)encodeWrappedBase64ForData
{
	NSString *encodedString = nil;
	
	// Make sure this is nul-terminated.
	size_t outBufferEstLength = EstimateBas64EncodedDataSize([self length]) + 1;
	char *outBuffer = calloc(outBufferEstLength, sizeof(char));
	
	size_t outBufferLength = outBufferEstLength;
	if (Base64EncodeData([self bytes], [self length], outBuffer, &outBufferLength, TRUE))
	{
		encodedString = [NSString stringWithCString:outBuffer encoding:NSASCIIStringEncoding];
	}
	else
	{
		[NSException raise:@"NSData+Base64AdditionsException" format:@"Unable to encode data!"];
	}
	
	free(outBuffer);
	
	return encodedString;
}
@end
