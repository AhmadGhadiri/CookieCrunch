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
                    CroissantVer, CupcakeVer, DanishVer, DonutVer, MacaroonVer, SugarCookieVer,
                    CroissantHor, CupcakeHor, DanishHor, DonutHor, MacaroonHor, SugarCookieHor,
                    CroissantBomb, CupcakeBomb, DanishBomb, DonutBomb, MacaroonBomb, SugarCookieBomb
    
    
    var spriteName: String {
        let spriteNames = [
            "Croissant",
            "Cupcake",
            "Danish",
            "Donut",
            "Macaroon",
            "SugarCookie",
            "CroissantVer",
            "CupcakeVer",
            "DanishVer",
            "DonutVer",
            "MacaroonVer",
            "SugarCookieVer",
            "CroissantHor",
            "CupcakeHor",
            "DanishHor",
            "DonutHor",
            "MacaroonHor",
            "SugarCookieHor",
            "CroissantBomb",
            "CupcakeBomb",
            "DanishBomb",
            "DonutBomb",
            "MacaroonBomb",
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
    var cookieType: CookieType
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
    
    static func returnGiftedVersion(oldType:CookieType, giftType: String) -> CookieType {
        if giftType == "VERTICAL" {
            return CookieType(rawValue: oldType.rawValue + 6)!
        }
        else if giftType == "HORIZONTAL" {
            return CookieType(rawValue: oldType.rawValue + 12)!
        }
        else if giftType == "BOMB" {
            return CookieType(rawValue: oldType.rawValue + 18)!
        }
        return CookieType.Unknown
    }
    
    func changeCookieType(newType:CookieType) {
        self.cookieType = newType
    }
    
    var hashValue: Int {
        return row*10+column
    }
}