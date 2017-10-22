//
//  ViewController.m
//  MacKeyboard
//
//  Created by liuyang on 2017/10/14.
//  Copyright © 2017年 liuyang. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.keyBoard = [[BTKeyboard alloc] init];
    [AppDelegate getKeyboard];
    
    // Do any additional setup after loading the view.
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent*(NSEvent* event){
        NSLog(@"key down ");
        [self keyDown:event];
        return nil;
    }];
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyUp handler:^NSEvent*(NSEvent* event){
        [self keyUp:event];
        return nil;
    }];
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskFlagsChanged handler:^NSEvent*(NSEvent* event){
        [self flagsChanged:event];
        return nil;
    }];
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskMouseMoved handler:^NSEvent*(NSEvent* event){
        [self mouseMoved:event];
        return nil;
    }];
    
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskLeftMouseDown handler:^NSEvent*(NSEvent* event){
        [self mouseDown:event];
        return event;
    }];
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskRightMouseDown handler:^NSEvent*(NSEvent* event){
        [self mouseDown:event];
        return event;
    }];
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskLeftMouseUp handler:^NSEvent*(NSEvent* event){
        [self mouseUp:event];
        return event;
    }];
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskRightMouseUp handler:^NSEvent*(NSEvent* event){
        [self mouseUp:event];
        return event;
    }];
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskRightMouseDragged handler:^NSEvent*(NSEvent* event){
        [self mouseDragged:event];
        return event;
    }];
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskScrollWheel handler:^NSEvent*(NSEvent* event){
        [self scrollWheel:event];
        return event;
    }];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

-(void) keyUp:(NSEvent *)event {
    [[AppDelegate getKeyboard] sendKey: (int)-1 Modifier:event.modifierFlags];
}
-(void) keyDown:(NSEvent *)event {
    [[AppDelegate getKeyboard] sendKey:(int)event.keyCode Modifier:event.modifierFlags];
}
-(void) flagsChanged:(NSEvent *)event {
//    [[AppDelegate getKeyboard] sendKey:event.keyCode Modifier:event.modifierFlags];
}
- (IBAction)controlConnect:(id)sender {
    [[AppDelegate getKeyboard] connect:0];
}
- (IBAction)interruptConnect:(id)sender {
    [[AppDelegate getKeyboard] connect:1];
}

- (IBAction)bothConnect:(id)sender {
    [[AppDelegate getKeyboard] connect:2];
}

-(void) mouseMoved:(NSEvent *)event {
    
    [[AppDelegate getKeyboard] sendMouse:ceilf(event.deltaX) Dy:ceilf(event.deltaY) Wheel:0 LeftButton:false RightButton:false];
}

-(void) mouseDown:(NSEvent *)event{
    bool leftDown = (NSEvent.pressedMouseButtons & 0x01) == 0x01;
    bool rightDown = (NSEvent.pressedMouseButtons & 0x02) == 0x02;
    NSLog(@"mouse down: left down =  %@    right down = %@", leftDown ? @"down" : @"up", rightDown ? @"down" : @"up");
    [[AppDelegate getKeyboard] sendMouse:ceilf(event.deltaX) Dy:ceilf(event.deltaY) Wheel:0 LeftButton:leftDown RightButton:rightDown];
}

-(void) mouseUp:(NSEvent *)event{
    bool leftDown = (NSEvent.pressedMouseButtons & 0x01) == 0x01;
    bool rightDown = (NSEvent.pressedMouseButtons & 0x02) == 0x02;
    NSLog(@"mouse up: left down =  %@    right down = %@", leftDown ? @"down" : @"up", rightDown ? @"down" : @"up");
    [[AppDelegate getKeyboard] sendMouse:ceilf(event.deltaX) Dy:ceilf(event.deltaY)
                                   Wheel:0 LeftButton:leftDown RightButton:rightDown];
}

-(void) mouseDragged:(NSEvent *)event{
    bool leftDown = (NSEvent.pressedMouseButtons & 0x01) == 0x01;
    bool rightDown = (NSEvent.pressedMouseButtons & 0x02) == 0x02;
    NSLog(@"mouse drag: left down =  %@    right down = %@", leftDown ? @"down" : @"up", rightDown ? @"down" : @"up");
    [[AppDelegate getKeyboard] sendMouse:ceilf(event.deltaX) Dy:ceilf(event.deltaY)
                                   Wheel:0 LeftButton:true RightButton:rightDown];
}

-(void) scrollWheel:(NSEvent *)event{
    bool leftDown = (NSEvent.pressedMouseButtons & 0x01) == 0x01;
    bool rightDown = (NSEvent.pressedMouseButtons & 0x02) == 0x02;
    NSLog(@"mouse scroll: left down =  %@    right down = %@  wheel = %f", leftDown ? @"down" : @"up", rightDown ? @"down" : @"up", event.deltaY);
    [[AppDelegate getKeyboard] sendMouse:ceilf(event.deltaX) Dy:ceilf(event.deltaY)
                                   Wheel:event.deltaY LeftButton:false RightButton:false];
}

@end
