//
//  MainViewController.m
//  DMDynamicWaterfallDemo
//
//	Created by Daniele Margutti on 23.12.2013.
//  Copyright (c) 2013 danielemargutti. All rights reserved.
//

#import "MainViewController.h"
#import "DMDynamicWaterfall.h"

#import "TestCollectionViewCell.h"
#import "TestCollectionHeaderView.h"
#import "TestCollectionFooterView.h"

#define kTestCollectionViewCellID	@"TestCollectionViewCell"
#define kTestCollectionViewHeaderID	@"kTestCollectionViewHeaderID"
#define kTestCollectionViewFooterID	@"kTestCollectionViewFooterID"

@interface MainViewController () <UICollectionViewDataSource,DMDynamicWaterfallDelegate> {
	UICollectionView		*waterfallCollectionView;
	DMDynamicWaterfall		*waterfallLayout;
	
	NSMutableArray *heightsForItems;
	NSUInteger		numberOfSections;
	NSMutableArray *numberOfColumnsInSection;
}

@end

@implementation MainViewController

#pragma mark - Helper Functions -

NSUInteger randomValueInRange(NSUInteger lowerBound,NSUInteger upperBound) {
	return lowerBound + arc4random() % (upperBound - lowerBound);
}

UIColor *randomColor() {
	CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
	CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
	CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
	UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
	return color;
}

#pragma mark - Init -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self fillUpCollectionViewWithSampleData];
	
	waterfallLayout = [[DMDynamicWaterfall alloc] init];
	waterfallLayout.delegate = self;
	waterfallCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
												 collectionViewLayout:waterfallLayout];
	[waterfallCollectionView registerClass: [TestCollectionViewCell class]
				forCellWithReuseIdentifier: kTestCollectionViewCellID];
	
	[waterfallCollectionView registerClass: [TestCollectionHeaderView class]
				forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
					   withReuseIdentifier: kTestCollectionViewHeaderID];
	
	[waterfallCollectionView registerClass: [TestCollectionFooterView class]
				forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
					   withReuseIdentifier: kTestCollectionViewFooterID];
	
	waterfallCollectionView.backgroundColor = [UIColor lightGrayColor];
	waterfallCollectionView.dataSource = self;
	waterfallCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:waterfallCollectionView];
}

- (void) fillUpCollectionViewWithSampleData {
	// number of sections
	numberOfSections =  randomValueInRange(2, 5);
	NSLog(@"%lu sections",(unsigned long)numberOfSections);
	
	numberOfColumnsInSection = [[NSMutableArray alloc] init];
	heightsForItems = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
	for (NSUInteger sectionIdx = 0; sectionIdx < numberOfSections; ++sectionIdx) {
		
		// number of columns
		NSUInteger columnsInSection = randomValueInRange(2, 4);
		[numberOfColumnsInSection addObject:@(columnsInSection)];
		
		// number of items
		[heightsForItems addObject:[NSMutableArray array]];
		NSUInteger numberOfItemsInSection = randomValueInRange(5, 20);

		// heights of items
		NSLog(@"  section %lu has %lu columns and %lu items",(unsigned long)sectionIdx,(unsigned long)columnsInSection,(unsigned long)numberOfItemsInSection);
		for (NSUInteger itemIdx = 0 ; itemIdx < numberOfItemsInSection; ++itemIdx) {
			CGFloat heightOfItem = randomValueInRange(35, 120);
			[heightsForItems[sectionIdx] addObject:[NSValue valueWithCGSize:CGSizeMake(106, heightOfItem)]];
		}
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionView DataSource -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return numberOfSections;
}

- (NSUInteger)collectionView:(UICollectionView *)aCollectionView layout:(DMDynamicWaterfall *)aLayout numberOfColumnsInSection:(NSUInteger)aSectionIdx {
	return ((NSNumber*)numberOfColumnsInSection[aSectionIdx]).unsignedIntValue;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [heightsForItems[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	TestCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTestCollectionViewCellID forIndexPath:indexPath];
	cell.backgroundColor = randomColor();
	[cell setString:[NSString stringWithFormat:@"#%ld",(long)indexPath.item]];
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return [((NSValue*)heightsForItems[indexPath.section][indexPath.item]) CGSizeValue];
}

//- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForItemsInSection:(NSUInteger)aSectionIdx {
//	// with valid insets and dynamic enabled everything bounce without a logic (?)
//	// why?
//	return UIEdgeInsetsMake(0, 0, 0, 0);
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath; {
	if (kind == UICollectionElementKindSectionHeader) {
		TestCollectionHeaderView *titleView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
																				 withReuseIdentifier: kTestCollectionViewHeaderID
																						forIndexPath: indexPath];
		[titleView setString:[NSString stringWithFormat: @"  Section %ld", (long)indexPath.section]];
		return titleView;
	} else {
		TestCollectionFooterView *titleView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
																				 withReuseIdentifier: kTestCollectionViewFooterID
																						forIndexPath: indexPath];
		return titleView;
	}
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
 heightForHeaderAtIndexPath:(NSIndexPath *)indexPath {
	return 30;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
heightForFooterAtIndexPath:(NSIndexPath *)indexPath {
	return  20;
}

@end
