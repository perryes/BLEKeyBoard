//
//  AppDelegate.m
//  MacKeyboard
//
//  Created by liuyang on 2017/10/14.
//  Copyright © 2017年 liuyang. All rights reserved.
//

#import "AppDelegate.h"
#import "HidLibrary.h"
#import "BTKeyboard.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    HidLibrary* lb = [HidLibrary alloc];
    [lb testMethodString:@"hellp"];
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    if([AppDelegate getKeyboard]){
        [[AppDelegate getKeyboard] terminate];
    }
}

+(BTKeyboard*) getKeyboard{
    static BTKeyboard* btKeyboard = nil;
    if(btKeyboard == nil){
        btKeyboard = [[BTKeyboard alloc] init];
    }
    
    return btKeyboard;
}


@end
