//
//  RWTChain.h
//  CookieCrunch
//
//  Created by Ahmad Ghadiri on 4/11/15.
//  Copyright (c) 2015 Ahmad Ghadiri. All rights reserved.
//

#import "Foundation/Foundation.h"

@class RWTCookie;

typedef NS_ENUM(NSUInteger, ChainType) {
    ChainTypeHorizontal,
    ChainTypeVertical,
};

@interface RWTChain : NSObject

@property (strong, nonatomic, readonly) NSArray *cookies;

@property (assign, nonatomic) ChainType chainType;

- (void)addCookie:(RWTCookie *)cookie;

@end