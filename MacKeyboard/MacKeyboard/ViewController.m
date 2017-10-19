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



@end
