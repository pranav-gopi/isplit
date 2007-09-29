//
//  TouchTable.m
//  
//
//  Created by Brent Jensen on 9/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UITable.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UITransformAnimation.h>
#import <UIKit/UIAnimator.h>
#import <GraphicsServices/GraphicsServices.h>
#import "TouchTable.h"
#import <includes/CoreGraphics/CoreGraphics.h>
#import "iSplitApplication.h"
#import "RowItem.h"


@implementation TouchTable : UITable

- (int) getPreviousRow
{
	return previousRow;
}

- (int) getCurrentRow
{
	return currentRow;
}

- (BOOL) ignoresMouseEvents
{	
	return NO;
}

- (void)slideRight
{
	NSLog(@"Slide right called");
	UITransformAnimation *translate = [[UITransformAnimation alloc] initWithTarget:self];
	UIAnimator *animator = [[UIAnimator alloc] init];
	
	struct CGAffineTransform trans = CGAffineTransformMakeTranslation(60, 0);
	
	[self setFrame:CGRectMake(-60.0f, 65.0f, 380.0f, 349.0f)];
	[translate setStartTransform:CGAffineTransformMake(1,0,0,1,0,0)];
	[translate setEndTransform:trans];
	[animator addAnimation:translate withDuration:.2 start:YES];

}

- (void)slideLeft
{	
	NSLog(@"Slide right called");
	UITransformAnimation *translate = [[UITransformAnimation alloc] initWithTarget:self];
	UIAnimator *animator = [[UIAnimator alloc] init];
	
	struct CGAffineTransform trans = CGAffineTransformMakeTranslation(60, 0);
	
	[self setFrame:CGRectMake(0.0f, 65.0f, 380.0f, 349.0f)];
	[translate setStartTransform:trans];
	[translate setEndTransform:CGAffineTransformMake(1,0,0,1,0,0)];
	[animator addAnimation:translate withDuration:.2 start:YES];
	
	
}

- (void)mouseUp:(struct __GSEvent *) event
{	
	[super mouseUp:(event)];
	if(editMode)
	{
		[self selectRow:(-1) byExtendingSelection:(NO)];		
		return;
	}
	if ((currentRow >= [array count]) || (editMode)) {
		[self selectRow:(previousRow) byExtendingSelection:(NO)];
	}
	if(![self isDecelerating])
	{
		if([self selectedRow] < (_visibleRows.location + 9))
			[self scrollRectToVisible:([self rectOfRow:(_visibleRows.location)]) animated:(YES)];
	}
}

- (void)mouseDown:(struct __GSEvent *) event
{	
	CGRect hitPoint = GSEventGetLocationInWindow(event);
	int column = 0;
	previousRow = [self selectedRow];
	currentRow = _visibleRows.location + ((hitPoint.origin.y - 20)/ 41.0f) - 1;
	
	if(editMode)
	{
		[self selectRow:(-1) byExtendingSelection:(NO)];	
		if((hitPoint.origin.x <=80) && (currentRow < [array count]))
		{
			[array removeObjectAtIndex:(currentRow)];
			[self animateDeletionOfCellAtRow:(currentRow) column:(1) viaEdge:(3)];
			[totalTable reloadData];
			double totalColumnCost = 0.0;
			int index;
			for(index = 0; index < [array count]; index++)
			{
				totalColumnCost += [[[array objectAtIndex:index] getPartyPortion: 0] doubleValue];
			}
			totalCost = totalColumnCost;
			
			if (tipUpdates)
			{
				tipDollars = tipPercent * (totalCost + totalTax);
				[itemTable reloadCellAtRow:[array count] + 1 column:0 animated:YES];
			}
			
			[itemTable reloadCellAtRow:[array count] column:1 animated:YES];
			[itemTable reloadCellAtRow:[array count] + 2 column:1 animated:YES];
			
		}	
		return;
	}
		
	[super mouseDown:(event)];
	
	
	//NSLog(@"Row hit: %i, Selected Row: %i, Y-coord: %f", row, [self selectedRow], hitPoint.origin.y);
	if ((currentRow >= [array count]) || (editMode)) {		
		return;
	}
	
	if(currentRow != [self selectedRow])
	{		
		
		return;		
	}
	
	//NSLog(@"Point hit at %f", hitPoint.origin.x);
	
	if((hitPoint.origin.x >= 80) && (hitPoint.origin.x < 140))
	{
		column = 1;
	}
	else if((hitPoint.origin.x >= 140) && (hitPoint.origin.x < 200))
	{
	   column = 2;
	}
	else if((hitPoint.origin.x >= 200) && (hitPoint.origin.x < 260))
	{
		column = 3;
	}
	else if((hitPoint.origin.x >= 260) && (hitPoint.origin.x <= 320))
	{
		column = 4;
	}
	
	if(column != 0)
		[[array objectAtIndex: currentRow] switchParty: (column) row:(currentRow)];
	
	//NSLog(@"Point hit was in column %i, row %i", column, row);

}

@end
