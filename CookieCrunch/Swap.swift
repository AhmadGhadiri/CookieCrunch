//
//  Swap.swift
//  CookieCrunch
//
//  Created by Ahmad Ghadiri on 4/10/15.
//  Copyright (c) 2015 Ahmad Ghadiri. All rights reserved.
//

struct Swap: Printable {
    let cookieA: Cookie
    let cookieB: Cookie
    
    init(cookieA: Cookie, cookieB: Cookie) {
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    
    var description: String {
        return "swap \(cookieA) with \(cookieB)"
    }
}

