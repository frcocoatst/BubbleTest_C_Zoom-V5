//
//  Controller.m
//  BubbleTest_C
//
//  Created by Friedrich Haeupl on 07.09.14.
//  Copyright (c) 2014 fritz. All rights reserved.
//

#import "Controller.h"

@implementation Controller
- (IBAction)sliderAction:(id)sender
{
   NSLog(@"sliderAction");
   [self.ViewOutlet setLineThickness:[self.sliderValue intValue]];
}

- (IBAction)textAction:(id)sender
{
   NSLog(@"textAction");
   [self.ViewOutlet setBubbleOrConnectorName:[self.textOutlet stringValue]];
}

- (IBAction)scalePopupAction:(id)sender
{
   NSLog(@"scalePopupAction =%ld", [self.scalePopupOutlet selectedTag]);
   
   switch ([self.scalePopupOutlet selectedTag])
   {
      case 1:
         [self.ViewOutlet setViewSize:1.0];
         break;
         
      case 2:
         [self.ViewOutlet setViewSize:2.0];
         break;
         
      case 3:
         [self.ViewOutlet setViewSize:0.5];
         break;
         
      default:
         [self.ViewOutlet setViewSize:1.0];
         break;
   }
}

- (IBAction)toolAction:(id)sender
{
   NSLog(@"selectedTool with tag=%ld",[self.selectedToolOutlet selectedTag]);
   [self.ViewOutlet setSelectedTool:(int)[self.selectedToolOutlet selectedTag]];
   
}

- (IBAction)deleteButtonAction:(id)sender
{
   NSLog(@"deleteButtonAction");
   [self.ViewOutlet deleteElementOrConnector];
}


@end
