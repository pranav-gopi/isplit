//
//  TouchTable.h
//  
//
//  Created by Brent Jensen on 9/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UITable.h>
#import <UIKit/CDStructures.h>
#import <GraphicsServices/GraphicsServices.h>



@interface TouchTable : UITable {
	int currentRow, previousRow;
}
- (int) getPreviousRow;
- (int) getCurrentRow;
-(void) slideRight;
-(void) slideLeft;
- (BOOL) ignoresMouseEvents;
- (void)mouseUp:(struct __GSEvent *) event;
- (void)mouseDown:(struct __GSEvent *) event;


@end
