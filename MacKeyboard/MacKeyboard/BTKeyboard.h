//
//  BTKeyboard.h
//  HidLibrary
//
//  Created by liuyang on 2017/10/14.
//  Copyright © 2017年 liuyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>
#import "BTDeviceWrapper.h"

enum BTHandShake:UInt8 {
    Successful = 0,
    NotReady,
    ErrInvalidReportId,
    ErrUnsupportedRequest,
    ErrInvalidParameter,
    ErrUnknown = 0xE,
    ErrFatal = 0xF
};

@interface BTKeyboard : NSObject<IOBluetoothL2CAPChannelDelegate>

@property IOBluetoothSDPServiceRecord* serviceRecord;
@property BTDeviceWrapper* deviceWrapper;

-(void) sendKey:(int) keyCode Modifier: (UInt) modifier;

-(void) connect:(int) type;
//-(BTKeyboard*) init;

-(void) terminate;

-(void) sendMouse:(float) dx Dy: (float) dy Wheel: (float) wheel LeftButton: (BOOL) leftButton RightButton: (BOOL) rightButton;

@end
