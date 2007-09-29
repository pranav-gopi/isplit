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
#import "HeaderTable.h"
#import <includes/CoreGraphics/CoreGraphics.h>
#import "iSplitApplication.h"
#import "RowItem.h"


@implementation HeaderTable : UITable

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
	
	[self setFrame:CGRectMake(-60.0f, 45.0f, 380.0f, 20.0f)];
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
	
	[self setFrame:CGRectMake(0.0f, 45.0f, 380.0f, 20.0f)];
	[translate setStartTransform:trans];
	[translate setEndTransform:CGAffineTransformMake(1,0,0,1,0,0)];
	[animator addAnimation:translate withDuration:.2 start:YES];
}

@end
