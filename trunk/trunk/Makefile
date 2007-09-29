CC=arm-apple-darwin-cc
LD=$(CC)
LDFLAGS=-lm -lobjc -ObjC -framework CoreFoundation -framework Foundation -framework UIKit -framework LayerKit -framework GraphicsServices -framework CoreGraphics
LDFLAGS_FRAMEWORKSDIR=-F/Developer/SDKs/iphone/heavenly/System/Library/

all:	iSplit

iSplit:	iSplit.o iSplitApplication.o RowItem.o TouchTable.o TotalTable.o HeaderTable.o
	$(LD) $(LDFLAGS) -o $@ $^

%.o:	%.m
		$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:
		rm -f *.o iSplit

