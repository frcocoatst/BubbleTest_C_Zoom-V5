//
//  Controller.h
//  BubbleTest_C
//
//  Created by Friedrich Haeupl on 07.09.14.
//  Copyright (c) 2014 fritz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BubbleTestView.h"

@interface Controller : NSObject

@property (weak) IBOutlet BubbleTestView *ViewOutlet;
@property (weak) IBOutlet NSMatrix *selectedToolOutlet;
@property (weak) IBOutlet NSTextField *textOutlet;
@property (weak) IBOutlet NSPopUpButton *scalePopupOutlet;
@property (weak) IBOutlet NSSlider *sliderValue;
@property (weak) IBOutlet NSButton *deleteButtonOutlet;

- (IBAction)sliderAction:(id)sender;
- (IBAction)scalePopupAction:(id)sender;
- (IBAction)textAction:(id)sender;
- (IBAction)toolAction:(id)sender;
- (IBAction)deleteButtonAction:(id)sender;

@end
