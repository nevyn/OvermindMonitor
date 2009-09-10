//
//  OMMonitorController.h
//  OvermindMonitor
//
//  Created by Joachim Bengtsson on 2009-09-09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl-WithInstaller/Growl.h>

@interface OMMonitorController : NSObject <GrowlApplicationBridgeDelegate> {
	IBOutlet NSTextField *discoveryLabel;
	IBOutlet NSTextField *overmindLabel;
	IBOutlet NSTextField *otherLabel;
	IBOutlet NSSegmentedControl *activeControl;
	IBOutlet NSProgressIndicator *spinner;
	
	IBOutlet NSSegmentedControl *restartButton;
	
	BOOL discoveryIsOn;
	BOOL overmindIsOn;
	int otherErlangCount;
	
	NSColor *noColor, *yesColor;
}
-(IBAction)toggleActive:(NSSegmentedControl*)sender;
-(IBAction)restartErlang:(id)sender;
-(IBAction)showConsole:(id)sender;

@property BOOL discoveryIsOn;
@property BOOL overmindIsOn;
@property int otherErlangCount;
@end
