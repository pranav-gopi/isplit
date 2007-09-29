//
//  rowItem.h
//  
//
//  Created by Brent Jensen on 9/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>


@interface RowItem : NSObject {
	NSMutableArray *amounts;
	 int partiesSharing;
}

-(id)initWithAmount: (double) amountArg;

-(NSNumber *)getItemCost;
-(NSNumber *)getPartyPortion: (int) party;

-(void)switchParty: (int) party row: (int) row;

@end
