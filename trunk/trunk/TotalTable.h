//
//  TotalTable.h
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



@interface TotalTable : UITable {
	
}

-(void) slideRight;
-(void) slideLeft;
- (BOOL) ignoresMouseEvents;


@end
