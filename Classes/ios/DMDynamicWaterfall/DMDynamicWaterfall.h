//
//  DMDynamicWaterfall.h
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

#import <UIKit/UIKit.h>

@class  DMDynamicWaterfall;

@protocol DMDynamicWaterfallDelegate <UICollectionViewDelegateFlowLayout>

@required

/**
 *  Return the number of columns to show in section.
 *  @warning Item size width will be adjusted based on insets and number of columns. Height is preserved.
 *
 *  @param aCollectionView target collection view
 *  @param aLayout         reference to layout
 *  @param aSectionIdx     section index
 *
 *  @return the number of sections in collection view
 */

- (NSUInteger)collectionView:(UICollectionView *)aCollectionView layout:(DMDynamicWaterfall *)aLayout
	 numberOfColumnsInSection:(NSUInteger)aSectionIdx;

@optional

/**
 *  Return the insets to mantain for each section
 *
 *  @param collectionView       target collection view
 *  @param collectionViewLayout reference to layout
 *  @param aSectionIdx          section index
 *
 *  @return insets for target section
 */


//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForItemsInSection:(NSUInteger)aSectionIdx;

/**
 *  Height of the header for a section (0 to disable it)
 *
 *  @param collectionView       target collection view
 *  @param collectionViewLayout reference to layout
 *  @param indexPath            section index path
 *
 *  @return the height of the header
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderAtIndexPath:(NSIndexPath *)indexPath;


/**
 *  Height of the footer for a section (0 to disable it)
 *
 *  @param collectionView       target collection view
 *  @param collectionViewLayout reference to layout
 *  @param indexPath            section index path
 *
 *  @return the height of the footer
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface DMDynamicWaterfall : UICollectionViewFlowLayout

/**
 *  Datasource for dynamic waterfall layout
 */
@property (nonatomic, weak) id <DMDynamicWaterfallDelegate>	delegate;

/**
 *  Yes to enable UIKitDynamics behavior for this layout
 */
@property (nonatomic, assign, getter = isDynamic) BOOL dynamic;

@end
