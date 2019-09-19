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
    [self.tbDevices setDataSource:self];
    [self.tbDevices setDelegate:self];
    
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
        return nil;
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
//    [[AppDelegate getKeyboard] connect:1];
    [[AppDelegate getKeyboard] sendMouse:0 Dy:0
                                   Wheel:-1 LeftButton:false RightButton:false];
    
}

- (IBAction)bothConnect:(id)sender {
    [[AppDelegate getKeyboard] connect:2];
}

-(void) mouseMoved:(NSEvent *)event {
    
//    [[AppDelegate getKeyboard] sendMouse:event.deltaX Dy:event.deltaY Wheel:0 LeftButton:false RightButton:false];
    
//    NSPoint event_location = [event locationInWindow];
//    NSPoint local_point = [self.view convertPoint:event_location fromView:nil];
    
    
    //    NSPoint pointInScreen =  [self.view.window convertPointToScreen:_pointInView];
    //    [[AppDelegate getKeyboard] sendMouseAbsoulte:pointInScreen.x Dy:pointInScreen.y Wheel:0 LeftButton:false RightButton:false];
    
    NSPoint screenPoint = [NSEvent mouseLocation];
    NSRect screenRect = CGRectMake(screenPoint.x, screenPoint.y, 1.0, 1.0);
    NSRect baseRect = [self.view.window convertRectFromScreen:screenRect];
    NSPoint _pointInView = [self.view convertPoint:baseRect.origin fromView:nil];
    
    if (CGRectContainsPoint(self.view.bounds, _pointInView)) {
        //1440 * 900   mac
        //2880 * 1800
        //    int32_t x = (int32_t) (dx * 24);
        //    int32_t x = (int32_t) (dx * 24);
        //    int32_t y = (int32_t) ((900 - dy) * 36);
        //    int32_t y = (int32_t) ((900 - dy) * 36);
        float x = ((1440 * 24) / self.view.bounds.size.width) * _pointInView.x;
        float y = ((900 * 36) / self.view.bounds.size.height) * (self.view.bounds.size.height - _pointInView.y);
        [[AppDelegate getKeyboard] sendMouseAbsoulte:x Dy:y Wheel:0 LeftButton:false RightButton:false];
    }
}

-(void) mouseDown:(NSEvent *)event{
    bool leftDown = (NSEvent.pressedMouseButtons & 0x01) == 0x01;
    bool rightDown = (NSEvent.pressedMouseButtons & 0x02) == 0x02;
//    NSLog(@"mouse down: left down =  %@    right down = %@", leftDown ? @"down" : @"up", rightDown ? @"down" : @"up");
//    [[AppDelegate getKeyboard] sendMouse:event.deltaX Dy:event.deltaY Wheel:0 LeftButton:leftDown RightButton:rightDown];


    NSPoint screenPoint = [NSEvent mouseLocation];
    NSRect screenRect = CGRectMake(screenPoint.x, screenPoint.y, 1.0, 1.0);
    NSRect baseRect = [self.view.window convertRectFromScreen:screenRect];
    NSPoint _pointInView = [self.view convertPoint:baseRect.origin fromView:nil];
    
    if (CGRectContainsPoint(self.view.bounds, _pointInView)) {
        //1440 * 900   mac
        //2880 * 1800
        //    int32_t x = (int32_t) (dx * 24);
        //    int32_t x = (int32_t) (dx * 24);
        //    int32_t y = (int32_t) ((900 - dy) * 36);
        //    int32_t y = (int32_t) ((900 - dy) * 36);
        float x = ((1440 * 24) / self.view.bounds.size.width) * _pointInView.x;
        float y = ((900 * 36) / self.view.bounds.size.height) * (self.view.bounds.size.height - _pointInView.y);
        [[AppDelegate getKeyboard] sendMouseAbsoulte:x Dy:y Wheel:0 LeftButton:leftDown RightButton:rightDown];
    }
}

-(void) mouseUp:(NSEvent *)event{
    bool leftDown = (NSEvent.pressedMouseButtons & 0x01) == 0x01;
    bool rightDown = (NSEvent.pressedMouseButtons & 0x02) == 0x02;
    NSLog(@"mouse up: left down =  %@    right down = %@", leftDown ? @"down" : @"up", rightDown ? @"down" : @"up");
//    [[AppDelegate getKeyboard] sendMouse:event.deltaX Dy:event.deltaY
//                                   Wheel:0 LeftButton:leftDown RightButton:rightDown];
    
    NSPoint screenPoint = [NSEvent mouseLocation];
    NSRect screenRect = CGRectMake(screenPoint.x, screenPoint.y, 1.0, 1.0);
    NSRect baseRect = [self.view.window convertRectFromScreen:screenRect];
    NSPoint _pointInView = [self.view convertPoint:baseRect.origin fromView:nil];
    
    if (CGRectContainsPoint(self.view.bounds, _pointInView)) {
        //1440 * 900   mac
        //2880 * 1800
        //    int32_t x = (int32_t) (dx * 24);
        //    int32_t x = (int32_t) (dx * 24);
        //    int32_t y = (int32_t) ((900 - dy) * 36);
        //    int32_t y = (int32_t) ((900 - dy) * 36);
        float x = ((1440 * 24) / self.view.bounds.size.width) * _pointInView.x;
        float y = ((900 * 36) / self.view.bounds.size.height) * (self.view.bounds.size.height - _pointInView.y);
        [[AppDelegate getKeyboard] sendMouseAbsoulte:x Dy:y Wheel:0 LeftButton:leftDown RightButton:rightDown];
    }
}

-(void) mouseDragged:(NSEvent *)event{
    bool leftDown = (NSEvent.pressedMouseButtons & 0x01) == 0x01;
    bool rightDown = (NSEvent.pressedMouseButtons & 0x02) == 0x02;
    NSLog(@"mouse drag: left down =  %@    right down = %@", leftDown ? @"down" : @"up", rightDown ? @"down" : @"up");
//    [[AppDelegate getKeyboard] sendMouse:event.deltaX Dy:event.deltaY
//                                   Wheel:0 LeftButton:true RightButton:rightDown];
    
    NSPoint screenPoint = [NSEvent mouseLocation];
    NSRect screenRect = CGRectMake(screenPoint.x, screenPoint.y, 1.0, 1.0);
    NSRect baseRect = [self.view.window convertRectFromScreen:screenRect];
    NSPoint _pointInView = [self.view convertPoint:baseRect.origin fromView:nil];
    
    if (CGRectContainsPoint(self.view.bounds, _pointInView)) {
        //1440 * 900   mac
        //2880 * 1800
        //    int32_t x = (int32_t) (dx * 24);
        //    int32_t x = (int32_t) (dx * 24);
        //    int32_t y = (int32_t) ((900 - dy) * 36);
        //    int32_t y = (int32_t) ((900 - dy) * 36);
        float x = ((1440 * 24) / self.view.bounds.size.width) * _pointInView.x;
        float y = ((900 * 36) / self.view.bounds.size.height) * (self.view.bounds.size.height - _pointInView.y);
        [[AppDelegate getKeyboard] sendMouseAbsoulte:x Dy:y Wheel:0 LeftButton:true RightButton:rightDown];
    }
}

-(void) scrollWheel:(NSEvent *)event{
    bool leftDown = (NSEvent.pressedMouseButtons & 0x01) == 0x01;
    bool rightDown = (NSEvent.pressedMouseButtons & 0x02) == 0x02;
    NSLog(@"mouse scroll: left down =  %@    right down = %@  deltY = %f  scrollDeltY = %f", leftDown ? @"down" : @"up", rightDown ? @"down" : @"up", event.deltaY, event.scrollingDeltaY);
//    [[AppDelegate getKeyboard] sendMouse:ceilf(event.deltaX) Dy:ceilf(event.deltaY)
//                                   Wheel:event.deltaY LeftButton:false RightButton:false];
    int wheel = event.deltaY * 2;
    if(event.deltaY > 1){
        wheel = 1;
    }else if(event.deltaY < -1){
        wheel = -1;
    }
//    [[AppDelegate getKeyboard] sendMouse:0 Dy:0
//                                   Wheel:wheel LeftButton:false RightButton:false];
    
    [[AppDelegate getKeyboard] sendMouseAbsoulte:0 Dy:0
                                   Wheel:wheel LeftButton:false RightButton:false];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSArray* devices = [[AppDelegate getKeyboard] getDevices];
    return [devices count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSTableCellView* v;
    v = [tableView makeViewWithIdentifier:tableColumn.identifier owner:nil];
    
     NSArray* devices = [[AppDelegate getKeyboard] getDevices];
    IOBluetoothDevice* d = [devices objectAtIndex:row];
    int column = 0;
    if(tableColumn == tableView.tableColumns[0]){
        column = 0;
        v.textField.stringValue = d.nameOrAddress;
        
    }else if(tableColumn == tableView.tableColumns[1]){
        column = 1;
        if(d.lastNameUpdate){
            v.textField.stringValue = d.lastNameUpdate.description;
        }else{
            v.textField.stringValue = @"null";
        }
        
    }else if(tableColumn == tableView.tableColumns[2]){
        column = 2;
        if(d.services){
            IOBluetoothSDPServiceRecord *r = [d.services objectAtIndex:0];
            NSLog(@"device = %@", d);
//            v.textField.stringValue = [[[r attributes] valueForKey:@"description"] componentsJoinedByString:@" "];
            NSLog(@"service %@", r);
        }else{
            v.textField.stringValue = @"2";
        }
        
    }
    
    return v;
}

@end
