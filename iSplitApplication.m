#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UITextField.h>
#import <UIKit/UITextLabel.h>
#import <UIKit/UIKeyboard.h>
#import <UIKit/UIKeyboardLayout.h>
#import <UIKit/UIView-Deprecated.h>
#import <UIKit/UIKeyboardLayoutQWERTY.h>
#import <UIKit/UIKeyboardLayoutQWERTYLandscape.h>
#import <UIKit/UIKeyboardLayout.h>
#import <UIKit/UIKeyboardImpl.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIKeyboardLayoutQWERTY-UI_QWERTY_NumbersAndPunctuationTransparent.h>
#import <UIKit/UIKeyboardLayoutQWERTY-UI_QWERTY_NumberPad.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UINavBarButton.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIView.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UITable.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UITableColumn.h>
#import <UIKit/UITableCellRemoveControl.h>
#import <UIKit/UIAlertSheet.h>
#import <WebCore/WebFontCache.h>
#import "iSplitApplication.h"
#import "RowItem.h"
#import "TouchTable.h"
#import "TotalTable.h"
#import "HeaderTable.h"

@implementation iSplitApplication

//member variables
UIWindow *window;
UIView *mainView;
UINavigationBar *nav;
UINavigationBar *nav2;
UITableColumn *deleteCol;
HeaderTable *header;

UIAlertSheet *addSheet;
UIAlertSheet *taxSheet;
UIAlertSheet *tipSheet;

UIImage *unchecked;
UIImage *checked;
UIImage *uncheckedGray;
UIImage *checkedGray;


-(BOOL) _needsKeyboard
{
	return NO;
}

- (int) numberOfRowsInTable: (UITable *)table
{
	if([table isEqual: itemTable])
	   return [array count] + 3;
	else
	   return 1;
}

-(void)tableSelectionDidChange:(NSNotification*)notification
{
	if(editMode)
		return;
	UITable *currentTable = [notification object];
	if(!([currentTable isEqual: itemTable]) || ([itemTable getCurrentRow] >= [array count]))
		return;
	
	int index;
	for(index = 1; index < 6; index++)
	{
		[itemTable reloadCellAtRow:[itemTable lastHighlightedRow] column:index animated:YES];	
		[itemTable reloadCellAtRow:[itemTable getPreviousRow] column:index animated:YES];	
	}	
}

- (UITableCell *) table: (UITable *)table cellForRow: (int)row column: (UITableColumn *) col
{ 	
	//initialize the cell that will be returned for the given table, row, and column
	UIImageAndTextTableCell* newCell = [[UIImageAndTextTableCell alloc] init];
	//calculate the column based on the title of the column (all columns are named in order 0 to 4)
	int colValue = [[col title] intValue];
	
	/////////////////////////////////////////////////////////////////////////
	//Table cell return algorithms for the header cells (titles above items//
	/////////////////////////////////////////////////////////////////////////
	if([table isEqual: header])
	{
		UIButtonBar *background; //the background of the cell
		UITextLabel *title; //the text element of the cell
		NSString *titleString;  //the string that title will be set to
		if(colValue == 5) {
			
			background = [[UIButtonBar alloc] initWithFrame: CGRectMake(0.0f, -11.0f, 60.0f, 47.0f)];	
			[newCell addSubview:background];
			return newCell;
		}
		else if(colValue == 0) {
			title = [[UITextLabel alloc] initWithFrame: CGRectMake(10.0f, 0.0f, 60.0f, 40.0f)];
			background = [[UIButtonBar alloc] initWithFrame: CGRectMake(0.0f, -11.0f, 80.0f, 47.0f)];	
			[title setCentersHorizontally:(YES)];
			titleString = @"Totals";
		}
		else
		{
			title = [[UITextLabel alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 60.0f, 40.0f)];
			background = [[UIButtonBar alloc] initWithFrame: CGRectMake(0.0f, -11.0f, 66.0f, 47.0f)];
			[title setCentersHorizontally:(YES)];
			titleString = [NSString stringWithFormat:@"Party %i", colValue];
		}
		
		//create the title and give it the right attributes	
		[title setFont: [NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:10]];
		[title setText: titleString];		
		float backgroundColor[4]={0,0,0,0}; 
		[title setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), backgroundColor)];
		
		float textColor[4]={.95,.95,.95,1};
		[title setColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), textColor)];
		float shadowColor[4]={0,0,0,.5};
		[title setShadowColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), shadowColor)];
		
		//add the subviews to the cell
		[background addSubview: title];
		[newCell addSubview: background];
		
		//return the resulting cell
		return newCell;
	}
	/////////////////////////////////////////////////////////////////
	//Table cell return algorithms for the totals across the bottom//
	/////////////////////////////////////////////////////////////////
	else if([table isEqual: totalTable])
	{
		//create the visual elements properly for a given column
		UIButtonBar *background; //the background of the cell
		UITextLabel *title; //the text element of the cell
		NSString *titleString;  //the string that title will be set to
		if(colValue == 5) {
			
			background = [[UIButtonBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 60.0f, 47.0f)];	
			[newCell addSubview:background];
			return newCell;
		}
		
		//Calculate the column's total
		double totalColumnCost = 0.0;
		int index;
		for(index = 0; index < [array count]; index++)
		{
			totalColumnCost += [[[array objectAtIndex:index] getPartyPortion: colValue] doubleValue];
		}
		double taxAndTipPortion = 1.0;
		
		
		if(colValue == 0)
		{
			totalCost = totalColumnCost;
		}
		else if(totalCost > 0)
			taxAndTipPortion = totalColumnCost / totalCost;
		else taxAndTipPortion = 0;
				
						
		//add the portions of tax and tip to the total		
		totalColumnCost = totalColumnCost + (taxAndTipPortion * totalTax) + (taxAndTipPortion * tipDollars);
					
		if(colValue == 0) {
			title = [[UITextLabel alloc] initWithFrame: CGRectMake(13.0f, 3.0f, 60.0f, 40.0f)];
			background = [[UIButtonBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 80.0f, 47.0f)];	
			
			if(totalColumnCost < 10)
				titleString = [NSString stringWithFormat:@"     %.2f", totalColumnCost];
			else if ((totalColumnCost >= 10) && (totalColumnCost < 100))
				titleString = [NSString stringWithFormat:@"   %.2f", totalColumnCost];
			else if ((totalColumnCost >= 100) && (totalColumnCost < 1000))
				titleString = [NSString stringWithFormat:@" %.2f", totalColumnCost];
			else if (totalColumnCost >= 1000)
				titleString = @"Error";
			else
				titleString = [NSString stringWithFormat:@"%.2f", totalColumnCost];
		}
		else if(colValue == 4)
		{
			title = [[UITextLabel alloc] initWithFrame: CGRectMake(0.0f, 3.0f, 60.0f, 40.0f)];
			background = [[UIButtonBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 66.0f, 47.0f)];
			[title setCentersHorizontally:(YES)];
			if(totalColumnCost < 1000)
				titleString = [NSString stringWithFormat:@"%.2f", totalColumnCost];	
			else
				titleString = @"Error";
		}
		else 
		{
			title = [[UITextLabel alloc] initWithFrame: CGRectMake(0.0f, 3.0f, 60.0f, 40.0f)];
			background = [[UIButtonBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 60.0f, 47.0f)];
			[title setCentersHorizontally:(YES)];
			if(totalColumnCost < 1000)
				titleString = [NSString stringWithFormat:@"%.2f", totalColumnCost];	
			else
				titleString = @"Error";
		}
		
		//create the title and give it the right attributes	
		[title setFont: [NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:16]];
		[title setText: titleString];		
		float backgroundColor[4]={0,0,0,0}; 
		[title setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), backgroundColor)];
		
		float textColor[4]={.95,.95,.95,1};
		[title setColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), textColor)];
		float shadowColor[4]={0,0,0,.5};
		[title setShadowColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), shadowColor)];
		
		//add the subviews to the cell
		[background addSubview: title];
		[newCell addSubview: background];
		
		//return the resulting cell
		return newCell;
	}
	///////////////////////////////////////////////////////////////////
	//Table cell return algorithms for the items table (most complex)//
	///////////////////////////////////////////////////////////////////
	//no else needed because previous if returns in all cases (and there are only two tables)
	//from here down relates to the items table
	//declare int for selected row (for displaying enable/disabled cells)
	int selectedRow = [itemTable selectedRow];
	
	if (colValue == 5) 
	{		
		if((editMode) && (row < [array count]))
		{
			UITableCellRemoveControl *removeButton = [[UITableCellRemoveControl alloc] initWithFrame: CGRectMake(24.0f, 3.0f, 43.0f, 33.0f)];
			[removeButton showRemoveButton:(YES) animated:(NO)];
			[newCell addSubview: removeButton];			
		}
		return newCell;
	}
	if(colValue == 0)
	{
		UITextLabel *title2 = [[UITextLabel alloc] initWithFrame: CGRectMake(13.0f, 3.0f, 66.0f, 37.0f)];
		
		double itemCost = 0.0;
		NSString *cellTitle;
		if(row == [array count])
			itemCost = totalCost;
		else if(row == [array count] + 1)
		{
			
			itemCost = totalTax;
			
		}
		else if(row == [array count] + 2)
		{
			
			itemCost = tipDollars;
			
		}
		else
			itemCost = [[[array objectAtIndex: row] getItemCost] doubleValue];
		
		if(itemCost < 10)
			cellTitle = [NSString stringWithFormat:@"      %.2f", itemCost];
		else if ((itemCost >= 10) && (itemCost < 100))
			cellTitle = [NSString stringWithFormat:@"    %.2f", itemCost];
		else if ((itemCost >= 100) && (itemCost < 1000))
			cellTitle = [NSString stringWithFormat:@"  %.2f", itemCost];
		else if ((itemCost >= 1000))
			cellTitle = @"Error";			
		else
			cellTitle = [NSString stringWithFormat:@"%.2f", itemCost];
		
		float backgroundColor[4]={0,0,0,0}; 
		[title2 setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), backgroundColor)];
		[title2 setFont: [NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:16]];
		[title2 setText: cellTitle];		
		[newCell addSubview: title2];
		return newCell;
	}
	else
	{		
		if(row == [array count])
		{	
			if(colValue == 4)
				[newCell setTitle: @"Sub"];
			
			return newCell;
		}
		else if(row == [array count] + 1)
		{	
			if(colValue == 4)
				[newCell setTitle: @" Tax"];
			
			return newCell;
		}
		else if(row == [array count] + 2)
		{	
			if(colValue == 4)
				[newCell setTitle: @" Tip"];
			
			return newCell;
		}
			
		UIImageView *buttonView = [[UIImageView alloc] initWithFrame: CGRectMake(18.0f, 8.0f, 43.0f, 33.0f)];
		if([[[array objectAtIndex: row] getPartyPortion: colValue] doubleValue] > 0)
		{			
			if(row == selectedRow)
				[buttonView setImage:checked];
			else
				[buttonView setImage:checkedGray];
		}
		else
		{
			if(row == selectedRow)
				[buttonView setImage:unchecked];
			else
				[buttonView setImage:uncheckedGray];
		}
		[newCell addSubview: buttonView];
		[newCell setSeparatorStyle:(2)];
		return newCell;		
	}
}

//I still am not sure why this is here, must experiment later
- (void) acceleratedInX: (float)x Y:(float)y Z:(float)z {
	printf("%f %f %f", x, y, z);
}

//Called whenever a button is hit on any of the alertSheets
- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	if([sheet isEqual: addSheet])
	{
		if ( button == 1 )
		{
			if([[[sheet textField] text] doubleValue] >= 1000)
			{
				[addSheet setTitle: @"Cost must be less than 1000!"];
				return;
			}
			if([[[sheet textField] text] doubleValue] == 0)
			{
				[[addSheet keyboard] setPreferredKeyboardType:(1)];
				[[addSheet keyboard] showPreferredLayout];
				return;
			}
			RowItem *row = [[RowItem alloc] initWithAmount: [[[sheet textField] text] doubleValue]];
			
			[array addObject:row];
			//Calculate the column's total
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
				[itemTable reloadCellAtRow:[array count] + 2 column:0 animated:YES];
			}
			
			[itemTable reloadData];
			[totalTable reloadData];
			
		}
		else if ( button == 2 )
			NSLog(@"Cancel");
	}
	else if([sheet isEqual: taxSheet])
	{
		if ( button == 1 )
		{
			totalTax = [[[sheet textField] text] doubleValue];
			[itemTable reloadData];
			[totalTable reloadData];
		}
		else if ( button == 2 )
			NSLog(@"Cancel");
		
	}
	else if([sheet isEqual: tipSheet])
	{
		if ( button == 1 )
		{
			tipPercent = [[[sheet textField] text] doubleValue];
			if(tipPercent > 1)
				tipPercent = tipPercent / 100.0f;
			tipDollars = tipPercent * (totalCost + totalTax);
			
			tipUpdates = YES;
			
			[itemTable reloadData];
			[totalTable reloadData];
		}
		else if ( button == 2 )
		{
			tipDollars = [[[sheet textField] text] doubleValue];
			
			tipPercent = tipDollars / (totalCost + totalTax);
			
			tipUpdates = NO;
			
			[itemTable reloadData];
			[totalTable reloadData];
		}
		else if ( button == 3 )
			NSLog(@"Cancel");
	}
	
	[sheet dismiss];
}

//called whenever a button is hit on either of the nav bars
- (void)navigationBar:(UINavigationBar*)bar buttonClicked:(int)button
{
	if([bar isEqual: nav2])
	{
		if (button == 0) { // right button
			NSLog(@"Hit tip"); 
			NSArray *buttons = [NSArray arrayWithObjects:@"%", @"$", @"Cancel", nil];
			tipSheet = [[UIAlertSheet alloc] initWithTitle:@"Enter tip amount or %" buttons:buttons defaultButtonIndex:1 delegate:self context:self];
			
			[tipSheet addTextFieldWithValue:@"" label:@""];
			[tipSheet popupAlertAnimated:NO];
			[[tipSheet keyboard] setPreferredKeyboardType:(1)];
			[[tipSheet keyboard] showPreferredLayout];
		}
		else if (button == 1) { // left button
			NSLog(@"hit tax");
			NSArray *buttons = [NSArray arrayWithObjects:@"OK", @"Cancel", nil];
			taxSheet = [[UIAlertSheet alloc] initWithTitle:@"Enter total tax:" buttons:buttons defaultButtonIndex:1 delegate:self context:self];
			
			[taxSheet addTextFieldWithValue:@"" label:@""];		
			[taxSheet popupAlertAnimated:NO];
			[[taxSheet keyboard] setPreferredKeyboardType:(1)];
			[[taxSheet keyboard] showPreferredLayout];
		}
	}
	else
	{	
		if (button == 0) { // right button
			NSLog(@"Hit edit");
			if(editMode)
			{
				editMode = NO;
				
				int index;
				for(index = 0; index < [array count]; index++)
				{
					[itemTable reloadCellAtRow:index column:0 animated:YES];	
				}		
				[header slideLeft];
				[itemTable slideLeft];
				[totalTable slideLeft];	
				
				[bar setButton:(1) enabled:(YES)];
				[nav2 setButton:(0) enabled:(YES)];
				[nav2 setButton:(1) enabled:(YES)];
				[bar showButtonsWithLeftTitle:@"+" rightTitle:@"Edit"];
				
				return;	
					
			}
			else
			{
				if([array count] == 0)
				{
					NSArray *buttons = [NSArray arrayWithObjects:@"OK", nil];
					UIAlertSheet *editSheet = [[UIAlertSheet alloc] initWithTitle:@"No items to delete!" buttons:buttons defaultButtonIndex:1 delegate:self context:self];
					[editSheet popupAlertAnimated:YES];
					return;
				}
					
				int index;
				for(index = 1; index < 5; index++)
				{
					[itemTable reloadCellAtRow:[itemTable getCurrentRow] column:index animated:YES];	
				}	
				[header slideRight];
				[itemTable slideRight];
				[totalTable slideRight];
				
				editMode = YES;	
				for(index = 0; index < [array count]; index++)
				{
					[itemTable reloadCellAtRow:index column:0 animated:YES];	
				}	
				
				[bar setButton:(1) enabled:(NO)];
				[nav2 setButton:(0) enabled:(NO)];
				[nav2 setButton:(1) enabled:(NO)];
				[bar showButtonsWithLeftTitle:@"+" rightTitle:@"Done"];	
				[itemTable enableRowDeletion:(YES) animated:(YES)];
				[itemTable selectRow:(-1) byExtendingSelection:(NO)];
				
				
				return;
			}			
		}
		else if (button == 1) { // left button
			NSLog(@"hit add");
			if(editMode)
				return;
			NSString *countString = [NSString stringWithFormat: @"%i", count];
			
			NSArray *buttons = [NSArray arrayWithObjects:@"Add", @"Cancel", nil];
			addSheet = [[UIAlertSheet alloc] initWithTitle:@"Enter item cost:" buttons:buttons defaultButtonIndex:1 delegate:self context:self];
			
			[addSheet addTextFieldWithValue:@"" label:@""];
			
			[addSheet popupAlertAnimated:NO];			
			[[addSheet keyboard] setPreferredKeyboardType:(1)];
			
			[[addSheet keyboard] showPreferredLayout];
		}
	}
    
}

//////////////////////////////
//Application Initialization//
//////////////////////////////
- (void) applicationDidFinishLaunching: (id) unused
{

  window = [[UIWindow alloc] initWithContentRect: [UIHardware
						    fullScreenApplicationContentRect]];
							
	//initialize the window for app
	[window orderFront: self];
	[window makeKey: self];
	[window _setHidden: NO];

  array = [[NSMutableArray alloc] initWithCapacity:25];
  
  //initialize the images
  checked = [[UIImage alloc] initWithContentsOfFile: @"/Applications/iSplit.app/checked3.png"];
  unchecked = [[UIImage alloc] initWithContentsOfFile: @"/Applications/iSplit.app/unchecked3.png"];
  checkedGray = [[UIImage alloc] initWithContentsOfFile: @"/Applications/iSplit.app/checkedGray3.png"];
  uncheckedGray = [[UIImage alloc] initWithContentsOfFile: @"/Applications/iSplit.app/uncheckedGray3.png"];
  
  //initialize tax and tip values
  totalTax = 0.0;
  tipDollars = 0.0;
  tipPercent = 0.0;
  tipUpdates = NO;
  editMode = NO;
  
  //Rows formerly used for debugging
  int count;
  /*for(count = 1; count < 20; count++)
	  [array addObject:[[RowItem alloc] initWithAmount: 100 + count]];*/
  
  //declare the 6 table columns (the delete column is usually off the screen to the left, but is always there
  deleteCol = [[UITableColumn alloc] initWithTitle: @"5" identifier: @"Delete" width: 60.0f]; 
  UITableColumn *moneyCol = [[UITableColumn alloc] initWithTitle: @"0"
					      identifier: @"Amount" width: 74.0f]; 
  UITableColumn *totalMoneyCol = [[UITableColumn alloc] initWithTitle: @"0"
													  identifier: @"Amount" width: 74.0f]; 
  UITableColumn *party1Col = [[UITableColumn alloc] initWithTitle: @"1" identifier: @"Party1" width: 60.0f]; 
  UITableColumn *party2Col = [[UITableColumn alloc] initWithTitle: @"2" identifier: @"Party2" width: 60.0f]; 
  UITableColumn *party3Col = [[UITableColumn alloc] initWithTitle: @"3" identifier: @"Party3" width: 60.0f]; 
  UITableColumn *party4Col = [[UITableColumn alloc] initWithTitle: @"4" identifier: @"Party4" width: 66.0f]; 
  
  //initialize the item table
  itemTable = [[TouchTable alloc] initWithFrame: CGRectMake(-60.0f, 65.0f, 380.0f, 349.0f)]; 
  [itemTable setSeparatorStyle:1];
  [itemTable addTableColumn: deleteCol];
  [itemTable addTableColumn: moneyCol]; 
  [itemTable addTableColumn: party1Col]; 
  [itemTable addTableColumn: party2Col]; 
  [itemTable addTableColumn: party3Col]; 
  [itemTable addTableColumn: party4Col]; 
  [itemTable setDataSource: self];
  [itemTable setDelegate: self];
  [itemTable reloadData];
  [itemTable setRowHeight:41.0f];
  
  //initialize the total table
  totalTable = [[TotalTable alloc] initWithFrame: CGRectMake(-60.0f, 414.0f, 380.0f, 46.0f)]; 
  [totalTable addTableColumn: deleteCol];
  [totalTable addTableColumn: totalMoneyCol]; 
  [totalTable addTableColumn: party1Col]; 
  [totalTable addTableColumn: party2Col]; 
  [totalTable addTableColumn: party3Col]; 
  [totalTable addTableColumn: party4Col];    
  [totalTable setDataSource: self];
  [totalTable setDelegate: self];
  [totalTable reloadData];
  [totalTable setRowHeight:47.0f];
  [totalTable setScrollingEnabled:NO];
  
  //initialize the header table
  header = [[HeaderTable alloc] initWithFrame: CGRectMake(-60.0f, 45.0f, 380.0f, 19.0f)]; 
  [header addTableColumn: deleteCol];
  [header addTableColumn: totalMoneyCol]; 
  [header addTableColumn: party1Col]; 
  [header addTableColumn: party2Col]; 
  [header addTableColumn: party3Col]; 
  [header addTableColumn: party4Col];    
  [header setDataSource: self];
  [header setDelegate: self];
  [header reloadData];
  [header setRowHeight:47.0f];
  [header setScrollingEnabled:NO];
  
  //initialize the navigation bar for left and right most buttons
  nav = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 45.0f)];
  [nav showButtonsWithLeftTitle:@"+" rightTitle:@"Edit"];
  [nav setDelegate: self];
  
  //initialize navigation bar for middle two buttons
  nav2 = [[UINavigationBar alloc] initWithFrame: CGRectMake(87.0f, 0.0f, 146.0f, 45.0f)];
  [nav2 setBarStyle: 0];
  [nav2 showButtonsWithLeftTitle:@"Tax" rightTitle:@"Tip"];
  [nav2 setDelegate: self];

  //initalize the window to hold all the relevant views
  struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
  rect.origin.x = rect.origin.y = 0.0f;
  mainView = [[UIView alloc] initWithFrame: rect];  
  [mainView addSubview: nav];  
  [mainView addSubview: nav2];  
  [mainView addSubview: itemTable];
  [mainView addSubview: header];
  [mainView addSubview: totalTable];  
  [window setContentView: mainView]; 
}

@end
