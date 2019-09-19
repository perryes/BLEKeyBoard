//
//  ViewController.h
//  MacKeyboard
//
//  Created by liuyang on 2017/10/14.
//  Copyright © 2017年 liuyang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BTKeyboard.h"
#import "AppDelegate.h"

@interface ViewController : NSViewController<NSTableViewDataSource, NSTableViewDelegate>

@property BTKeyboard* keyBoard;
@property (weak) IBOutlet NSTableView *tbDevices;

@end

