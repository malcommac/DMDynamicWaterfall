//
//  DMDynamicWaterfall.m
//  DMDynamicWaterfallDemo
//
//	Created by Daniele Margutti on 23.12.2013.
//	Web: http://www.danielemargutti.com
//	Mail: me@danielemargutti.com
//	Copyright 2013 Daniele Margutti.
//
//	This software is provided 'as-is', without any express or implied
//	warranty. In no event will the authors be held liable for any damages
//	arising from the use of this software.
//
//	Permission is granted to anyone to use this software for any purpose,
//	including commercial applications, and to alter it and redistribute it
//	freely, subject to the following restrictions:
//
//	   1. The origin of this software must not be misrepresented; you must not
//	   claim that you wrote the original software. If you use this software
//	   in a product, an acknowledgment in the product documentation would be
//	   appreciated but is not required.
//
//	   2. Altered source versions must be plainly marked as such, and must not be
//	   misrepresented as being the original software.
//
//	   3. This notice may not be removed or altered from any source
//	   distribution.
//

#import "DMDynamicWaterfall.h"

@interface DMDynamicWaterfall() {
	NSMutableArray			*sectionRects;
	NSMutableArray			*columnRectsInSection;
	
	NSMutableArray			*layoutItemAttributes;
	NSDictionary            *headerFooterItemAttributes;
	UIDynamicAnimator		*dynamicAnimator;
	NSMutableSet			*visibleIndexPathsSet;
	CGFloat					latestDelta;
}

@end

@implementation DMDynamicWaterfall

- (id)init {
    self = [super init];
    if (self) {
		self.dynamic = YES;
    }
    return self;
}

- (void)setDynamic:(BOOL)dynamic {
    if (![UIDynamicAnimator class]) {
        _dynamic = NO;
        return;
    }
    
	if (_dynamic != dynamic) {
		_dynamic = dynamic;

		if (!_dynamic) {
			[dynamicAnimator removeAllBehaviors];
			dynamicAnimator = nil;
			visibleIndexPathsSet = nil;
		} else {
			dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
			visibleIndexPathsSet = [NSMutableSet set];
		}
	}
}

#pragma mark - Layout Overrides -

- (CGSize)collectionViewContentSize {
	CGRect lastSectionRect = [[sectionRects lastObject] CGRectValue];
	CGSize size = CGSizeMake(CGRectGetWidth(self.collectionView.frame),CGRectGetMaxY(lastSectionRect));
	return size;
}

- (void)prepareLayout {
	NSUInteger numberOfSections = self.collectionView.numberOfSections;
	sectionRects = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
	columnRectsInSection = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
	layoutItemAttributes = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
	headerFooterItemAttributes = @{UICollectionElementKindSectionHeader : [NSMutableArray array], UICollectionElementKindSectionFooter : [NSMutableArray array]};
	
	for (NSUInteger sectIdx = 0; sectIdx < numberOfSections; ++sectIdx) {
		NSUInteger itemsInSection = [self.collectionView numberOfItemsInSection:sectIdx];
		[layoutItemAttributes addObject:[NSMutableArray array]];
		[self prepareSectionLayout:sectIdx withNumberOfItems:itemsInSection];
	}
	
	if (_dynamic) {
		[self prepareDynamicLayout];
    }
}

- (CGRect)prepareSectionLayout:(NSUInteger) sectionIdx withNumberOfItems:(NSUInteger) numberOfItems {
	UICollectionView *cView = self.collectionView;
    
    UIEdgeInsets sectionInsets = UIEdgeInsetsZero;

    if([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]){
        sectionInsets = [self.delegate collectionView:cView layout:self insetForSectionAtIndex:sectionIdx];
    }
//    UIEdgeInsets interItemInsets = UIEdgeInsetsZero;
    CGFloat lineSpacing = 0.0f;
    CGFloat interitemSpacing = 0.0f;
//    if([self.delegate respondsToSelector:@selector(collectionView:layout:insetForItemsInSection:)]){
//        interItemInsets = [self.delegate collectionView:cView layout:self insetForItemsInSection:sectionIdx];
//    }
    if([self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]){
        interitemSpacing = [self.delegate collectionView:cView layout:self minimumInteritemSpacingForSectionAtIndex:sectionIdx];
    }
    
    if([self.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]){
        lineSpacing = [self.delegate collectionView:cView layout:self minimumLineSpacingForSectionAtIndex:sectionIdx];
    }
	
	NSIndexPath *sectionPath = [NSIndexPath indexPathWithIndex:sectionIdx];
	
	// #1: Define the rect of the section
	CGRect previousSectionRect = [self rectForSectionAtIndex:sectionIdx-1];
	CGRect sectionRect;
	sectionRect.origin.x = sectionInsets.left;
	sectionRect.origin.y = CGRectGetMaxY(previousSectionRect)+sectionInsets.top;
	
	NSUInteger numberOfColumns = [self.delegate collectionView:cView layout:self numberOfColumnsInSection:sectionIdx];
	sectionRect.size.width =	CGRectGetWidth(cView.frame) - (sectionInsets.left + sectionInsets.right);
	
	CGFloat columnSpace = sectionRect.size.width - (interitemSpacing * (numberOfColumns-1));
	CGFloat columnWidth = (columnSpace/numberOfColumns);
	
	// store space for each column
	[columnRectsInSection addObject:[NSMutableArray arrayWithCapacity:numberOfColumns]];
	for (NSUInteger colIdx = 0; colIdx < numberOfColumns; ++colIdx)
		[columnRectsInSection[sectionIdx] addObject:[NSMutableArray array]];
	
	// #2: Define the rect of the header
	CGRect headerFrame;
	headerFrame.origin = sectionRect.origin;
	headerFrame.size.width = sectionRect.size.width;
    headerFrame.size.height = 0.0f;
    
    if([self.delegate respondsToSelector:@selector(collectionView:layout:heightForHeaderAtIndexPath:)]){
        headerFrame.size.height = [self.delegate collectionView:cView layout:self heightForHeaderAtIndexPath:sectionPath];
    }
	
	UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes
															  layoutAttributesForSupplementaryViewOfKind: UICollectionElementKindSectionHeader
																							withIndexPath: sectionPath];
	headerAttributes.frame = headerFrame;
	[headerFooterItemAttributes[UICollectionElementKindSectionHeader] addObject:headerAttributes];
	if (headerFrame.size.height > 0)
		[layoutItemAttributes[sectionIdx] addObject:headerAttributes];

//	NSLog(@" ");
//	NSLog(@"Section %d with %d columns and %d items",sectionIdx,numberOfColumns,numberOfItems);
//	NSLog(@"Header: %@",NSStringFromCGRect(headerFrame));
	// #3: Define the rect of the of each item
	for (NSUInteger itemIdx = 0; itemIdx < numberOfItems; ++itemIdx) {
		NSIndexPath *itemPath = [NSIndexPath indexPathForItem:itemIdx inSection:sectionIdx];
		CGSize itemSize = [self.delegate collectionView:cView layout:self sizeForItemAtIndexPath:itemPath];
		
		NSUInteger destColumnIdx = [self preferredColumnIndexInSection:sectionIdx];
		NSUInteger destRowInColumn = [self numberOfItemsInColumn:destColumnIdx ofSection:sectionIdx];
		CGFloat lastItemInColumnOffset = [self lastItemOffsetInColumn: destColumnIdx inSection: sectionIdx];
		
		CGRect itemRect;
//		itemRect.origin.x = sectionRect.origin.x +
//							(destColumnIdx * interItemInsets.left) +
//							(destColumnIdx * interItemInsets.right) +
//							(destColumnIdx * columnWidth);
//		itemRect.origin.y = lastItemInColumnOffset +
//							interItemInsets.top + (destRowInColumn == 0 ? interItemInsets.top : 0.0f) +
//							(destRowInColumn > 0 ? interItemInsets.bottom : 0.0f);
        itemRect.origin.x = sectionRect.origin.x + destColumnIdx * (interitemSpacing + columnWidth);
        itemRect.origin.y = lastItemInColumnOffset + (destRowInColumn > 0 ? lineSpacing: 0.0f);
		itemRect.size.width = columnWidth;
		itemRect.size.height = itemSize.height;
		
		UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:itemPath];
		itemAttributes.frame = itemRect;
		[layoutItemAttributes[sectionIdx] addObject:itemAttributes];
		[columnRectsInSection[sectionIdx][destColumnIdx] addObject:[NSValue valueWithCGRect:itemRect]];
		
	//	NSLog(@"   Item %d (col %d) : %@",itemIdx,destColumnIdx,NSStringFromCGRect(itemRect));
	}
	
	// #3 Define the rect of the footer
	CGRect footerFrame;
	footerFrame.origin.x = headerFrame.origin.x;
	footerFrame.origin.y = [self heightOfItemsInSection:sectionIdx] + lineSpacing;
	footerFrame.size.width = headerFrame.size.width;
    footerFrame.size.height = 0.0f;
    if([self.delegate respondsToSelector:@selector(collectionView:layout:heightForFooterAtIndexPath:)]){
        footerFrame.size.height = [self.delegate collectionView:cView layout:self heightForFooterAtIndexPath:sectionPath];
    }
	
	UICollectionViewLayoutAttributes *footerAttributes = [UICollectionViewLayoutAttributes
															layoutAttributesForSupplementaryViewOfKind: UICollectionElementKindSectionFooter
															withIndexPath: sectionPath];
	footerAttributes.frame = footerFrame;
	[headerFooterItemAttributes[UICollectionElementKindSectionFooter] addObject:footerAttributes];
	
	if (footerFrame.size.height)
		[layoutItemAttributes[sectionIdx] addObject:footerAttributes];
	//NSLog(@"Footer: %@",NSStringFromCGRect(footerFrame));

	sectionRect.size.height = (CGRectGetMaxY(footerFrame) - CGRectGetMinY(headerFrame))+sectionInsets.bottom;
	[sectionRects addObject:[NSValue valueWithCGRect:sectionRect]];
	
	//NSLog(@"Section %d rect: %@",sectionIdx,NSStringFromCGRect(sectionRect));
	return sectionRect;
}

- (CGFloat)heightOfItemsInSection:(NSUInteger) sectionIdx {
	CGFloat maxHeightBetweenColumns = 0.0f;
	NSArray *columnsInSection = columnRectsInSection[sectionIdx];
	for (NSUInteger columnIdx = 0; columnIdx < columnsInSection.count; ++columnIdx) {
		CGFloat heightOfColumn = [self lastItemOffsetInColumn:columnIdx inSection:sectionIdx];
		maxHeightBetweenColumns = MAX(maxHeightBetweenColumns,heightOfColumn);
	}
	return maxHeightBetweenColumns;
}

- (NSUInteger)numberOfItemsInColumn:(NSUInteger) columnIdx ofSection:(NSInteger) sectionIdx {
	return [columnRectsInSection[sectionIdx][columnIdx] count];
}

- (CGFloat)lastItemOffsetInColumn:(NSUInteger) columnIdx inSection:(NSInteger) sectionIdx {
	NSArray *itemsInColumn = columnRectsInSection[sectionIdx][columnIdx];
	if (itemsInColumn.count == 0) {
		CGRect headerFrame = [headerFooterItemAttributes[UICollectionElementKindSectionHeader][sectionIdx] frame];
		return CGRectGetMaxY(headerFrame);
	} else {
		CGRect lastItemRect = [[itemsInColumn lastObject] CGRectValue];
		return CGRectGetMaxY(lastItemRect);
	}
}

- (NSUInteger)preferredColumnIndexInSection:(NSInteger) sectionIdx {
	NSUInteger shortestColumnIdx = 0;
	CGFloat heightOfShortestColumn = CGFLOAT_MAX;
	for (NSUInteger columnIdx = 0; columnIdx < [columnRectsInSection[sectionIdx] count]; ++columnIdx) {
		CGFloat columnHeight = [self lastItemOffsetInColumn:columnIdx inSection:sectionIdx];
		if (columnHeight < heightOfShortestColumn) {
			shortestColumnIdx = columnIdx;
			heightOfShortestColumn = columnHeight;
		}
	}
	return shortestColumnIdx;
}

- (CGRect)rectForSectionAtIndex:(NSInteger) sectionIdx {
	if (sectionIdx < 0 || sectionIdx >= sectionRects.count) return CGRectZero;
	return [sectionRects[sectionIdx] CGRectValue];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	return headerFooterItemAttributes[kind][indexPath.section];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!_dynamic) {
		return [super layoutAttributesForItemAtIndexPath:indexPath];
    }
    
	return [dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)visibleRect {
	if (!_dynamic) {
		return [self searchVisibleLayoutAttributesInRect:visibleRect];
    }
    
	return [dynamicAnimator itemsInRect:visibleRect];
}

#pragma mark - Dynamic Support via UIKit Dynamics -

- (void) prepareDynamicLayout {
    // Take visible portion of the collection view and enlarge it slightly to avoid flickering for non dynamic aware items
    CGRect visibleRect = CGRectInset((CGRect){.origin = self.collectionView.bounds.origin, .size = self.collectionView.frame.size}, -100, -100);
	NSArray *itemsInVisibleRectArray = [self searchVisibleLayoutAttributesInRect:visibleRect];
	NSSet *itemsIndexPathsInVisibleRectSet = [NSSet setWithArray:[itemsInVisibleRectArray valueForKey:@"indexPath"]];
	
	// loper.apple.com/wwdc/videos/index.php?id=217 (WWDC Videos 217)
	// First of all we want to remove dynamic behaviour for each no longer visible items along with the index paths from the visibleIndexPathsSet property
	// This allows us to red
    NSArray *noLongerVisibleBehaviours = [dynamicAnimator.behaviors filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behaviour, NSDictionary *bindings) {
        BOOL currentlyVisible = [itemsIndexPathsInVisibleRectSet member:[[[behaviour items] firstObject] indexPath]] != nil;
        return !currentlyVisible;
    }]];
	
	[noLongerVisibleBehaviours enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        [dynamicAnimator removeBehavior:obj];
        [visibleIndexPathsSet removeObject:[[[obj items] firstObject] indexPath]];
    }];
	
	// The next step is to calculate a list of UICollectionViewLayoutAttributes that are newly visible
    // A newly-visible item is one that is in the itemsInVisibleRect(Set|Array) but not in the visibleIndexPathsSet
    NSArray *newlyVisibleItems = [itemsInVisibleRectArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        BOOL isVisible = ([visibleIndexPathsSet member:item.indexPath] != nil);
        return !isVisible;
    }]];
    
	CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger idx, BOOL *stop) {
        CGPoint center = item.center;
        UIAttachmentBehavior *springBehaviour = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:center];
		
        springBehaviour.length = 1.0f;
        springBehaviour.damping = 0.8f;
        springBehaviour.frequency = 1.0f;
        
        // If our touchLocation is not (0,0), we'll need to adjust our item's center "in flight"
        if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
            CGFloat distanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
            CGFloat scrollResistance = distanceFromTouch / 1500.0f;
            
            if (latestDelta < 0)
                center.y += MAX(latestDelta, latestDelta*scrollResistance);
            else
                center.y += MIN(latestDelta, latestDelta*scrollResistance);
            item.center = center;
        }
        [dynamicAnimator addBehavior:springBehaviour];
        [visibleIndexPathsSet addObject:item.indexPath];
    }];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
	if (!_dynamic) {
		return [super shouldInvalidateLayoutForBoundsChange:newBounds];
	}
    
    UIScrollView *scrollView = self.collectionView;
    CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
    
    latestDelta = delta;
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
        CGFloat yDistanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
        CGFloat xDistanceFromTouch = 0;// fabsf(touchLocation.x - springBehaviour.anchorPoint.x);
        CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1500.0f;
        
        UICollectionViewLayoutAttributes *item = [springBehaviour.items firstObject];
        CGPoint center = item.center;
        if (delta < 0)
            center.y += MAX(delta, delta*scrollResistance);
        else
            center.y += MIN(delta, delta*scrollResistance);
        item.center = center;
        [dynamicAnimator updateItemUsingCurrentState:item];
    }];
    
    return NO;
}

#pragma mark - Helper Methods -

- (NSArray *)searchVisibleLayoutAttributesInRect:(CGRect) visibleRect {
	NSMutableArray *itemAttrs = [[NSMutableArray alloc] init];
	NSIndexSet *visibleSections = [self sectionIndexesInRect:visibleRect];
	[visibleSections enumerateIndexesUsingBlock:^(NSUInteger sectionIdx, BOOL *stop) {
		for (UICollectionViewLayoutAttributes *itemAttr in layoutItemAttributes[sectionIdx]) {
			CGRect itemRect = itemAttr.frame;
			BOOL isVisible = CGRectIntersectsRect(visibleRect, itemRect);
			if (isVisible)
				[itemAttrs addObject:itemAttr];
		}
	}];
	return itemAttrs;
}

- (NSIndexSet *)sectionIndexesInRect:(CGRect) aRect {
	CGRect theRect = aRect;
	NSMutableIndexSet *visibleIndexes = [[NSMutableIndexSet alloc] init];
	NSUInteger numberOfSections = self.collectionView.numberOfSections;
	for (NSUInteger sectionIdx = 0; sectionIdx < numberOfSections; ++sectionIdx) {
		CGRect sectionRect = [sectionRects[sectionIdx] CGRectValue];
		BOOL isVisible = CGRectIntersectsRect(theRect, sectionRect);
		if (isVisible)
			[visibleIndexes addIndex:sectionIdx];
	}
	return visibleIndexes;
}
/*
- (NSUInteger) shortestColumnInSection:(NSUInteger) aSectionIdx {
	NSUInteger shortestCIdx = 0;
	CGFloat shortestHeight = CGFLOAT_MAX;
	CGFloat columnHeight;
	for (NSUInteger columnIdx = 0; columnIdx < [columnRectsInSection[aSectionIdx] count]; ++columnIdx) {
		columnHeight = [self heightForColumn:columnIdx inSection:aSectionIdx];
		if (columnHeight < shortestHeight) {
			shortestCIdx = columnIdx;
			shortestHeight = columnHeight;
		}
	}
	return shortestCIdx;
}

- (CGFloat) lastItemOffsetInColumn:(NSUInteger) aColumnIdx ofSection:(NSUInteger) sectionIdx {
	NSArray *itemsInColumn = columnRectsInSection[sectionIdx][aColumnIdx];
	if (itemsInColumn.count == 0) {
		CGFloat headerHeight = [self.dataSource collectionView:self.collectionView layout:self heightForHeaderAtIndexPath:[NSIndexPath indexPathWithIndex:sectionIdx]];
		return headerHeight;
	} else {
		CGRect lastItemInColumn = [[itemsInColumn lastObject] CGRectValue];
		return CGRectGetMaxY(lastItemInColumn);
	}
}

- (CGFloat) heightOfSection:(NSUInteger) aSectionIdx {
	CGFloat maxHeight = 0.0f;
	for (NSUInteger columnIdx = 0; columnIdx < [columnRectsInSection[aSectionIdx] count]; ++columnIdx) {
		CGFloat heightOfColumn = [self heightForColumn:columnIdx inSection:aSectionIdx];
		if (heightOfColumn > maxHeight)
			maxHeight = heightOfColumn;
	}
	CGFloat footerHeight = [self.dataSource collectionView:self.collectionView layout:self heightForFooterAtIndexPath:[NSIndexPath indexPathWithIndex:aSectionIdx]];
	return maxHeight+footerHeight;
}

- (NSUInteger) heightForColumn:(NSUInteger) columnIdx inSection:(NSUInteger) sectionIdx {
	CGFloat sectionYStartOffset = [self rectForSectionAtIndex:sectionIdx].origin.y;
	CGRect lastColumnItemRect = [[columnRectsInSection[sectionIdx][columnIdx] lastObject] CGRectValue];
	CGFloat lastColumnItemFrame = CGRectGetMaxY(lastColumnItemRect);
	if (lastColumnItemFrame == 0)
		return 0;
	return (lastColumnItemFrame-sectionYStartOffset);
}

- (CGRect) rectForSectionAtIndex:(NSInteger) aSectionIdx {
	if (aSectionIdx < 0 || aSectionIdx > sectionRects.count || sectionRects.count == 0)
		return CGRectZero;
	return [sectionRects[aSectionIdx] CGRectValue];
}*/

@end
