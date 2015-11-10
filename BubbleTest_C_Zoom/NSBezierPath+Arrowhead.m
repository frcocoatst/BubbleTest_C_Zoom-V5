//
//  NSBezierPath+Arrowhead.m
//  Stockfish
//
//  Created by Daylen Yang on 1/26/14.
//  Copyright (c) 2014 Daylen Yang. All rights reserved.
//

#import "NSBezierPath+Arrowhead.h"

#define kArrowPointCount 7

@implementation NSBezierPath (NSBezierPath_Arrow)

+ (NSBezierPath *)curveFromPoint:(NSPoint)startPoint
                         toPoint:(NSPoint)endPoint
                   controlPoint1:(NSPoint)controlPoint1
                   controlPoint2:(NSPoint)controlPoint2
                       tailWidth:(CGFloat)tailWidth
                       headWidth:(CGFloat)headWidth
                      headLength:(CGFloat)headLength
{
   // Helpful resources
   // http://stackoverflow.com/questions/14068862/drawing-an-arrow-with-nsbezierpath-between-two-points
   // https://gist.github.com/mayoff/4146780
   
   NSBezierPath* path = [NSBezierPath bezierPath];
   
   // Arrow length
   CGFloat length = hypotf(endPoint.x - controlPoint2.x, endPoint.y - controlPoint2.y);
   
   // The transformation
   CGFloat cosine = (endPoint.x - controlPoint2.x) / length;
   CGFloat sine = (endPoint.y - controlPoint2.y) / length;
   NSAffineTransformStruct transformStruct = { cosine, sine, -sine, cosine, endPoint.x, endPoint.y };
   NSAffineTransform *tr = [NSAffineTransform transform];
   [tr setTransformStruct:transformStruct];
   
   // The points
   NSPoint points[kArrowPointCount];
   [self dqd_getAxisAlignedArrowPoints:points
                             forLength:0 //length
                             tailWidth:tailWidth
                             headWidth:headWidth
                            headLength:headLength];
   
   [path moveToPoint:points[0]];
   for (int i = 0; i < kArrowPointCount; i++)
   {
      [path lineToPoint:points[i]];
   }
   
   [path closePath];
   [path transformUsingAffineTransform:tr];
   
   // make the curve
   [path moveToPoint:startPoint];
   [path curveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
   
   return path;
   
}

+ (void)dqd_getAxisAlignedArrowPoints:(NSPoint[kArrowPointCount])points
                            forLength:(CGFloat)length
                            tailWidth:(CGFloat)tailWidth
                            headWidth:(CGFloat)headWidth
                           headLength:(CGFloat)headLength
{
   CGFloat tailLength = length - headLength;
   points[0] = NSMakePoint(0, tailWidth / 2);
   points[1] = NSMakePoint(tailLength, tailWidth / 2);
   points[2] = NSMakePoint(tailLength, headWidth / 2);
   points[3] = NSMakePoint(length, 0);
   points[4] = NSMakePoint(tailLength, -headWidth / 2);
   points[5] = NSMakePoint(tailLength, -tailWidth / 2);
   points[6] = NSMakePoint(0, -tailWidth / 2);
}

@end
