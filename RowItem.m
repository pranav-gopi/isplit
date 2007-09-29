//
//  rowItem.m
//  
//
//  Created by Brent Jensen on 9/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "RowItem.h"
#import "iSplitApplication.h"


@implementation RowItem	

-(id)initWithAmount: (double) amountArg {
	
	amounts = [[NSMutableArray alloc] init];
	[amounts addObject: [NSNumber numberWithDouble: amountArg]];	
	[amounts addObject: [NSNumber numberWithDouble: 0.0]];		
	[amounts addObject: [NSNumber numberWithDouble: 0.0]];		
	[amounts addObject: [NSNumber numberWithDouble: 0.0]];	
	[amounts addObject: [NSNumber numberWithDouble: 0.0]];
	
	
	partiesSharing = 0;
	
	return self;
}

-(NSNumber *) getItemCost {
	return [amounts objectAtIndex: 0];
}

-(NSNumber *)getPartyPortion: (int) party {
	//NSLog(@"Getting amount for party: %i", party);
	return [amounts objectAtIndex: party];
}

-(void)switchParty: (int) party row: (int) row {
	if (party == 0)
		return;

	if([[amounts objectAtIndex: party] doubleValue] == 0)
	{
		[amounts replaceObjectAtIndex: (party) withObject: [NSNumber numberWithDouble: 500.0]];
		
		partiesSharing = partiesSharing + 1;
		//NSLog(@"Parties sharing: %i, Item amount: %f", partiesSharing, [[amounts objectAtIndex: 0] intValue]);
		double individualPortion = ([[amounts objectAtIndex: 0] doubleValue]) / partiesSharing;
		//NSLog(@"Individual Portion: %f, Parties sharing: %i", individualPortion, partiesSharing);
		if([[amounts objectAtIndex: 1] doubleValue] > 0)
			[amounts replaceObjectAtIndex: (1) withObject: [NSNumber numberWithDouble: individualPortion]];
		if([[amounts objectAtIndex: 2] doubleValue] > 0)
			[amounts replaceObjectAtIndex: (2) withObject: [NSNumber numberWithDouble: individualPortion]];
		if([[amounts objectAtIndex: 3] doubleValue] > 0)
			[amounts replaceObjectAtIndex: (3) withObject: [NSNumber numberWithDouble: individualPortion]];
		if([[amounts objectAtIndex: 4] doubleValue] > 0)
			[amounts replaceObjectAtIndex: (4) withObject: [NSNumber numberWithDouble: individualPortion]];
		
	}
	else {
		[amounts replaceObjectAtIndex: (party) withObject: [NSNumber numberWithDouble: 0.0]];
		partiesSharing = partiesSharing - 1;
		double individualPortion = ([[amounts objectAtIndex: 0] doubleValue]) / partiesSharing;
		if([[amounts objectAtIndex: 1] doubleValue] > 0)
			[amounts replaceObjectAtIndex: (1) withObject: [NSNumber numberWithDouble: individualPortion]];
		if([[amounts objectAtIndex: 2] doubleValue] > 0)
			[amounts replaceObjectAtIndex: (2) withObject: [NSNumber numberWithDouble: individualPortion]];
		if([[amounts objectAtIndex: 3] doubleValue] > 0)
			[amounts replaceObjectAtIndex: (3) withObject: [NSNumber numberWithDouble: individualPortion]];
		if([[amounts objectAtIndex: 4] doubleValue] > 0)
			[amounts replaceObjectAtIndex: (4) withObject: [NSNumber numberWithDouble: individualPortion]];
	}

	
	[itemTable reloadCellAtRow:row column:party + 1 animated:YES];
	[totalTable reloadData];
}

- (void)dealloc {
	[super dealloc]; 
}

@end
