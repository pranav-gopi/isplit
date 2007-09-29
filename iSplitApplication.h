#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import "TouchTable.h"
#import "TotalTable.h"

@interface iSplitApplication : UIApplication {
	
}

double totalTax;
double tipDollars;
double tipPercent;
BOOL tipUpdates;
double totalCost;

NSMutableArray *array;
TouchTable *itemTable;
TotalTable *totalTable;
BOOL editMode;

@end
