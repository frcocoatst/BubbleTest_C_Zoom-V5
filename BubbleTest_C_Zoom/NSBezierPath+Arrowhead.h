//
//  NSBezierPath+Arrowhead.h
//  Stockfish
//
//  Created by Daylen Yang on 1/26/14.
//  Copyright (c) 2014 Daylen Yang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kArrowPointCount 7

@interface NSBezierPath (NSBezierPath_Arrow)

+ (NSBezierPath *)curveFromPoint:(NSPoint)startPoint
                         toPoint:(NSPoint)endPoint
                   controlPoint1:(NSPoint)controlPoint1
                   controlPoint2:(NSPoint)controlPoint2
                       tailWidth:(CGFloat)tailWidth
                       headWidth:(CGFloat)headWidth
                      headLength:(CGFloat)headLength;

+ (void)dqd_getAxisAlignedArrowPoints:(NSPoint[kArrowPointCount])points
                            forLength:(CGFloat)length
                            tailWidth:(CGFloat)tailWidth
                            headWidth:(CGFloat)headWidth
                           headLength:(CGFloat)headLength ;

@end
