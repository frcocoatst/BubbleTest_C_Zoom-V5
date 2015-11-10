//
//  BubbleTestView.h
//  BubbleTest_C
//
//  Created by Friedrich Haeupl on 21.07.14.
//  Copyright (c) 2014 fritz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
/*!
 @typedef TOOLS
 @brief A list of available tools
 @constant ARROW_TOOL
 @constant BUBBLE_TOOL
 @constant TERMINATOR_TOOL
 @constant STORE_TOOL
 @constant CONNECT_TOOL
 @constant STATE_TOOL
 @constant DELETE_TOOL
 */
enum
{
    ARROW_TOOL=0,
    BUBBLE_TOOL,
    TERMINATOR_TOOL,
    STORE_TOOL,
    CONNECT_TOOL,
    STATE_TOOL,
    DELETE_TOOL
};

/*!
 @typedef SUPPORTED ELEMENTS
 @brief A list of available elements
 @constant BUBBLE
 @constant TERMINATOR
 @constant STORE
 @constant STATE
 */
enum
{
    BUBBLE = 1,
    TERMINATOR,
    STORE,
    STATE
};

/*!
 @typedef struct to describe an element
 */
typedef struct
{
    // description data
    int number;                      // reference number
    int type;                        // type = [BUBBLE|TERMINATOR|STORE|RECT]
    char name[32];                   // name string
    char description[256];           // description string
    // layout data
    NSPoint location;                // central location of the element
    int number_connectionPoint;      // actual number of connectionpoints
    NSPoint connectionPoints[12];    // array of connection points
    
}element;

/*!
 @typedef struct to describe aconnector
 */
typedef struct
{
    // description data
    int number;                      // reference number
    int type;                        // type = [DATA|CONTROL]
    char name[32];                   // name string
    char description[256];           // description string
    // layout data
    int startPoint_number;           // reference to the element where the line starts
    int startPoint_connectionPoint;  // reference to the connection point where the line starts
    int endPoint_number;             // reference to the element where the line ends
    int endPoint_connectionPoint;    // reference to the connection point where the line ends
    NSPoint controlPoint[2];         // control points for beziercurve
    int number_wayPoint;             // number of waypoints
    NSPoint wayPoints[12];           // waypoints array
    NSPoint labelPoint;              // point where the label is placed
    
}connection;


@interface BubbleTestView : NSView
{
    element     arrayOfElements[100];            // storage for elements
    connection  arrayOfConnectionElements[100];  // storage for connections
    NSTrackingArea * trackingArea;               // tracking Area
    
    int arrayOfElementsCount;
    int arrayOfConnectionElementsCount;
    int numberCounter;
    
    int selected_element_index;
    int selected_connector_index;
    int startpoint_element;
    int startpoint_index;
    int endpoint_element;
    int endpoint_index;
    BOOL showConnectionPoints;
    BOOL startpoint_selected;
    
    BOOL controlpoint1_selected;
    BOOL controlpoint2_selected;
    NSPoint controlPoint_1;
    NSPoint controlPoint_2;
    
    float linewidth;
    int selectedTool;
}

/*!
 @discussion sets the thickness of a connection line
 @param value integer ranging from 1 to 5
 @return void
 */
-(void)setLineThickness:(int)value;

/*!
 @discussion sets bubble or connector name
 @param str a NSString
 @return void
 */
-(void)setBubbleOrConnectorName:(NSString *)str;

/*!
 @discussion sets the size of the view
 @param value double ranging between 0,5 and 2,0
 @return void
 */
-(void)setViewSize:(double)value;

/*!
 @discussion sets the selected tool
 @param tool integer containg the tag of the selected tool
 @return none
 */
-(void)setSelectedTool:(int)tool;

/*!
 @discussion snaps a point to the next grid point
 @param input point NSPoint
 @return next grid point NSPoint
 */
-(NSPoint)snapToGrid:(NSPoint)point;

/*!
 @discussion deletes the selected element or connector
 @param none
 @return void
 */
-(void)deleteElementOrConnector;

/*!
 @discussion deletes an element
 @param element index of the element to be deleted
 @return none
 */
-(void)deleteElement:(int)element_index;

/*!
 @discussion deletes an connector
 @param element index of the connector to be deleted
 @return none
 */
-(void)deleteConnector:(int)connector_index;

@end
