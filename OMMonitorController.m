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
	NSTask *task = [[NSTask new] autorelease];
    [task setLaunchPath: @"/bin/bash"];
	
    [task setArguments: [NSArray arrayWithObjects: @"-c", @"ps awwwxu | grep beam.smp | grep -v grep", nil]];
	
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
	[task setStandardInput:[NSPipe pipe]];
    NSFileHandle *file = [pipe fileHandleForReading];
	
    [task launch];
	
	
	NSData *data = [file readDataToEndOfFile];
	NSString *procsStr = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
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
-(BOOL)overmindIsActive;
{
	return system("launchctl list | grep se.bth.real.grace") == 0;
}
-(void)determineIfOvermindIsActive;
{
	if([self overmindIsActive]) {// Overmind is active in launchd
		[activeControl setSelectedSegment:0];
		[restartButton setLabel:@"Restart" forSegment:0];
	} else {
		[activeControl setSelectedSegment:1];
		[restartButton setLabel:@"Shut down" forSegment:0];
	}
	
	[spinner stopAnimation:nil];
	
	[self performSelector:@selector(determineIfOvermindIsActive) withObject:nil afterDelay:1.0];
}
-(void)awakeFromNib;
{
	[GrowlApplicationBridge setGrowlDelegate:self];
	
	noColor = [[discoveryLabel textColor] retain];
	yesColor = [[overmindLabel textColor] retain];
	
	[self determineErlangProcessCount];
	[self determineIfOvermindIsActive];
}
-(IBAction)toggleActive:(NSSegmentedControl*)sender;
{
	[spinner startAnimation:nil];
	[activeControl setSelected:NO forSegment:0];
	[activeControl setSelected:NO forSegment:1];
	
	NSString *command = nil;
	BOOL wasActive = [self overmindIsActive];
	if(wasActive)
		command = @"launchctl unload -w /Library/LaunchAgents/se.bth.real.grace.plist";
	else
		command = @"launchctl load -w /Library/LaunchAgents/se.bth.real.grace.plist";
	
	int ret = system([command UTF8String]);
	
	if(ret != 0)
		[GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:@"Couldn't %@", wasActive?@"unload":@"load"]  description:@"Launchd wouldn't perform the given command. Check the log." notificationName:@"Warning" iconData:nil priority:0 isSticky:NO clickContext:nil];
	else
		system("killall beam.smp");
	
	// Spinner will deactivate and activeControl be set by determineIfOvermind… later
}
-(IBAction)restartErlang:(id)sender;
{
	if(system("killall beam.smp") != 0)
		[GrowlApplicationBridge notifyWithTitle:@"Couldn't restart/shutdown" description:@"Likely there were no Erlang processes running, or they weren't owned by you." notificationName:@"Warning" iconData:nil priority:0 isSticky:NO clickContext:nil];
}

-(IBAction)showConsole:(id)sender;
{
	system("open /Applications/Utilities/Console.app");
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
