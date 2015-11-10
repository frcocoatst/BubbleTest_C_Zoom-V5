//
//  BubbleTestView.m
//  BubbleTest_C
//
//  Created by Friedrich Haeupl on 21.07.14.
//  Copyright (c) 2014 fritz. All rights reserved.
//

#import "BubbleTestView.h"
#import "NSBezierPath+Arrowhead.h"

#define TRACK_RADIUS    100
#define GRID_RADIUS     100
#define RADIUS          60
#define STOREHEIGHT     40
#define STOREWIDTH      60
#define CONNRADIUS      5
#define SELECTRADIUS    20
#define TEXTOFFSET      45
#define STRING_ATTR [NSDictionary dictionaryWithObjectsAndKeys: [NSColor blackColor], NSForegroundColorAttributeName, nil]

static const NSSize unitSize = {1.0, 1.0};


@implementation BubbleTestView

- (id)initWithFrame:(NSRect)frame
{
   self = [super initWithFrame:frame];
   if (self)
   {
      // Initialization code here.
      
      memset(arrayOfElements,            0, sizeof(arrayOfElements));
      memset(arrayOfConnectionElements,  0, sizeof(arrayOfConnectionElements));
      arrayOfElementsCount               = 0;
      arrayOfConnectionElementsCount     = 0;
      selected_element_index             = -1;
      selected_connector_index           = -1;
      showConnectionPoints               = NO;
      startpoint_selected                = NO;
      controlpoint1_selected             = NO;
      controlpoint2_selected             = NO;
      numberCounter                      = 0;
      linewidth                          = 1.0;
      
      selectedTool                       = 0;
      
      NSLog(@"frame = %f %f %f %f",frame.origin.x,frame.origin.y,frame.size.height,frame.size.width);
   }
   return self;
}

-(void)awakeFromNib
{
   memset(arrayOfElements,            0, sizeof(arrayOfElements));
   memset(arrayOfConnectionElements,  0, sizeof(arrayOfConnectionElements));
   arrayOfElementsCount               = 0;
   arrayOfConnectionElementsCount     = 0;
   selected_element_index             = -1;
   selected_connector_index           = -1;
   showConnectionPoints               = NO;
   startpoint_selected                = NO;
   controlpoint1_selected             = NO;
   controlpoint2_selected             = NO;
   numberCounter                      = 0;
   linewidth                          = 1.0;
   
   selectedTool                       = 0;
}

// test if point is within an element
- (BOOL)testSelectElementInRect:(NSPoint)point
{
   int i;
   NSRect aRect;
   
   // test if an element is selected
   for (i=0; i<arrayOfElementsCount; i++)
   {
      aRect.origin.x    = arrayOfElements[i].location.x - RADIUS;
      aRect.origin.y    = arrayOfElements[i].location.y - RADIUS;
      aRect.size.width  = 2*RADIUS;
      aRect.size.height = 2*RADIUS;
      if (NSPointInRect(point, aRect) == YES)
      {
         selected_element_index = i;
         NSLog(@"selected_element_index =%d",selected_element_index);
         return YES;
      }
   }
   
   selected_element_index = -1;
   return NO;
}

// test if point is within a controlpoint
- (BOOL)testControlPointSelected:(NSPoint)point
{
   //
   NSRect aRect;
   
   // security check
   if (selected_connector_index == -1)
   {
      return NO;
   }
   
   // get the controlpoints
   controlPoint_1 = arrayOfConnectionElements[selected_connector_index].controlPoint[0];
   controlPoint_2 = arrayOfConnectionElements[selected_connector_index].controlPoint[1];
   
   // test if controlpoint1 is selected
   aRect.origin.x = controlPoint_1.x - SELECTRADIUS;
   aRect.origin.y = controlPoint_1.y - SELECTRADIUS;
   aRect.size.width  = 2*SELECTRADIUS;
   aRect.size.height = 2*SELECTRADIUS;
   if (NSPointInRect(point, aRect) == YES)
   {
      controlpoint1_selected = YES;
      NSLog(@"controlpoint1_selected");
      return YES;
   }
   
   // test if controlpoint2 is selected
   aRect.origin.x = controlPoint_2.x - SELECTRADIUS;
   aRect.origin.y = controlPoint_2.y - SELECTRADIUS;
   aRect.size.width  = 2*SELECTRADIUS;
   aRect.size.height = 2*SELECTRADIUS;
   if (NSPointInRect(point, aRect) == YES)
   {
      controlpoint2_selected = YES;
      NSLog(@"controlpoint1_selected");
      return YES;
   }
   return NO;
}

// test if point is within a connector
- (BOOL)testSelectConnectorInRect:(NSPoint)point
{
   int i;
   // int j;
   NSRect aRect;
   int startPoint_number;
   int startPoint_connectionPoint;
   int endPoint_number;
   int endPoint_connectionPoint;
   
   NSLog(@"testSelectConnectorInRect");
   
   // test if any connector is selected
   for (i=0; i<arrayOfConnectionElementsCount; i++)
   {
      startPoint_number = arrayOfConnectionElements[i].startPoint_number;
      startPoint_connectionPoint = arrayOfConnectionElements[i].startPoint_connectionPoint;
      endPoint_number = arrayOfConnectionElements[i].endPoint_number;
      endPoint_connectionPoint = arrayOfConnectionElements[i].endPoint_connectionPoint;
      
      aRect.origin.x    = arrayOfElements[startPoint_number].connectionPoints[startPoint_connectionPoint].x +
      (arrayOfElements[endPoint_number].connectionPoints[endPoint_connectionPoint].x -
       arrayOfElements[startPoint_number].connectionPoints[startPoint_connectionPoint].x)/2;
      
      aRect.origin.y    = arrayOfElements[startPoint_number].connectionPoints[startPoint_connectionPoint].y +
      (arrayOfElements[endPoint_number].connectionPoints[endPoint_connectionPoint].y -
       arrayOfElements[startPoint_number].connectionPoints[startPoint_connectionPoint].y)/2;
      
      aRect.origin.x    = aRect.origin.x - CONNRADIUS;
      aRect.origin.y    = aRect.origin.y - CONNRADIUS;
      aRect.size.width  = 2*CONNRADIUS;
      aRect.size.height = 2*CONNRADIUS;
      
      if (NSPointInRect(point, aRect) == YES)
      {
         selected_connector_index = i;
         NSLog(@"selected_connector_index =%d",selected_connector_index);
         //            NSLog(@"Element=%03d:%f,%f,%f,%f %f,%f",i,aRect.origin.x,aRect.origin.y,aRect.size.width,aRect.size.height,point.x,point.y);
         return YES;
      }
   }
   
   selected_connector_index = -1;
   return NO;
}


// test if point is within a connector
- (BOOL)testPointInConnector:(NSPoint)point
{
   int i;
   int j;
   NSRect aRect;
   
   // test if a connection point of an element is selected
   for (i=0; i<arrayOfElementsCount; i++)
   {
      for(j=0; j<arrayOfElements[i].number_connectionPoint; j++)
      {
         aRect.origin.x = arrayOfElements[i].connectionPoints[j].x - CONNRADIUS;
         aRect.origin.y = arrayOfElements[i].connectionPoints[j].y - CONNRADIUS;
         aRect.size.width  = 2*CONNRADIUS;
         aRect.size.height = 2*CONNRADIUS;
         if (NSPointInRect(point, aRect) == YES)
         {
            if (startpoint_selected == NO)
            {
               startpoint_index = j;
               startpoint_element = i;
               startpoint_selected = YES;
               NSLog(@"startpoint_selected");
            }
            else
            {
               endpoint_index = j;
               endpoint_element = i;
               startpoint_selected = NO;
               NSLog(@"endpoint_selected");
            }
            return YES;
         }
      }
   }
   // reset start and end of connector
   startpoint_index = -1;
   startpoint_element =  -1;
   endpoint_index = -1;
   endpoint_element =  -1;
   return NO;
}

// adds a bubble to the list of bubbles
-(void)addABubble:(NSPoint)atPoint
{
   // set position of an element
   arrayOfElements[arrayOfElementsCount].number = numberCounter;
   numberCounter ++;
   arrayOfElements[arrayOfElementsCount].location = atPoint;
   arrayOfElements[arrayOfElementsCount].type = BUBBLE;
   arrayOfElements[arrayOfElementsCount].number_connectionPoint = 12;
   
   // set the absolute position of all connection points
   int i;
   for(i=0; i<arrayOfElements[arrayOfElementsCount].number_connectionPoint; i++)
   {
      arrayOfElements[arrayOfElementsCount].connectionPoints[i].x = atPoint.x + (RADIUS * sin(i * M_PI * 30/180));
      arrayOfElements[arrayOfElementsCount].connectionPoints[i].y = atPoint.y + (RADIUS * cos(i * M_PI * 30/180));
   }
   
   NSLog(@"addABubble: arrayOfElementsCount =%d",arrayOfElementsCount);
   
   // new element added so increase element counter
   arrayOfElementsCount++;
}

// adds a square to the list of elements
-(void)addASquare:(NSPoint)atPoint
{
   // set position of an element
   arrayOfElements[arrayOfElementsCount].number = numberCounter;
   numberCounter ++;
   arrayOfElements[arrayOfElementsCount].location = atPoint;
   arrayOfElements[arrayOfElementsCount].type = TERMINATOR;
   arrayOfElements[arrayOfElementsCount].number_connectionPoint = 12;
   
   // set the absolute position of all connection points
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[0].x = atPoint.x ;
   arrayOfElements[arrayOfElementsCount].connectionPoints[0].y = atPoint.y + RADIUS;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[1].x = atPoint.x + RADIUS/2;
   arrayOfElements[arrayOfElementsCount].connectionPoints[1].y = atPoint.y + RADIUS;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[2].x = atPoint.x - RADIUS/2;
   arrayOfElements[arrayOfElementsCount].connectionPoints[2].y = atPoint.y + RADIUS;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[3].x = atPoint.x + RADIUS;
   arrayOfElements[arrayOfElementsCount].connectionPoints[3].y = atPoint.y + RADIUS/2;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[4].x = atPoint.x + RADIUS;
   arrayOfElements[arrayOfElementsCount].connectionPoints[4].y = atPoint.y;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[5].x = atPoint.x + RADIUS;
   arrayOfElements[arrayOfElementsCount].connectionPoints[5].y = atPoint.y - RADIUS/2;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[6].x = atPoint.x - RADIUS/2;
   arrayOfElements[arrayOfElementsCount].connectionPoints[6].y = atPoint.y - RADIUS;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[7].x = atPoint.x;
   arrayOfElements[arrayOfElementsCount].connectionPoints[7].y = atPoint.y - RADIUS;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[8].x = atPoint.x + RADIUS/2;
   arrayOfElements[arrayOfElementsCount].connectionPoints[8].y = atPoint.y - RADIUS;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[9].x = atPoint.x - RADIUS;
   arrayOfElements[arrayOfElementsCount].connectionPoints[9].y = atPoint.y + RADIUS/2;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[10].x = atPoint.x - RADIUS;
   arrayOfElements[arrayOfElementsCount].connectionPoints[10].y = atPoint.y;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[11].x = atPoint.x - RADIUS;
   arrayOfElements[arrayOfElementsCount].connectionPoints[11].y = atPoint.y - RADIUS/2;
   
   NSLog(@"addASquare: arrayOfElementsCount =%d",arrayOfElementsCount);
   
   // new element added so increase element counter
   arrayOfElementsCount++;
}

// adds a store to the list of elements
-(void)addAStore:(NSPoint)atPoint
{
   // set position of an element
   arrayOfElements[arrayOfElementsCount].number = numberCounter;
   numberCounter ++;
   arrayOfElements[arrayOfElementsCount].location = atPoint;
   arrayOfElements[arrayOfElementsCount].type = STORE;
   arrayOfElements[arrayOfElementsCount].number_connectionPoint = 10;
   
   // set the absolute position of all connection points
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[0].x = atPoint.x ;
   arrayOfElements[arrayOfElementsCount].connectionPoints[0].y = atPoint.y + STOREHEIGHT;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[1].x = atPoint.x + STOREWIDTH/2;
   arrayOfElements[arrayOfElementsCount].connectionPoints[1].y = atPoint.y + STOREHEIGHT;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[2].x = atPoint.x - STOREWIDTH/2;
   arrayOfElements[arrayOfElementsCount].connectionPoints[2].y = atPoint.y + STOREHEIGHT;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[3].x = atPoint.x - STOREWIDTH;
   arrayOfElements[arrayOfElementsCount].connectionPoints[3].y = atPoint.y + STOREHEIGHT;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[4].x = atPoint.x + STOREWIDTH;
   arrayOfElements[arrayOfElementsCount].connectionPoints[4].y = atPoint.y + STOREHEIGHT;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[5].x = atPoint.x - STOREWIDTH/2;
   arrayOfElements[arrayOfElementsCount].connectionPoints[5].y = atPoint.y - STOREHEIGHT;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[6].x = atPoint.x;
   arrayOfElements[arrayOfElementsCount].connectionPoints[6].y = atPoint.y - STOREHEIGHT;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[7].x = atPoint.x + STOREWIDTH/2;
   arrayOfElements[arrayOfElementsCount].connectionPoints[7].y = atPoint.y - STOREHEIGHT;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[8].x = atPoint.x - STOREWIDTH;
   arrayOfElements[arrayOfElementsCount].connectionPoints[8].y = atPoint.y - STOREHEIGHT;
   
   arrayOfElements[arrayOfElementsCount].connectionPoints[9].x = atPoint.x + STOREWIDTH;
   arrayOfElements[arrayOfElementsCount].connectionPoints[9].y = atPoint.y - STOREHEIGHT;
   
   NSLog(@"addAStore: arrayOfElementsCount =%d",arrayOfElementsCount);
   
   // new element added so increase element counter
   arrayOfElementsCount++;
}


-(void)addAConnector
{
   
   //NSLog(@"addAConnector: startpoint_index=%d startpoint_element=%d endpoint_index=%d endpoint_element=%d",
   //      startpoint_index, startpoint_element, endpoint_index, endpoint_element );
   
   NSLog(@"addAConnector: arrayOfConnectionElementsCount=%d", arrayOfConnectionElementsCount );
   //
   arrayOfConnectionElements[arrayOfConnectionElementsCount].startPoint_connectionPoint = startpoint_index;
   arrayOfConnectionElements[arrayOfConnectionElementsCount].startPoint_number = startpoint_element;
   arrayOfConnectionElements[arrayOfConnectionElementsCount].endPoint_connectionPoint = endpoint_index;
   arrayOfConnectionElements[arrayOfConnectionElementsCount].endPoint_number = endpoint_element;
   
   // add a number
   arrayOfConnectionElements[arrayOfConnectionElementsCount].number = arrayOfConnectionElementsCount;
   
   // add control points
   NSPoint start = arrayOfElements[startpoint_element].connectionPoints[startpoint_index];
   NSPoint end   = arrayOfElements[endpoint_element].connectionPoints[endpoint_index];
   CGFloat length = hypotf(end.x - start.x, end.y - start.y);
   
   if (length >10.0)
   {
      arrayOfConnectionElements[arrayOfConnectionElementsCount].controlPoint[0].x = start.x + (end.x-start.x)/4;
      arrayOfConnectionElements[arrayOfConnectionElementsCount].controlPoint[0].y = start.y + (end.y-start.y)/4;
      arrayOfConnectionElements[arrayOfConnectionElementsCount].controlPoint[1].x = start.x + (end.x-start.x)*3/4;
      arrayOfConnectionElements[arrayOfConnectionElementsCount].controlPoint[1].y = start.y + (end.y-start.y)*3/4;
   }
   else
   {
      arrayOfConnectionElements[arrayOfConnectionElementsCount].controlPoint[0] = start;
      arrayOfConnectionElements[arrayOfConnectionElementsCount].controlPoint[1] = end;
   }
   
   // increase counter
   arrayOfConnectionElementsCount++;
}

// draw a bubble
-(void)drawABubble:(int)index
{
   NSRect dotRect;
   NSBezierPath *path;
   NSBezierPath *apath;
   NSPoint center;
   int j;
   float radius=RADIUS;
   
   center = arrayOfElements[index].location;
   // ------ draw the circle
   dotRect.origin.x    = center.x - RADIUS;
   dotRect.origin.y    = center.y - RADIUS;
   dotRect.size.width  = 2*RADIUS;
   dotRect.size.height = 2*RADIUS;
   
   if ((selected_element_index != -1) && (selected_element_index == index))
   {
      [[NSColor redColor] set];
      path = [NSBezierPath bezierPathWithOvalInRect:dotRect];
      [path setLineWidth:5.0];
   }
   else
   {
      [[NSColor blackColor] set];
      path = [NSBezierPath bezierPathWithOvalInRect:dotRect];
      [path setLineWidth:linewidth];
   }
   [path stroke];
   
   // ------ draw string into bubble
   sprintf(arrayOfElements[index].name,"0.%d",index);
   NSString *str = [[NSString alloc]initWithBytes:arrayOfElements[index].name length:sizeof(arrayOfElements[index].name) encoding:NSUTF8StringEncoding];
   
   NSAttributedString* referenceToDraw = [[NSAttributedString alloc] initWithString:str attributes:STRING_ATTR];
   
   // figure out how big the string is going to be so we can center it
   NSSize referenceSize = [referenceToDraw size];
   
   // figure out where to draw the reference in the upper quater of the circle.
   NSPoint referencePoint = NSMakePoint(dotRect.origin.x + (dotRect.size.width - referenceSize.width)/2,
                                        (dotRect.origin.y + (dotRect.size.height - referenceSize.height - radius/4)));
   
   // draw the string
   [referenceToDraw drawAtPoint:referencePoint];
   
   // draw string into bubble
   // create the string
   NSString *strdesc = [[NSString alloc]initWithBytes:arrayOfElements[index].description length:sizeof(arrayOfElements[index].description) encoding:NSUTF8StringEncoding];
   
   NSAttributedString* stringToDraw = [[NSAttributedString alloc] initWithString:strdesc attributes:STRING_ATTR];
   
   // figure out how big the string is going to be so we can center it
   NSSize stringSize = [stringToDraw size];
   
   // figure out where to draw the string.  Centered in the circle.
   NSPoint destPoint = NSMakePoint(dotRect.origin.x + (dotRect.size.width - stringSize.width)/2,
                                   (dotRect.origin.y + (dotRect.size.height - stringSize.height)/2));
   
   // draw the string
   [stringToDraw drawAtPoint:destPoint];
   
   
   // ------ connection points
   NSPoint conn;
   for(j=0; j<arrayOfElements[index].number_connectionPoint; j++)
   {
      conn.x = arrayOfElements[index].connectionPoints[j].x;
      conn.y = arrayOfElements[index].connectionPoints[j].y;
      // -------------- Circle --------------
      dotRect.origin.x = conn.x - CONNRADIUS;
      dotRect.origin.y = conn.y - CONNRADIUS;
      dotRect.size.width  = 2 * CONNRADIUS;
      dotRect.size.height = 2 * CONNRADIUS;
      
      if (showConnectionPoints==YES)
      {
         [[NSColor blueColor] set];
         apath = [NSBezierPath bezierPathWithOvalInRect:dotRect];
         [apath setLineWidth:1];
         [apath stroke];
      }
   }
}

// draw a square
-(void)drawASquare:(int)index
{
   NSRect dotRect;
   NSBezierPath *path;
   NSBezierPath *apath;
   NSPoint center;
   int j;
   float radius=RADIUS;
   
   center = arrayOfElements[index].location;
   // ------ draw the circle
   dotRect.origin.x    = center.x - RADIUS;
   dotRect.origin.y    = center.y - RADIUS;
   dotRect.size.width  = 2*RADIUS;
   dotRect.size.height = 2*RADIUS;
   
   if ((selected_element_index != -1) && (selected_element_index == index))
   {
      [[NSColor redColor] set];
      path = [NSBezierPath bezierPathWithRect:dotRect];
      [path setLineWidth:5];
   }
   else
   {
      [[NSColor blackColor] set];
      path = [NSBezierPath bezierPathWithRect:dotRect];
      [path setLineWidth:linewidth];
   }
   [path stroke];
   
   // ------ draw string into bubble
   sprintf(arrayOfElements[index].name,"0.%d",index);
   NSString *str = [[NSString alloc]initWithBytes:arrayOfElements[index].name length:sizeof(arrayOfElements[index].name) encoding:NSUTF8StringEncoding];
   
   NSAttributedString* referenceToDraw = [[NSAttributedString alloc] initWithString:str attributes:STRING_ATTR];
   
   // figure out how big the string is going to be so we can center it
   NSSize referenceSize = [referenceToDraw size];
   
   // figure out where to draw the reference in the upper quater of the circle.
   NSPoint referencePoint = NSMakePoint(dotRect.origin.x + (dotRect.size.width - referenceSize.width)/2,
                                        (dotRect.origin.y + (dotRect.size.height - referenceSize.height - radius/4)));
   
   // draw the string
   [referenceToDraw drawAtPoint:referencePoint];
   
   // draw string into bubble
   // create the string
   NSString *strdesc = [[NSString alloc]initWithBytes:arrayOfElements[index].description length:sizeof(arrayOfElements[index].description) encoding:NSUTF8StringEncoding];
   
   NSAttributedString* stringToDraw = [[NSAttributedString alloc] initWithString:strdesc attributes:STRING_ATTR];
   
   // figure out how big the string is going to be so we can center it
   NSSize stringSize = [stringToDraw size];
   
   // figure out where to draw the string.  Centered in the circle.
   NSPoint destPoint = NSMakePoint(dotRect.origin.x + (dotRect.size.width - stringSize.width)/2,
                                   (dotRect.origin.y + (dotRect.size.height - stringSize.height)/2));
   
   // draw the string
   [stringToDraw drawAtPoint:destPoint];
   
   
   // ------ connection points
   NSPoint conn;
   for(j=0; j<arrayOfElements[index].number_connectionPoint; j++)
   {
      conn.x = arrayOfElements[index].connectionPoints[j].x;
      conn.y = arrayOfElements[index].connectionPoints[j].y;
      // -------------- Circle --------------
      dotRect.origin.x = conn.x - CONNRADIUS;
      dotRect.origin.y = conn.y - CONNRADIUS;
      dotRect.size.width  = 2 * CONNRADIUS;
      dotRect.size.height = 2 * CONNRADIUS;
      
      if (showConnectionPoints==YES)
      {
         [[NSColor blueColor] set];
         apath = [NSBezierPath bezierPathWithOvalInRect:dotRect];
         [apath setLineWidth:1];
         [apath stroke];
      }
   }
}

// draw a store
-(void)drawAStore:(int)index
{
   NSRect dotRect;
   //NSBezierPath *path;
   NSBezierPath *apath;
   NSPoint center;
   int j;
   CGFloat radius=RADIUS;
   NSPoint p1;
   NSPoint p2;
   NSPoint p3;
   NSPoint p4;
   
   
   center = arrayOfElements[index].location;
   //
   dotRect.origin.x    = center.x - STOREWIDTH;
   dotRect.origin.y    = center.y - STOREHEIGHT;
   dotRect.size.width  = 2*STOREWIDTH;
   dotRect.size.height = 2*STOREHEIGHT;
   
   p1 = NSMakePoint(dotRect.origin.x                      , dotRect.origin.y + dotRect.size.height);
   p2 = NSMakePoint(dotRect.origin.x + dotRect.size.width , dotRect.origin.y + dotRect.size.height);
   p3 = NSMakePoint(dotRect.origin.x                      , dotRect.origin.y);
   p4 = NSMakePoint(dotRect.origin.x + dotRect.size.width , dotRect.origin.y);
   
   NSBezierPath *path = [NSBezierPath bezierPath];
   
   if ((selected_element_index != -1) && (selected_element_index == index))
   {
      [[NSColor redColor] set];
      
      [path moveToPoint:p1];
      [path lineToPoint:p2];
      [path moveToPoint:p3];
      [path lineToPoint:p4];
      
      [path setLineWidth:5];
   }
   else
   {
      [[NSColor blackColor] set];
      
      [path moveToPoint:p1];
      [path lineToPoint:p2];
      [path moveToPoint:p3];
      [path lineToPoint:p4];
      
      [path setLineWidth:linewidth];
   }
   [path stroke];
   
   // ------ draw string into bubble
   sprintf(arrayOfElements[index].name,"0.%d",index);
   NSString *str = [[NSString alloc]initWithBytes:arrayOfElements[index].name length:sizeof(arrayOfElements[index].name) encoding:NSUTF8StringEncoding];
   
   NSAttributedString* referenceToDraw = [[NSAttributedString alloc] initWithString:str attributes:STRING_ATTR];
   
   // figure out how big the string is going to be so we can center it
   NSSize referenceSize = [referenceToDraw size];
   
   // figure out where to draw the reference in the upper quater of the circle.
   NSPoint referencePoint = NSMakePoint(dotRect.origin.x + (dotRect.size.width - referenceSize.width)/2,
                                        (dotRect.origin.y + (dotRect.size.height - referenceSize.height - radius/4)));
   
   // draw the string
   [referenceToDraw drawAtPoint:referencePoint];
   
   // draw string into bubble
   // create the string
   NSString *strdesc = [[NSString alloc]initWithBytes:arrayOfElements[index].description length:sizeof(arrayOfElements[index].description) encoding:NSUTF8StringEncoding];
   
   NSAttributedString* stringToDraw = [[NSAttributedString alloc] initWithString:strdesc attributes:STRING_ATTR];
   
   // figure out how big the string is going to be so we can center it
   NSSize stringSize = [stringToDraw size];
   
   // figure out where to draw the string.  Centered in the circle.
   NSPoint destPoint = NSMakePoint(dotRect.origin.x + (dotRect.size.width - stringSize.width)/2,
                                   (dotRect.origin.y + (dotRect.size.height - stringSize.height)/2));
   
   // draw the string
   [stringToDraw drawAtPoint:destPoint];
   
   
   // ------ connection points
   NSPoint conn;
   for(j=0; j<arrayOfElements[index].number_connectionPoint; j++)
   {
      conn.x = arrayOfElements[index].connectionPoints[j].x;
      conn.y = arrayOfElements[index].connectionPoints[j].y;
      // -------------- Circle --------------
      dotRect.origin.x = conn.x - CONNRADIUS;
      dotRect.origin.y = conn.y - CONNRADIUS;
      dotRect.size.width  = 2 * CONNRADIUS;
      dotRect.size.height = 2 * CONNRADIUS;
      
      if (showConnectionPoints==YES)
      {
         [[NSColor blueColor] set];
         apath = [NSBezierPath bezierPathWithOvalInRect:dotRect];
         [apath setLineWidth:1];
         [apath stroke];
      }
   }
}


// draw a connector
-(void)drawAConnector:(int)index
{
   // int i;
   NSPoint referencePoint;
   NSPoint textPoint;
   
   if ((selected_connector_index != -1) && (selected_connector_index == index))
   {
      [[NSColor redColor] set];
      
   }
   else
   {
      [[NSColor greenColor] set];
      
   }
   int element_start   = arrayOfConnectionElements[index].startPoint_number;
   int conn_start      = arrayOfConnectionElements[index].startPoint_connectionPoint;
   int element_end     = arrayOfConnectionElements[index].endPoint_number;
   int conn_end        = arrayOfConnectionElements[index].endPoint_connectionPoint;
   
   NSPoint start = arrayOfElements[element_start].connectionPoints[conn_start];
   NSPoint end   = arrayOfElements[element_end].connectionPoints[conn_end];
   
   
   CGFloat length = hypotf(end.x - start.x, end.y - start.y);
   
   if (length > 1.0)
   {        
      // get the controlpoints
      controlPoint_1 = arrayOfConnectionElements[index].controlPoint[0];
      controlPoint_2 = arrayOfConnectionElements[index].controlPoint[1];
      
      // -------------------- show the control points
      if (selected_connector_index != -1)
      {
         NSRect dotRect;
         dotRect.origin.x = controlPoint_1.x - CONNRADIUS;
         dotRect.origin.y = controlPoint_1.y - CONNRADIUS;
         dotRect.size.width  = 2 * CONNRADIUS;
         dotRect.size.height = 2 * CONNRADIUS;
         NSBezierPath *apath = [NSBezierPath bezierPathWithOvalInRect:dotRect];
         [apath setLineWidth:1];
         [apath stroke];
         dotRect.origin.x = controlPoint_2.x - CONNRADIUS;
         dotRect.origin.y = controlPoint_2.y - CONNRADIUS;
         dotRect.size.width  = 2 * CONNRADIUS;
         dotRect.size.height = 2 * CONNRADIUS;
         apath = [NSBezierPath bezierPathWithOvalInRect:dotRect];
         [apath stroke];
         
         if (selected_connector_index == index)
         {
            apath = [NSBezierPath bezierPath];
            [apath moveToPoint:start];
            [apath lineToPoint:controlPoint_1];
            [apath stroke];
            
            apath = [NSBezierPath bezierPath];
            [apath moveToPoint:end];
            [apath lineToPoint:controlPoint_2];
            [apath stroke];
         }
      }
      // --------------------
      
      /*
       replaced simple line
       NSBezierPath *arrowpath = [NSBezierPath bezierPathWithArrowFromPoint:start
       toPoint:end
       tailWidth:1
       headWidth:15
       headLength:15];
       
       [arrowpath fill];
       by a bezier curve
       */
      // show resulting curve
      
      NSBezierPath *mycurve = [NSBezierPath curveFromPoint:start
                                                   toPoint:end
                                             controlPoint1:controlPoint_1
                                             controlPoint2:controlPoint_2
                                                 tailWidth:1
                                                 headWidth:15
                                                headLength:15];
      
      //[mycurve fill];
      
      // Draw the outline
      [[NSColor blueColor] set];
      [mycurve stroke];
      
      // ----- TEXTPOINT -----
      double hypothenuse = sqrt((end.x - start.x)*(end.x - start.x) + (end.y - start.y)*(end.y - start.y));
      
      
      textPoint.x = - (end.x - start.x)*TEXTOFFSET/hypothenuse + end.x;    //
      textPoint.y = - (end.y - start.y)*TEXTOFFSET/hypothenuse + end.y;    // textoffset
      
      //textPoint.x = (end.x - start.x)*4/5 + start.x;    // 80% old
      //textPoint.y = (end.y - start.y)*4/5 + start.y;    // 80% old
      
      
      NSString *str = [[NSString alloc]initWithBytes:arrayOfConnectionElements[index].description
                                              length:sizeof(arrayOfConnectionElements[index].description)
                                            encoding:NSUTF8StringEncoding];
      
      NSAttributedString* referenceToDraw = [[NSAttributedString alloc] initWithString:str attributes:STRING_ATTR];
      
      // figure out how big the string is going to be so we can center it
      NSSize referenceSize = [referenceToDraw size];
      
      // figure out where to draw the reference - avoiding overlay of line & text
      if ((end.x - start.x)>=0)
      {
         // left of end point
         // subtract referenceSize.width
         referencePoint.x = textPoint.x - referenceSize.width;
         if((end.y - start.y)>=0)
         {
            // above
            referencePoint.y  = textPoint.y;
         }
         else
         {
            // subtract referenceSize.height
            referencePoint.y  = textPoint.y - referenceSize.height;
         }
      }
      else
      {
         // right of end point
         referencePoint.x  = textPoint.x;
         if((end.y - start.y)>=0)
         {
            // above
            referencePoint.y  = textPoint.y;
         }
         else
         {
            // subtract referenceSize.height
            referencePoint.y  = textPoint.y - referenceSize.height;
         }
      }
      
      //NSPoint referencePoint = NSMakePoint((textPoint.x - referenceSize.width/2),
      //                                     (textPoint.y - referenceSize.height/2));
      
      // draw the string
      [referenceToDraw drawAtPoint:referencePoint];
      
      
      
   }
   else
   {
      NSLog(@"distance very small");
   }
}


// --------------- PRINTING -------------
// For printing see Lesson 48
-(void)print:(id)sender
{
   //simple:
   //  [[NSPrintOperation printOperationWithView:self] runOperation];
   //fit printing:
   NSPrintOperation* po = [NSPrintOperation printOperationWithView:self];
   NSPrintInfo *pInfo = [po printInfo];
   [NSPrintOperation setCurrentOperation:po];
   [pInfo setHorizontalPagination:NSFitPagination];
   [pInfo setVerticalPagination:NSClipPagination];
   
   //  Margins
   [pInfo setLeftMargin:10];
   [pInfo setRightMargin:10];
   [pInfo setTopMargin:10];
   [pInfo setBottomMargin:10];
   
   //   NSPortraitOrientation = 0,
   //   NSLandscapeOrientation = 1
   [pInfo setOrientation:NSPaperOrientationLandscape];
   
   NSLog(@"%@",[pInfo paperName]);
   NSSize paperSize = [pInfo paperSize];
   NSLog(@"paperSize.w=%f h=%f",paperSize.width, paperSize.height);
   
   // force don't show connection points
   showConnectionPoints=NO;
   
   [po runOperation];
   
}

// For printing see Lesson 48
- (BOOL)acceptsFirstResponder
{
   return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
   // Drawing code here.
   NSRect dotRect;
   NSBezierPath *path;
   NSBezierPath *cpath;
   //
   int startPoint_number;
   int startPoint_connectionPoint;
   int endPoint_number;
   int endPoint_connectionPoint;
   //float radius=RADIUS;
   float x_pos;
   float y_pos;
   int i;
   int j;
   
   NSGraphicsContext *context = [NSGraphicsContext currentContext];
   
   
   // colour the background white
   [[NSColor whiteColor] set];		// this is Cocoa
   NSRectFill( dirtyRect );
   
   [[NSColor blackColor] set];
   
   if ([context isDrawingToScreen])
   {
      // snap to grid points
      for (i=1; i<20; i++)
      {
         for (j=1; j<20; j++)
         {
            // TRACK_RADIUS
            x_pos = i * TRACK_RADIUS;
            y_pos = j * TRACK_RADIUS;
            path = [NSBezierPath bezierPath];
            [path moveToPoint:NSMakePoint(x_pos - 5,y_pos)];
            [path lineToPoint:NSMakePoint(x_pos + 5,y_pos)];
            [path moveToPoint:NSMakePoint(x_pos ,y_pos - 5)];
            [path lineToPoint:NSMakePoint(x_pos ,y_pos + 5)];
            [path setLineWidth:0.2];
            [path stroke];
         }
      }
   }
   
   // draw the elements
   for (i=0; i<arrayOfElementsCount; i++)
   {
      switch (arrayOfElements[i].type)
      {
         case BUBBLE:
            [self drawABubble:i];
            break;
            
         case TERMINATOR:
            [self drawASquare:i];
            break;
            
         case STORE:
            [self drawAStore:i];
            break;
      }
      
      // ------ connection points
      NSPoint conn;
      for(j=0; j<arrayOfElements[i].number_connectionPoint; j++)
      {
         conn.x = arrayOfElements[i].connectionPoints[j].x;
         conn.y = arrayOfElements[i].connectionPoints[j].y;
         // -------------- Circle --------------
         dotRect.origin.x = conn.x - CONNRADIUS;
         dotRect.origin.y = conn.y - CONNRADIUS;
         dotRect.size.width  = 2 * CONNRADIUS;
         dotRect.size.height = 2 * CONNRADIUS;
         
         if (showConnectionPoints==YES)
         {
            [[NSColor blueColor] set];
            cpath = [NSBezierPath bezierPathWithOvalInRect:dotRect];
            [cpath setLineWidth:1];
            [cpath stroke];
         }
      }
   }
   
   // ------- connection lines
   for (i=0; i<arrayOfConnectionElementsCount; i++)
   {
      //
      startPoint_number = arrayOfConnectionElements[i].startPoint_number;
      startPoint_connectionPoint = arrayOfConnectionElements[i].startPoint_connectionPoint;
      endPoint_number = arrayOfConnectionElements[i].endPoint_number;
      endPoint_connectionPoint = arrayOfConnectionElements[i].endPoint_connectionPoint;
      
      dotRect.origin.x    = arrayOfElements[startPoint_number].connectionPoints[startPoint_connectionPoint].x +
      (arrayOfElements[endPoint_number].connectionPoints[endPoint_connectionPoint].x -
       arrayOfElements[startPoint_number].connectionPoints[startPoint_connectionPoint].x)/2;
      
      dotRect.origin.y    = arrayOfElements[startPoint_number].connectionPoints[startPoint_connectionPoint].y +
      (arrayOfElements[endPoint_number].connectionPoints[endPoint_connectionPoint].y -
       arrayOfElements[startPoint_number].connectionPoints[startPoint_connectionPoint].y)/2;
      
      dotRect.origin.x    = dotRect.origin.x - CONNRADIUS;
      dotRect.origin.y    = dotRect.origin.y - CONNRADIUS;
      dotRect.size.width  = 2*CONNRADIUS;
      dotRect.size.height = 2*CONNRADIUS;
      
      if (showConnectionPoints==YES)
      {
         [[NSColor blueColor] set];
         cpath = [NSBezierPath bezierPathWithOvalInRect:dotRect];
         [cpath setLineWidth:1];
         [cpath stroke];
      }
   }
   
   // ------- connection elements
   
   for (i=0; i<arrayOfConnectionElementsCount; i++)
   {
      [self drawAConnector:i];
   }
   
   /* serialize arrayOfElementPoints
    NSData *arrayOfElementPointsData = [NSData dataWithBytes:(void *)&arrayOfElementPoints length:sizeof(arrayOfElementPoints)];
    NSLog(@"%@",arrayOfElementPointsData);
    */
}

-(void)mouseDown:(NSEvent *)pTheEvent
{
   NSLog(@"mouseDown");
   NSPoint mousePointInWindow	= [pTheEvent locationInWindow];
   NSPoint mousePointInView	= [self convertPoint:mousePointInWindow fromView:nil];
   
   NSLog(@"selectedTool=%d",selectedTool);
   
   switch(selectedTool)
   {
      case ARROW_TOOL:
         if (selected_connector_index != -1)
         {
            if ([self testControlPointSelected:mousePointInView]==YES)
            {
               NSLog(@"ControlPoint selected");
               [self setNeedsDisplay:YES];
               break;
            }
            else
            {
               NSLog(@"no ControlPoint selected");
            }
         }
         
         if ([self testSelectElementInRect:mousePointInView]==YES)    // mousePointInView instead of snapPointInView!
         {
            NSLog(@"element selected");
         }
         else
         {
            NSLog(@"no element selected");
         }
         
         if ([self testSelectConnectorInRect:mousePointInView]==YES)
         {
            NSLog(@"connector selected");
         }
         else
         {
            NSLog(@"no connector selected");
         }
         
         [self setNeedsDisplay:YES];
         
         break;
         
      case BUBBLE_TOOL:
         startpoint_selected = NO;
         // reset start and end of connector
         startpoint_index     = -1;
         startpoint_element   = -1;
         endpoint_index       = -1;
         endpoint_element     = -1;
         break;
         
      case TERMINATOR_TOOL:
         startpoint_selected = NO;
         // reset start and end of connector
         startpoint_index     = -1;
         startpoint_element   = -1;
         endpoint_index       = -1;
         endpoint_element     = -1;
         break;
         
      case STORE_TOOL:
         startpoint_selected = NO;
         // reset start and end of connector
         startpoint_index     = -1;
         startpoint_element   = -1;
         endpoint_index       = -1;
         endpoint_element     = -1;
         break;
         
      case CONNECT_TOOL:
         //showConnectionPoints=YES;
         if ([self testPointInConnector:mousePointInView]==YES)
         {
            NSLog(@"connector");
         }
         else
         {
            NSLog(@"no connector");
         }
         break;
      case DELETE_TOOL:
         break;
   }
}

-(void)mouseDragged:(NSEvent *)pTheEvent
{
   NSPoint mousePointInView;
   NSPoint snapPointInView;
   int i;
   
   // get the location of a bubble
   NSPoint mousePointInWindow	= [pTheEvent locationInWindow];
   mousePointInView	= [self convertPoint:mousePointInWindow fromView:nil];
   snapPointInView   = [self snapToGrid:mousePointInView];
   
   NSLog(@"mouseDragged:");
   
   switch(selectedTool)
   {
      case ARROW_TOOL:
         
         // handle control points of the selected connector
         if (selected_connector_index != -1)
         {
            if (controlpoint1_selected == YES)
            {
               // set intermediate control point
               arrayOfConnectionElements[selected_connector_index].controlPoint[0]  = mousePointInView;
            }
            else
               if (controlpoint2_selected == YES)
               {
                  // set intermediate control point
                  arrayOfConnectionElements[selected_connector_index].controlPoint[1]  = mousePointInView;
               }
         }
         
         // something is selected so ...
         if (selected_element_index != -1)
         {
            // set new position of an existing element
            arrayOfElements[selected_element_index].location = snapPointInView;
            
            if (arrayOfElements[selected_element_index].type == BUBBLE)
            {
               // change the absolute position of all connection points
               
               for(i=0; i<arrayOfElements[selected_element_index].number_connectionPoint; i++)
               {
                  arrayOfElements[selected_element_index].connectionPoints[i].x = snapPointInView.x + (RADIUS * sin(i * M_PI * 30/180));
                  arrayOfElements[selected_element_index].connectionPoints[i].y = snapPointInView.y + (RADIUS * cos(i * M_PI * 30/180));
               }
            }
            else
               if (arrayOfElements[selected_element_index].type == TERMINATOR)
               {
                  arrayOfElements[selected_element_index].connectionPoints[0].x = snapPointInView.x ;
                  arrayOfElements[selected_element_index].connectionPoints[0].y = snapPointInView.y + RADIUS;
                  
                  arrayOfElements[selected_element_index].connectionPoints[1].x = snapPointInView.x + RADIUS/2;
                  arrayOfElements[selected_element_index].connectionPoints[1].y = snapPointInView.y + RADIUS;
                  
                  arrayOfElements[selected_element_index].connectionPoints[2].x = snapPointInView.x - RADIUS/2;
                  arrayOfElements[selected_element_index].connectionPoints[2].y = snapPointInView.y + RADIUS;
                  
                  arrayOfElements[selected_element_index].connectionPoints[3].x = snapPointInView.x + RADIUS;
                  arrayOfElements[selected_element_index].connectionPoints[3].y = snapPointInView.y + RADIUS/2;
                  
                  arrayOfElements[selected_element_index].connectionPoints[4].x = snapPointInView.x + RADIUS;
                  arrayOfElements[selected_element_index].connectionPoints[4].y = snapPointInView.y;
                  
                  arrayOfElements[selected_element_index].connectionPoints[5].x = snapPointInView.x + RADIUS;
                  arrayOfElements[selected_element_index].connectionPoints[5].y = snapPointInView.y - RADIUS/2;
                  
                  arrayOfElements[selected_element_index].connectionPoints[6].x = snapPointInView.x - RADIUS/2;
                  arrayOfElements[selected_element_index].connectionPoints[6].y = snapPointInView.y - RADIUS;
                  
                  arrayOfElements[selected_element_index].connectionPoints[7].x = snapPointInView.x;
                  arrayOfElements[selected_element_index].connectionPoints[7].y = snapPointInView.y - RADIUS;
                  
                  arrayOfElements[selected_element_index].connectionPoints[8].x = snapPointInView.x + RADIUS/2;
                  arrayOfElements[selected_element_index].connectionPoints[8].y = snapPointInView.y - RADIUS;
                  
                  arrayOfElements[selected_element_index].connectionPoints[9].x = snapPointInView.x - RADIUS;
                  arrayOfElements[selected_element_index].connectionPoints[9].y = snapPointInView.y + RADIUS/2;
                  
                  arrayOfElements[selected_element_index].connectionPoints[10].x = snapPointInView.x - RADIUS;
                  arrayOfElements[selected_element_index].connectionPoints[10].y = snapPointInView.y;
                  
                  arrayOfElements[selected_element_index].connectionPoints[11].x = snapPointInView.x - RADIUS;
                  arrayOfElements[selected_element_index].connectionPoints[11].y = snapPointInView.y - RADIUS/2;
                  
               }
               else
                  if (arrayOfElements[selected_element_index].type == STORE)
                  {
                     arrayOfElements[selected_element_index].connectionPoints[0].x = snapPointInView.x ;
                     arrayOfElements[selected_element_index].connectionPoints[0].y = snapPointInView.y + STOREHEIGHT;
                     
                     arrayOfElements[selected_element_index].connectionPoints[1].x = snapPointInView.x + STOREWIDTH/2;
                     arrayOfElements[selected_element_index].connectionPoints[1].y = snapPointInView.y + STOREHEIGHT;
                     
                     arrayOfElements[selected_element_index].connectionPoints[2].x = snapPointInView.x - STOREWIDTH/2;
                     arrayOfElements[selected_element_index].connectionPoints[2].y = snapPointInView.y + STOREHEIGHT;
                     
                     arrayOfElements[selected_element_index].connectionPoints[3].x = snapPointInView.x - STOREWIDTH;
                     arrayOfElements[selected_element_index].connectionPoints[3].y = snapPointInView.y + STOREHEIGHT;
                     
                     arrayOfElements[selected_element_index].connectionPoints[4].x = snapPointInView.x + STOREWIDTH;
                     arrayOfElements[selected_element_index].connectionPoints[4].y = snapPointInView.y + STOREHEIGHT;
                     
                     arrayOfElements[selected_element_index].connectionPoints[5].x = snapPointInView.x - STOREWIDTH/2;
                     arrayOfElements[selected_element_index].connectionPoints[5].y = snapPointInView.y - STOREHEIGHT;
                     
                     arrayOfElements[selected_element_index].connectionPoints[6].x = snapPointInView.x;
                     arrayOfElements[selected_element_index].connectionPoints[6].y = snapPointInView.y - STOREHEIGHT;
                     
                     arrayOfElements[selected_element_index].connectionPoints[7].x = snapPointInView.x + STOREWIDTH/2;
                     arrayOfElements[selected_element_index].connectionPoints[7].y = snapPointInView.y - STOREHEIGHT;
                     
                     arrayOfElements[selected_element_index].connectionPoints[8].x = snapPointInView.x - STOREWIDTH;
                     arrayOfElements[selected_element_index].connectionPoints[8].y = snapPointInView.y - STOREHEIGHT;
                     
                     arrayOfElements[selected_element_index].connectionPoints[9].x = snapPointInView.x + STOREWIDTH;
                     arrayOfElements[selected_element_index].connectionPoints[9].y = snapPointInView.y - STOREHEIGHT;
                     
                  }
            
            NSLog(@"selected_element_index =%d",selected_element_index);
         }
         // update the trackingAreas
         //[self updateTrackingAreas];
         [self setNeedsDisplay:YES];
         break;
         
      case BUBBLE_TOOL:
         break;
         
      case TERMINATOR_TOOL:
         break;
         
      case STORE_TOOL:
         break;
         
      case CONNECT_TOOL:
         break;
         
   }
}


-(void)mouseUp:(NSEvent *)pTheEvent
{
   NSLog(@"mouseUp");
   NSPoint mousePointInWindow	= [pTheEvent locationInWindow];
   NSPoint mousePointInView	= [self convertPoint:mousePointInWindow fromView:nil];
   NSPoint snapPointInView    = [self snapToGrid:mousePointInView];
   
   switch(selectedTool)
   {
      case ARROW_TOOL:
         //
         if (selected_connector_index != -1)
         {
            if (controlpoint1_selected == YES)
            {
               arrayOfConnectionElements[selected_connector_index].controlPoint[0]  = mousePointInView;
               
               // set back
               controlpoint1_selected = NO;
            }
            else
               if (controlpoint2_selected == YES)
               {
                  arrayOfConnectionElements[selected_connector_index].controlPoint[1]  = mousePointInView;
                  // set back
                  controlpoint2_selected = NO;
               }
         }
         
         //
         showConnectionPoints=YES;
         [self setNeedsDisplay:YES];
         break;
         
      case BUBBLE_TOOL:
         
         [self addABubble:snapPointInView];
         showConnectionPoints=NO;
         [self setNeedsDisplay:YES];
         
         break;
         
      case TERMINATOR_TOOL:
         
         [self addASquare:snapPointInView];
         showConnectionPoints=NO;
         [self setNeedsDisplay:YES];
         break;
         
      case STORE_TOOL:
         
         [self addAStore:snapPointInView];
         showConnectionPoints=NO;
         [self setNeedsDisplay:YES];
         break;
         
      case CONNECT_TOOL:
         if (startpoint_selected == YES)
         {
            NSLog(@"startpoint_index=%d startpoint_element=%d",startpoint_index, startpoint_element);
         }
         else
            if ((endpoint_index > -1) && (startpoint_index > -1))    // both exist
            {
               if(endpoint_element != startpoint_element)
               {
                  NSLog(@"endpoint_index=%d  endpoint_element=%d",endpoint_index, endpoint_element);
                  
                  [self addAConnector];
                  [self setNeedsDisplay:YES];
               }
            }
         break;
   }
}

-(NSPoint)snapToGrid:(NSPoint)clickPoint
{
   NSPoint snapPoint;
   int x;
   int y;
   
   x = ((int)clickPoint.x + GRID_RADIUS/2)/GRID_RADIUS;
   y = ((int)clickPoint.y + GRID_RADIUS/2)/GRID_RADIUS;
   if (x==0)
      x=1;
   if (y==0)
      y=1;
   
   snapPoint.x = x * GRID_RADIUS;
   snapPoint.y = y * GRID_RADIUS;
   return(snapPoint);
}

-(void)setLineThickness:(int)value
{
   NSLog(@"setLineThickness = %d",value);
   linewidth = value;
   [self setNeedsDisplay:YES];
}

-(void)setBubbleOrConnectorName:(NSString *)str
{
   NSLog(@"setName = %@ %d",str, selected_element_index);
   if (selected_element_index!=-1)
   {
      memset(arrayOfElements[selected_element_index].description,0,sizeof(arrayOfElements[selected_element_index].description));
      strcpy(arrayOfElements[selected_element_index].description, [str UTF8String]);
   }
   
   if (selected_connector_index!=-1)
   {
      memset(arrayOfConnectionElements[selected_connector_index].description,0,sizeof(arrayOfConnectionElements[selected_connector_index].description));
      strcpy(arrayOfConnectionElements[selected_connector_index].description, [str UTF8String]);
   }
   
   [self setNeedsDisplay:YES];
}

// Makes the scaling of the receiver equal to the window's base coordinate system.

- (void)resetScaling;
{
   
   [self scaleUnitSquareToSize:[self convertSize:unitSize fromView:nil]];
}

-(void)setViewSize:(double)value
{
   [self resetScaling];                                     // First, match our scaling to the window's coordinate system
   [self scaleUnitSquareToSize:NSMakeSize(value, value)];   // Then, set the scale.
   
   // Important, changing the scale doesn't invalidate the display
   [self setNeedsDisplay:YES];
}

-(void)setSelectedTool:(int)tool
{
   NSLog(@"setSelectedTool with tool: %d",tool);
   
   selectedTool = tool; //     ARROW_TOOL,BUBBLE_TOOL,TERMINATOR_TOOL,STORE_TOOL,CONNECT_TOOL,DELETE_TOOL
   
   // clear all selections
   selected_element_index             = -1;
   selected_connector_index           = -1;
   
   if ((selectedTool==ARROW_TOOL) || (selectedTool==CONNECT_TOOL))
   {
      showConnectionPoints=YES;
      [self setNeedsDisplay:YES];
   }
   else
   {
      showConnectionPoints=NO;
      [self setNeedsDisplay:YES];
   }
}


// ------------------ delete methods ------------------

-(void)deleteElementOrConnector
{
   if (selected_element_index != -1)
   {
      [self deleteElement:selected_element_index];
      NSLog(@"deleteElement=%d", selected_element_index);
      // set back selection
      selected_element_index = -1;
   }
   if (selected_connector_index != -1)
   {
      [self deleteConnector: selected_connector_index ];
      NSLog(@"deleteConnector=%d", selected_connector_index);
      // set back selection
      selected_connector_index = -1;
   }
   // update the trackingAreas
   //[self updateTrackingAreas];
   [self setNeedsDisplay:YES];
   
}


-(void)deleteElement:(int)element_index
{
   // arrayOfElementsCount
   int i;
   int j;
   
   //
   // search for connector that were using arrayOfElements[element_index] and delete them
   
   j=0;
   NSLog(@"arrayOfConnectionElementsCount:%d arrayOfConnectionElementsCount=%d",element_index,arrayOfConnectionElementsCount);
   for (i=0;i<arrayOfConnectionElementsCount;i++)
   {
      if ((arrayOfConnectionElements[i].startPoint_number == element_index) ||
          (arrayOfConnectionElements[i].endPoint_number == element_index))
      {
         //
         NSLog(@"delete connection with startPoint||endPoint lineelement=%d" ,i);
         //[self deleteConnector:i];
         
      }
      else
      {
         arrayOfConnectionElements[j]=arrayOfConnectionElements[i];
         NSLog(@"arrayOfConnectionElements[j=%d]:%d %d %d %d" ,j, arrayOfConnectionElements[j].startPoint_number,
               arrayOfConnectionElements[j].endPoint_number,
               arrayOfConnectionElements[j].startPoint_connectionPoint,
               arrayOfConnectionElements[j].endPoint_connectionPoint );
         j++;
      }
   }
   // clean out old connection elements
   for( i=j;i<arrayOfConnectionElementsCount;i++)
   {
      arrayOfConnectionElements[i].number = -1;
      strcpy(arrayOfConnectionElements[i].description, "not set");
   }
   // set arrayOfConnectionElementsCount to the new value
   arrayOfConnectionElementsCount = j;
   
   // correct startPointnumber or endPoint_number
   for (i=0;i<arrayOfConnectionElementsCount;i++)
   {
      
      if (arrayOfConnectionElements[i].startPoint_number > element_index)
      {
         arrayOfConnectionElements[i].startPoint_number -= 1;
      }
      
      if (arrayOfConnectionElements[i].endPoint_number > element_index)
      {
         arrayOfConnectionElements[i].endPoint_number -= 1;
      }
   }
   
   
   NSLog(@"arrayOfConnectionElementsCount=%d",arrayOfConnectionElementsCount);
   
   // simple overwrite with next element beginning with element_index
   for (i=element_index;i<arrayOfElementsCount-1;i++)
   {
      arrayOfElements[i] = arrayOfElements[i+1];  
      arrayOfElements[i].number = i;              // modify number
   }
   arrayOfElementsCount--;
   
   arrayOfElements[arrayOfElementsCount].number = -1;
   strcpy(arrayOfElements[arrayOfElementsCount].description, "not set");
   
   NSLog(@"arrayOfElementsCount=%d",arrayOfElementsCount);
   
   
}

-(void)deleteConnector:(int)connector_index
{
   int i;
   int j;
   
   j=0;
   
   for (i=0;i<arrayOfConnectionElementsCount;i++)
   {
      if (i == connector_index)
      {
         NSLog(@"delete connection with connector_index=%d" ,i);
      }
      else
      {
         arrayOfConnectionElements[j]=arrayOfConnectionElements[i];
         arrayOfConnectionElements[j].number = j;
         j++;
      }
   }
   arrayOfConnectionElementsCount = j;
   //
   arrayOfConnectionElements[j].number = -1;
   strcpy(arrayOfConnectionElements[j].description, "not set");
}

-(NSSize)intrinsicContentSize
{
   return NSMakeSize(2000,1000);
   
}



@end
