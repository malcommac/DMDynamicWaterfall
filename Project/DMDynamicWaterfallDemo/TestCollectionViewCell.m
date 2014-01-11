//
//  TestCollectionViewCell.m
//  DMDynamicWaterfallDemo
//
//	Created by Daniele Margutti on 23.12.2013.
//  Copyright (c) 2013 danielemargutti. All rights reserved.
//

#import "TestCollectionViewCell.h"

@interface TestCollectionViewCell() {
	UILabel	*label;
	UIColor* bkColor;
}

@end

@implementation TestCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		label = [[UILabel alloc] initWithFrame:self.bounds];
		label.textAlignment = NSTextAlignmentCenter;
		label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		[self addSubview:label];
    }
    return self;
}

- (void) setString:(NSString *) text {
	label.text = text;
}

@end
