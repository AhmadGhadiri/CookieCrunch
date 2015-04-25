//
//  Cookie.swift
//  CookieCrunch
//
//  Created by Ahmad Ghadiri on 4/8/15.
//  Copyright (c) 2015 Ahmad Ghadiri. All rights reserved.
//

import SpriteKit

func ==(lhs: CookieType, rhs: CookieType) -> Bool {
//    if lhs.rawValue == 25 || rhs.rawValue == 25 {
//        return false
//    }
    return lhs.rawValue%6 == rhs.rawValue%6
}

enum CookieType: Int, Printable{
    case Unknown = 0, Croissant, Cupcake, Danish, Donut, Macaroon, SugarCookie,
                    CroissantVer, CupcakeVer, DanishVer, DonutVer, MacaroonVer, SugarCookieVer,
                    CroissantHor, CupcakeHor, DanishHor, DonutHor, MacaroonHor, SugarCookieHor,
                    CroissantBomb, CupcakeBomb, DanishBomb, DonutBomb, MacaroonBomb, SugarCookieBomb,
                    allcookie
    
    
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
            "SugarCookieBomb",
            "allcookie"]
        
        return spriteNames[rawValue - 1]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    static func random() -> CookieType {
        return CookieType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
    
    static func returnGiftedVersion(oldType:CookieType, giftType: String) -> CookieType {
        var typeValue = oldType.rawValue%6
        typeValue = (typeValue == 0 ? 6 : oldType.rawValue%6)
        switch giftType {
        case "VERTICAL":
            return CookieType(rawValue: typeValue + 6)!
        case "HORIZONTAL":
            return CookieType(rawValue: typeValue + 12)!
        case "BOMB":
            return CookieType(rawValue: typeValue + 18)!
        default:
            return CookieType.Unknown
        }
    }
    
    static func isItBoostable(type: CookieType) -> Bool {
        if type.rawValue >= 7 && type.rawValue <= 19 {
            return true
        }
        return false
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
    /*var bursted: Bool {
        get {
            return self.bursted
        }
        set(bursted) {
            self.bursted = bursted
        }
    }*/
    
    //for printable
    var description: String {
        return "type:\(cookieType) square:(\(column),\(row))"
    }
    
    init(column: Int, row: Int, cookieType: CookieType) {
        self.column = column
        self.row = row
        self.cookieType = cookieType
        //self.bursted = false
    }
    
    func changeCookieType(newType:CookieType) {
        self.cookieType = newType
    }
    
    var hashValue: Int {
        return row*10+column
    }
}