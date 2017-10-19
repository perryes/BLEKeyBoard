//
//  BTDeviceWrapper.h
//  HidLibrary
//
//  Created by liuyang on 2017/10/14.
//  Copyright © 2017年 liuyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>

@interface BTDeviceWrapper: NSObject

@property IOBluetoothDevice* device;
@property (strong) IOBluetoothL2CAPChannel* interruptChannel;
@property (strong) IOBluetoothL2CAPChannel* controlChannel;



@end
