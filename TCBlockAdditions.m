//
//  TCBlockAdditions.m
//  OrbAvoidance
//
//  Created by Joachim Bengtsson on 2009-09-02.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "TCBlockAdditions.h"

@implementation NSArray (TCFunctionalArray)
-(NSArray*)filteredArray:(TCArrayFilter)filter;
{
	NSMutableArray *filtered = [NSMutableArray arrayWithCapacity:[self count]];
	for (id obj in self) {
		if(filter(obj))
			[filtered addObject:obj];
	}
	return filtered;
}
-(NSArray*)map:(id(^)(id))mapper;
{
	NSMutableArray *res = [NSMutableArray arrayWithCapacity:[self count]];
	for (id obj in self)
		[res addObject:mapper(obj)];
	return res;
}

-(id)foldInitialValue:(id)initial with:(TCArrayFolder)folder;
{
	id current = initial;
	for(id element in self) {
		id old = current;
		current = folder(old, element);
	}
	return current;
}

@end

void TCOnMain(dispatch_block_t block)
{
	[[[block copy] autorelease] performSelectorInBackground:@selector(my_callBlock) withObject: nil];
}

@implementation NSObject (BlocksAdditions)

- (void)my_callBlock
{
	void (^block)(void) = (id)self;
	block();
}

@end

