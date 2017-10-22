//
//  BTKeyboard.m
//  HidLibrary
//
//  Created by liuyang on 2017/10/14.
//  Copyright © 2017年 liuyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/Bluetooth.h>
#import <IOBluetooth/IOBluetooth.h>
#import <IOBluetooth/IOBluetoothTypes.h>
#import <IOBluetooth/IOBluetoothUserLib.h>
#import <IOBluetooth/IOBluetoothUtilities.h>
#import <IOBluetooth/OBEX.h>
#import <IOBluetooth/OBEXBluetooth.h>
#import "BTKeyboard.h"
#import "KeyCodes.h"
#import <Cocoa/Cocoa.h>


enum BTMessageType: UInt8 {
    Handshake = 0,
    HIDControl,
    GetReport = 4,
    SetReport,
    GetProtocol,
    SetProtocol,
    GetIdle,
    SetIdle,
    Data = 0xA
};


//kBluetoothL2CAPPSMHIDControl                = 0x0011,    // HID profile - control interface
//kBluetoothL2CAPPSMHIDInterrupt                = 0x0013,    // HID profile - interrupt interface

@interface BTKeyboard()

@end

@implementation BTKeyboard

-(BTKeyboard*) init {
//    IOBluetoothHostController* controllor = [[IOBluetoothHostController alloc] init];
    IOBluetoothHostController* controllor = [IOBluetoothHostController defaultController];
    
    // Make the computer look like a keyboard device
    // 1 00101 010000 00
    // 3 21098 765432 10
    // Minor Device Class - Keyboard
    // Major Device Class - Peripheral
    // Limited Discoverable Mode
    // 1 00101 1000 00 00         Mouse
    // 1 00101 1100 00 00  Mouse and Keyboard
    [controllor setClassOfDevice:0x0025C0 forTimeInterval:60];
    
    //Keyboard
    //[controllor setClassOfDevice:0x002540 forTimeInterval:60];
    
    
//    NSString* bundlePath = [[NSBundle mainBundle] pathForResource:@"KeyboardProperty" ofType:@"plist"];
        NSString* bundlePath = [[NSBundle mainBundle] pathForResource:@"MouseProperty" ofType:@"plist"];
    NSDictionary* dct = [[NSDictionary alloc] initWithContentsOfFile:bundlePath];
    self.serviceRecord = [IOBluetoothSDPServiceRecord publishedServiceRecordWithDictionary:dct];
    IOBluetoothUserNotification *  regisControlResult = [IOBluetoothL2CAPChannel registerForChannelOpenNotifications:self selector:@selector(newChannelNotification:Channel:) withPSM:kBluetoothL2CAPPSMHIDControl direction:kIOBluetoothUserNotificationChannelDirectionIncoming];
    
    NSLog(@"register control result = %@", regisControlResult == nil ? nil : [regisControlResult description]);
    
    IOBluetoothUserNotification * regisInterruptResult = [IOBluetoothL2CAPChannel registerForChannelOpenNotifications:self selector:@selector(newChannelNotification:Channel:) withPSM:kBluetoothL2CAPPSMHIDInterrupt direction:kIOBluetoothUserNotificationChannelDirectionIncoming];
    
    [IOBluetoothL2CAPChannel registerForChannelOpenNotifications:self selector:@selector(newChannelNotification:Channel:) withPSM:kBluetoothL2CAPPSMHIDControl direction:kIOBluetoothUserNotificationChannelDirectionOutgoing];
    
    [IOBluetoothL2CAPChannel registerForChannelOpenNotifications:self selector:@selector(newChannelNotification:Channel:) withPSM:kBluetoothL2CAPPSMHIDInterrupt direction:kIOBluetoothUserNotificationChannelDirectionOutgoing];
    
    NSLog(@"register interrupt result = %@ ", regisControlResult == nil ? nil : [regisInterruptResult description]);
    
    return self;
}

-(void) terminate {
    if(self.deviceWrapper){
        if(self.deviceWrapper.device){
            NSLog(@"closing device");
            [self.deviceWrapper.device closeConnection];
        }
    }
    
    if(self.serviceRecord){
        NSLog(@"removing service");
        [self.serviceRecord removeServiceRecord];
    }
}

-(void) newChannelNotification: (IOBluetoothUserNotification*)noti Channel :(IOBluetoothL2CAPChannel*)channel {
    NSLog(@"new channel opened: channel = ");
    
    [channel setDelegate:self];
    
}



- (void)l2capChannelData:(IOBluetoothL2CAPChannel*)l2capChannel data:(void *)dataPointer length:(size_t)dataLength{
        NSData* data = [[NSData alloc] initWithBytes:dataPointer length:dataLength];
    
        NSLog(@"channel data, ");
        
        if (l2capChannel.PSM == kBluetoothL2CAPPSMHIDControl) {
            if(dataLength <= 0){
                return;
            }
            
            uint8 d[1];
            [data getBytes: d length:1];
            d[0] = d[0] / 16;
            
            enum BTMessageType messageType = (enum BTMessageType) d[0];
            
            NSLog(@"message Type %d", messageType);
            
            switch (messageType) {
            case Handshake:
                    NSLog(@"hand shake");
                break;
            case HIDControl:
                //                NSLog(format: "hid control %@",args: data.debugDescription)
                
                break;
            case SetReport:
                    NSLog(@"set report");
                    [self sendHandShake:l2capChannel Shake: Successful];
                break;
            case SetProtocol:
                    NSLog(@"set protocol");
                    [self sendHandShake:l2capChannel Shake:Successful];
                break;
                //            case .GetIdle:
                //                sendHandshake(channel: channel, .Successful)
                //                break
                //            case .SetIdle:
                //                sendHandshake(channel: channel, .Successful)
                //                break
            default:
                //                sendHandshake(channel: channel, .ErrUnsupportedRequest)
                break;
            }
        }
    
}

- (void)l2capChannelOpenComplete:(IOBluetoothL2CAPChannel*)l2capChannel status:(IOReturn)error{
    
    NSLog(@"channel open complete, channel = %d", l2capChannel.PSM);
    
    [self setupDevice:l2capChannel.device];
    
    switch (l2capChannel.PSM) {
        case kBluetoothL2CAPPSMHIDControl:
            self.deviceWrapper.controlChannel= l2capChannel;
            break;
        case kBluetoothL2CAPPSMHIDInterrupt:
            self.deviceWrapper.interruptChannel = l2capChannel;
            break;
        default:
            break;
    }
    
}

- (void)l2capChannelClosed:(IOBluetoothL2CAPChannel*)l2capChannel{
    
    NSLog(@"channel closed, channel = %d" , l2capChannel.PSM);
//    IOBluetoothL2CAPChannel* channel = nil;
    
    if(l2capChannel.PSM == kBluetoothL2CAPPSMHIDControl){
        
//        [self.deviceWrapper.device openL2CAPChannelAsync:&channel withPSM:kBluetoothL2CAPPSMHIDControl delegate:self];
//        [self.deviceWrapper.device openL2CAPChannelAsync:&channel withPSM:kBluetoothL2CAPPSMHIDInterrupt delegate:self];
        
    }
//    IOReturn result = [l2capChannel.device openL2CAPChannelAsync:&channel withPSM: l2capChannel.PSM delegate:self];
//    NSLog(@"reopen channel result %d", result);
//    [l2capChannel.device openConnection : self withPageTimeout:5 * 60 * 1000 authenticationRequired:NO];
}

- (void)l2capChannelReconfigured:(IOBluetoothL2CAPChannel*)l2capChannel{
    NSLog(@"channel reconfigured, channel = ");
}

- (void)l2capChannelWriteComplete:(IOBluetoothL2CAPChannel*)l2capChannel refcon:(void*)refcon status:(IOReturn)error{
    NSLog(@"channel write complete, channel = ");
}

- (void)l2capChannelQueueSpaceAvailable:(IOBluetoothL2CAPChannel*)l2capChannel{
    NSLog(@"channel queue space availabe, channel = ");
}


-(BOOL) setupDevice: (IOBluetoothDevice*) device{
    
    if(!self.deviceWrapper){
        self.deviceWrapper = [[BTDeviceWrapper alloc] init];
        self.deviceWrapper.device = device;
    }
//
//
//    IOBluetoothL2CAPChannel* control = [[IOBluetoothL2CAPChannel alloc] init];
//    IOReturn channelResult = [self.deviceWrapper.device openL2CAPChannelSync: &control withPSM:kBluetoothL2CAPPSMHIDControl delegate:self];
//    self.deviceWrapper.controlChannel = control;
//
//    if(channelResult != kIOReturnSuccess){
//        NSLog(@"open control channel failed %d", channelResult);
//        return NO;
//    }
//
//    self.deviceWrapper.controlChannel = control;
//
//
//    NSLog(@"open control channel result %d", channelResult);
//
//    IOBluetoothL2CAPChannel* interrupt = [[IOBluetoothL2CAPChannel alloc] init];
//    IOReturn interruptChannelResult = [self.deviceWrapper.device openL2CAPChannelSync: &interrupt withPSM:kBluetoothL2CAPPSMHIDControl delegate:self];
//
//    if(interruptChannelResult != kIOReturnSuccess ){
//        NSLog(@"open interrupt channel failed");
//        return NO;
//    }
//
//    self.deviceWrapper.interruptChannel = interrupt;
//
//    NSLog(@"open interrupt channel result %d", interruptChannelResult);
//
    return YES;
}

-(void) sendHandShake:(IOBluetoothL2CAPChannel*) channel Shake: (enum BTHandShake) status {
    
    if(channel.PSM == kBluetoothL2CAPPSMHIDInterrupt){
        NSLog(@"Passing wrong channel to handshake");
        return;
    }
    
    NSLog(@"handshake data %d", status);
    UInt8 array[] = {status};
    int lenth = 1;
    [self sendBytes:channel Data: array Length: lenth];
}

-(void) sendData: (UInt8[]) bytes Length: (int) lenth {
    if (self.deviceWrapper.interruptChannel) {
        [self sendBytes:self.deviceWrapper.interruptChannel Data:bytes Length:lenth];
    }
}

-(void) sendBytes:(IOBluetoothL2CAPChannel*)channel Data: (UInt8[]) bytes Length: (int) length {

    NSLog(@"data = %d" , *bytes);
    IOReturn result = [channel writeAsync:(bytes) length:length refcon:nil];
    
    if (result != kIOReturnSuccess) {
        NSLog(@"Buff Data Failed \(channel.psm)");
    }else{
        NSLog(@"Buff data success");
    }
}

-(void) sendKey:(int) vKeyCode Modifier: (UInt) vModifier{
    
    UInt8 keyCode = virtualKeyCodeToHIDKeyCode(vKeyCode);
    
    UInt8 modifier = 0;
    NSEventModifierFlags flags = vModifier;
    if(flags & NSEventModifierFlagCommand){
        modifier |= (1<<3);
    }
    if(flags & NSEventModifierFlagOption){
        modifier |= (1<<2);
    }
    if(flags & NSEventModifierFlagShift){
        modifier |= (1<<1);
    }
    if(flags & NSEventModifierFlagControl){
        modifier |= 1;
    }
    
    UInt8 bytes[] = {
        0xA1,      // 0 DATA | INPUT (HIDP Bluetooth)

        0x01,      // 0 Report ID
        modifier,  // 1 Modifier Keys
        0x00,      // 2 Reserved
        keyCode,   // 3 Keys ( 6 keys can be held at the same time )
        0x00,      // 4
        0x00,      // 5
        0x00,      // 6
        0x00,      // 7
        0x00,      // 8
        0x00       // 9
    };

    [self sendData:bytes Length:11];
    
   
}

-(void) sendMouse:(int) dx Dy: (int) dy Wheel: (int) wheel LeftButton: (BOOL) leftButton RightButton: (BOOL) rightButton{
    UInt8 button = 0x00;
    if(leftButton){
        button |=1 ;
    }
    if(rightButton){
        button|=2;
    }
//    if(wheel){
//        button|=4;
//    }
    button = button & 0x07;
    
    dx = dx * 2;
    dy = dy * 2;
    if(dx > 127){
        dx = 127;
    }
    if(dx < -127){
        dx = -127;
    }
    if(dy > 127){
        dy = 127;
    }
    if(dy < -127){
        dy = -127;
    }
    if(wheel > 127){
        wheel = 127;
    }
    if(wheel < -127){
        wheel = -127;
    }
    int8_t x = dx;
    int8_t y = dy;
    NSLog(@"x = %d, y = %d", x, y);
    int8_t bytes[] = {
        0xA1,     // 0 DATA | INPUT (HIDP Bluetooth)
        0x51,      // 0 Report ID
        button,  // buttons
        x,      // x
        y,   // y
        wheel
        
    };
    
    if (self.deviceWrapper.interruptChannel) {
        IOReturn result = [self.deviceWrapper.interruptChannel writeAsync:(bytes) length:6 refcon:nil];
        if (result != kIOReturnSuccess) {
            NSLog(@"Buff Data Failed \(channel.psm)");
        }else{
            NSLog(@"Buff data success");
        }
    }
    
}

-(void) connect:(int)type{
    NSMutableDictionary* d = [[NSMutableDictionary alloc] init];
//    kIOBluetoothL2CAPChannelMaxAllowedIncomingMTU        @"MaxAllowedIncomingMTU"
//#define kIOBluetoothL2CAPChannelDesiredOutgoingMTU
    
    if(self.deviceWrapper == nil || self.deviceWrapper.device == nil){
        NSArray* devices = [IOBluetoothDevice pairedDevices];
        for(id device in devices){
            IOBluetoothDevice* d = device;
            NSLog(@"paired devices name = %@", d.name);
            //Samsung Galaxy Note 3
            //小米手机
            //LIUYANG-NUC
            //Galaxy S8+
            //王佳星的MacBook Pro
            if([d.name isEqualTo:@"王佳星的MacBook Pro"]){
//            if([d.name isEqualTo:@"iPet"]){
                self.deviceWrapper = [[BTDeviceWrapper alloc] init];
                self.deviceWrapper.device = d;
            }
        }
    }
    
    
    NSNumber* i = [[NSNumber alloc] initWithInt:50];
    [d setValue:i forKey:kIOBluetoothL2CAPChannelMaxAllowedIncomingMTU];
    [d setValue:i forKey:kIOBluetoothL2CAPChannelDesiredOutgoingMTU];
    
    if(type == 0 || type == 2){
        IOBluetoothL2CAPChannel* channel = [[IOBluetoothL2CAPChannel alloc] init];
        
        //open channel 必须用同步方法， 异步方法会失败，原因未知
        IOReturn result = [self.deviceWrapper.device openL2CAPChannelSync:&channel withPSM:kBluetoothL2CAPPSMHIDControl
                                        delegate:self];
        NSLog(@"open channel result =  %d  psm = %d", result, channel.PSM);
    }
    
    if(type == 1 || type == 2){
        IOBluetoothL2CAPChannel* channel = [[IOBluetoothL2CAPChannel alloc] init];
        
        //open channel 必须用同步方法， 异步方法会失败，原因未知
        IOReturn result = [self.deviceWrapper.device openL2CAPChannelSync:&channel withPSM:kBluetoothL2CAPPSMHIDInterrupt delegate:self];
        
        NSLog(@"open channel result =  %d psm = %d", result, channel.PSM);
    }
}

@end
