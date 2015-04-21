//
//  Cookie.swift
//  CookieCrunch
//
//  Created by Ahmad Ghadiri on 4/8/15.
//  Copyright (c) 2015 Ahmad Ghadiri. All rights reserved.
//

import SpriteKit

enum CookieType: Int, Printable{
    case Unknown = 0, Croissant, Cupcake, Danish, Donut, Macaroon, SugarCookie,
                    CroissantVer, CroissantHor, CroissantBomb, CupcakeVer, CupcakeHor, CupcakeBomb,
                    DanishVer, DanishHor, DanishBomb, DonutVer, DonutHor, DonutBomb, MacaroonVer,
                    MacaroonHor, MacaroonBomb, SugarCookieVer, SugarCookieHor,SugarCookieBomb
    
    
    var spriteName: String {
        let spriteNames = [
            "Croissant",
            "Cupcake",
            "Danish",
            "Donut",
            "Macaroon",
            "SugarCookie",
            "CroissantVer",
            "CroissantHor",
            "CroissantBomb",
            "CupcakeVer",
            "CupcakeHor",
            "CupcakeBomb",
            "DanishVer",
            "DanishHor",
            "DanishBomb",
            "DonutVer",
            "DonutHor",
            "DonutBomb",
            "MacaroonVer",
            "MacaroonHor",
            "MacaroonBomb",
            "SugarCookieVer",
            "SugarCookieHor",
            "SugarCookieBomb"]
        
        return spriteNames[rawValue - 1]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    static func random() -> CookieType {
        return CookieType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
    
    // For Printable
    var description: String {
        return spriteName
    }
}


func ==(lhs: Cookie, rhs: Cookie) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}

class Cookie: Printable, Hashable {
    var column: Int
    var row: Int
    let cookieType: CookieType
    var sprite: SKSpriteNode?
    
    //for printable
    var description: String {
        return "type:\(cookieType) square:(\(column),\(row))"
    }
    
    init(column: Int, row: Int, cookieType: CookieType) {
        self.column = column
        self.row = row
        self.cookieType = cookieType
    }
    
    var hashValue: Int {
        return row*10+column
    }
}