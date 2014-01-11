//
//  TestCollectionHeaderView.m
//  DMDynamicWaterfallDemo
//
//  Created by Daniele Margutti on 10/01/14.
//  Copyright (c) 2013 danielemargutti. All rights reserved.
//

#import "TestCollectionHeaderView.h"

@interface TestCollectionHeaderView() {
	UILabel	*label;
	UIColor* bkColor;
}

@end

@implementation TestCollectionHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		label = [[UILabel alloc] initWithFrame:self.bounds];
		label.textAlignment = NSTextAlignmentLeft;
		label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		[self addSubview:label];
		self.backgroundColor = [UIColor cyanColor];
    }
    return self;
}

- (void) setString:(NSString *) text {
	label.text = text;
}

@end
