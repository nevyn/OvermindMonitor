//
//  OMMonitorController.m
//  OvermindMonitor
//
//  Created by Joachim Bengtsson on 2009-09-09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OMMonitorController.h"
#import "TCBlockAdditions.h"

@implementation OMMonitorController
-(void)determineErlangProcessCount;
{	
	NSTask *task = [[[NSTask alloc] init] autorelease];
    [task setLaunchPath: @"/bin/bash"];
	
    [task setArguments: [NSArray arrayWithObjects: @"-c", @"ps awwwxu | grep beam.smp | grep -v grep", nil]];
	
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
	[task setStandardInput:[NSPipe pipe]];
    NSFileHandle *file = [pipe fileHandleForReading];
	
    [task launch];
	
	
	NSData *data = [file readDataToEndOfFile];
	NSString *procsStr = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	NSArray *procs = [procsStr componentsSeparatedByString:@"\n"];
	
	BOOL discoveryIsOnNow = NO;
	BOOL overmindIsOnNow = NO;
	int otherErlangCountNow = 0;
	
	for (NSString *proc in procs) {
		if([proc rangeOfString:@"-run discovery"].location != NSNotFound) {
			discoveryIsOnNow = YES;
		} else if([proc rangeOfString:@"-run om_standalone"].location != NSNotFound) {
			overmindIsOnNow = YES;
		} else if( ! [proc isEqual:@""] )
			otherErlangCountNow += 1;
	}
	
	self.discoveryIsOn = discoveryIsOnNow;
	self.overmindIsOn = overmindIsOnNow;
	self.otherErlangCount = otherErlangCountNow;
	
	
	[self performSelector:@selector(determineErlangProcessCount) withObject:nil afterDelay:1.0];
}
-(void)awakeFromNib;
{
	[GrowlApplicationBridge setGrowlDelegate:self];
	
	noColor = [discoveryLabel textColor];
	yesColor = [overmindLabel textColor];
	
	[self determineErlangProcessCount];
}
-(IBAction)toggleActive:(NSSegmentedControl*)sender;
{
	
}
-(IBAction)restartErlang:(id)sender;
{
	if(system("killall beam.smp") != 0)
		[GrowlApplicationBridge notifyWithTitle:@"Couldn't restart" description:@"Likely there were no Erlang processes running, or they weren't owned by you." notificationName:@"Warning" iconData:nil priority:0 isSticky:NO clickContext:nil];
}

@synthesize discoveryIsOn, overmindIsOn, otherErlangCount;
-(void)setDiscoveryIsOn:(BOOL)now;
{
	[discoveryLabel setStringValue:now?@"Discovery on":@"Discovery off"];
	[discoveryLabel setTextColor:now?yesColor:noColor];
	discoveryIsOn = now;
}
-(void)setOvermindIsOn:(BOOL)now;
{
	[overmindLabel setStringValue:now?@"Overmind on":@"Overmind off"];
	[overmindLabel setTextColor:now?yesColor:noColor];
	overmindIsOn = now;
}
-(void)setOtherErlangCount:(int)newCount;
{
	[otherLabel setStringValue:[NSString stringWithFormat:@"%d other Erlangs", newCount]];
	[otherLabel setTextColor:(newCount>0)?yesColor:noColor];
	otherErlangCount = newCount;
}
@end
