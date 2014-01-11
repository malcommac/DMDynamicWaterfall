//
//  NSGeometry.h
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

#import <Foundation/Foundation.h>

static inline CGFloat NSMinX(CGRect rect) {
	return rect.origin.x;
}

static inline CGFloat NSMinY(CGRect rect) {
	return rect.origin.y;
}

static inline CGFloat NSWidth(CGRect rect) {
	return rect.size.width;
}

static inline CGFloat NSHeight(CGRect rect) {
	return rect.size.height;
}

static inline CGFloat NSMaxX(CGRect rect) {
	return rect.origin.x+rect.size.width;
}

static inline CGFloat NSMaxY(CGRect rect) {
	return rect.origin.y+rect.size.height;
}

static inline CGFloat NSMidX(CGRect rect) {
	return rect.origin.x+rect.size.width/2;
}

static inline CGFloat NSMidY(CGRect rect) {
	return rect.origin.y+rect.size.height/2;
}

static inline CGFloat NSHorizontalInset(UIEdgeInsets inset) {
	return inset.left+inset.right;
}

static inline CGFloat NSVerticalInset(UIEdgeInsets inset) {
	return inset.top+inset.bottom;
}

static inline CGRect NSRectFromSize(CGSize size) {
	return CGRectMake(0.0, 0.0, size.width, size.height);
}