//
//  Level.swift
//  CookieCrunch
//
//  Created by Ahmad Ghadiri on 4/8/15.
//  Copyright (c) 2015 Ahmad Ghadiri. All rights reserved.
//

import Foundation


let NumColumns = 9
let NumRows = 9

class Level {
    private var cookies = Array2D<Cookie>(columns: NumColumns, rows: NumRows)
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    
    // For checking possible movements
    private var possibleSwaps = MySet<Swap>()
    
    // For the points
    var targetScore = 0
    var maximumMoves = 0
    
    // For the last swap and boostable moves
    var lastSwap : Swap = Swap(cookieA: Cookie(column: 1, row: 1, cookieType: .Unknown), cookieB: Cookie(column: 1, row: 1, cookieType: .Unknown) )
    var boostable : Bool = false
    
    // For combos
    private var comboMultiplier = 0
    
    
    func cookieAtColumn(column: Int, row: Int) -> Cookie? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return cookies[column, row]
    }

    // To shuffle and check all possible moves
    func shuffle() -> MySet<Cookie> {
        var set: MySet<Cookie>
        do {
            set = createInitialCookies()
            detectPossibleSwaps()
            println("possible swaps: \(possibleSwaps)")
        }
        while possibleSwaps.count == 0
        
        return set
    }
    
    // Helper method
    private func hasChainAtColumn(column: Int, row: Int) -> Bool {
        let cookieType = cookies[column, row]!.cookieType
        
        var horzLength = 1
        for var i = column - 1; i >= 0 && cookies[i, row]?.cookieType == cookieType;
            --i, ++horzLength { }
        for var i = column + 1; i < NumColumns && cookies[i, row]?.cookieType == cookieType;
            ++i, ++horzLength { }
        if horzLength >= 3 { return true }
        
        var vertLength = 1
        for var i = row - 1; i >= 0 && cookies[column, i]?.cookieType == cookieType;
            --i, ++vertLength { }
        for var i = row + 1; i < NumRows && cookies[column, i]?.cookieType == cookieType;
            ++i, ++vertLength { }
        return vertLength >= 3
    }
    
    func detectPossibleSwaps() {
        var set = MySet<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let cookie = cookies[column, row] {
                    if cookies[column, row]?.cookieType == .allcookie {
                        var ringCookies = cookiesAroundThisCookie(column, row: row)
                        for other in ringCookies {
                            set.addElement(Swap(cookieA: cookies[other.column,other.row]!, cookieB: cookies[column,row]!))
                        }
                    }
                    else {
                        // TODO: detection logic goes here
                        // Is it possible to swap this cookie with the one on the right?
                        if column < NumColumns - 1 {
                            // Have a cookie in this spot? If there is no tile, there is no cookie.
                            if let other = cookies[column + 1, row] {
                                // Swap them
                                cookies[column, row] = other
                                cookies[column + 1, row] = cookie
                                
                                // Is either cookie now part of a chain?
                                if hasChainAtColumn(column + 1, row: row) ||
                                    hasChainAtColumn(column, row: row) {
                                        set.addElement(Swap(cookieA: cookie, cookieB: other))
                                }
                                
                                // Swap them back
                                cookies[column, row] = cookie
                                cookies[column + 1, row] = other
                                
                            }
                        }
                        // Try to swap with the one above
                        if row < NumRows - 1 {
                            if let other = cookies[column, row + 1] {
                                cookies[column, row] = other
                                cookies[column, row + 1] = cookie
                                
                                // Is either cookie now part of a chain?
                                if hasChainAtColumn(column, row: row + 1) ||
                                    hasChainAtColumn(column, row: row) {
                                        set.addElement(Swap(cookieA: cookie, cookieB: other))
                                }
                                
                                // Swap them back
                                cookies[column, row] = cookie
                                cookies[column, row + 1] = other
                            }
                        }
                    }
                }
            }
        }
        possibleSwaps = set
    }
    
    
    
    private func createInitialCookies() -> MySet<Cookie> {
        var set = MySet<Cookie>()
        
        // 1
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if tiles[column,row] != nil {
                    // 2
                    
                    // To remove all the cookies that are making matches already
                    var cookieType: CookieType
                    do {
                        cookieType = CookieType.random()
                    }
                        while (column >= 2 &&
                            cookies[column - 1, row]?.cookieType == cookieType &&
                            cookies[column - 2, row]?.cookieType == cookieType)
                            || (row >= 2 &&
                                cookies[column, row - 1]?.cookieType == cookieType &&
                                cookies[column, row - 2]?.cookieType == cookieType)
                
                    // 3
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                
                    // 4
                    set.addElement(cookie)
                }
            }
        }
        return set
    }
    
    // For Json reading
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    init(filename: String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            if let tilesArray: AnyObject = dictionary["tiles"] {
                for (row, rowArray) in enumerate(tilesArray as! [[Int]]) {
                    let tileRow = NumRows - row - 1
                    for (column, value) in enumerate(rowArray) {
                        if value == 1 {
                            tiles[column, tileRow] = Tile()
                        }
                    }
                }
                targetScore = dictionary["targetScore"] as! Int
                maximumMoves = dictionary["moves"] as! Int
//                self.lastSwap = Swap(cookieA: Cookie(column: 1, row: 1, cookieType: .Unknown), cookieB: Cookie(column: 1, row: 1, cookieType: .Unknown) )
//                self.boostable = false
            }
        }
    }
    
    // Performs the logic of the swap
    func performSwap(swap: Swap) {
        let columnA = swap.cookieA.column
        let rowA = swap.cookieA.row
        let columnB = swap.cookieB.column
        let rowB = swap.cookieB.row
        
        cookies[columnA, rowA] = swap.cookieB
        swap.cookieB.column = columnA
        swap.cookieB.row = rowA
        
        cookies[columnB, rowB] = swap.cookieA
        swap.cookieA.column = columnB
        swap.cookieA.row = rowB
        
        if (swap.cookieA.cookieType == .allcookie || swap.cookieB.cookieType == .allcookie) {
            self.boostable = true
        }
        self.lastSwap = swap
    }
    
    func isPossibleSwap(swap: Swap) -> Bool {
        return possibleSwaps.containsElement(swap)
    }
    
    // Detecting the Horizontal chains
    private func detectHorizontalMatches() -> MySet<Chain> {

        var set = MySet<Chain>()

        for row in 0..<NumRows {
            for var column = 0; column < NumColumns - 2 ; {
                
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType
                    
                    if cookies[column + 1, row]?.cookieType == matchType &&
                        cookies[column + 2, row]?.cookieType == matchType {
                            // 5
                            let chain = Chain(chainType: .Horizontal)
                            do {
                                chain.addCookie(cookies[column, row]!)
                                ++column
                            }
                            while column < NumColumns && cookies[column, row]?.cookieType == matchType
                            
                            set.addElement(chain)
                            continue
                    }
                }
                // 6
                ++column
            }
        }
        return set
    }
    
    // Detecting the Vertical chains
    private func detectVerticalMatches() -> MySet<Chain> {
        var set = MySet<Chain>()
        
        for column in 0..<NumColumns {
            for var row = 0; row < NumRows - 2; {
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType
                    
                    if cookies[column, row + 1]?.cookieType == matchType &&
                        cookies[column, row + 2]?.cookieType == matchType {
                            
                            let chain = Chain(chainType: .Vertical)
                            do {
                                chain.addCookie(cookies[column, row]!)
                                ++row
                            }
                                while row < NumRows && cookies[column, row]?.cookieType == matchType
                            
                            set.addElement(chain)
                            continue
                    }
                }
                ++row
            }
        }
        return set
    }
    
    private func makeBoostingChain() -> Chain {
        var chain = Chain(chainType: .OneType)
        if self.boostable {
            var removeTypeCookie = (lastSwap.cookieA.cookieType == .allcookie) ? lastSwap.cookieB.cookieType : lastSwap.cookieA.cookieType
            var removingCookie = (lastSwap.cookieA.cookieType == .allcookie) ? lastSwap.cookieA : lastSwap.cookieB
            
            chain.addCookie(removingCookie)

            for column in 0..<NumColumns {
                for row in 0..<NumRows {
                    if let cookie = cookies[column, row] {
                        if cookie.cookieType == removeTypeCookie {
                            chain.addCookie(cookie)
                        }
                    }
                }
            }
            self.boostable = false
        }
        return chain
    }
    
    private func detectAllShapedMatches(horizontalMatches: MySet<Chain>, verticalMatches: MySet<Chain>) -> MySet<Chain> {
        var set = MySet<Chain>()
        set = set.unionSet(horizontalMatches)
        set = set.unionSet(verticalMatches)
        for chain in horizontalMatches {
            if chain.length == 3 {
                for vchain in verticalMatches {
                    if vchain.length == 3 && vchain.firstCookie().cookieType == chain.firstCookie().cookieType && (vchain.firstCookie()==chain.firstCookie() || vchain.firstCookie() == chain.lastCookie() || vchain.lastCookie() == chain.firstCookie() || vchain.lastCookie() == chain.lastCookie()) {
                        var newChain = Chain(chainType: .LShape)
                        for cookie in chain.cookies {
                            newChain.addCookie(cookie)
                        }
                        for cookie in vchain.cookies {
                            newChain.addCookie(cookie)
                        }
                        set.addElement(newChain)
                        set.removeElement(vchain)
                        set.removeElement(chain)
                    }
                    else if vchain.length == 3 && vchain.firstCookie().cookieType == chain.firstCookie().cookieType && (vchain.firstCookie() == chain.returnCookie(1) || vchain.lastCookie() == chain.returnCookie(1) || vchain.returnCookie(1) == chain.firstCookie() || vchain.returnCookie(1) == chain.lastCookie()) {
                        var newChain = Chain(chainType: .TShape)
                        for cookie in chain.cookies {
                            newChain.addCookie(cookie)
                        }
                        for cookie in vchain.cookies {
                            newChain.addCookie(cookie)
                        }
                        set.addElement(newChain)
                        set.removeElement(vchain)
                        set.removeElement(chain)
                    }
                }
            } else if chain.length == 4 {
                var newChain = Chain(chainType: .LongHor)
                for cookie in chain.cookies { newChain.addCookie(cookie) }
                set.removeElement(chain)
                set.addElement(newChain)
            } else if chain.length == 5 {
                var newChain = Chain(chainType: .FiveHor)
                for cookie in chain.cookies { newChain.addCookie(cookie) }
                set.removeElement(chain)
                set.addElement(newChain)
            }
        }
        for chain in verticalMatches {
            if chain.length == 4 {
                var newChain = Chain(chainType: .LongVer)
                for cookie in chain.cookies { newChain.addCookie(cookie) }
                set.removeElement(chain)
                set.addElement(newChain)
            } else if chain.length == 5 {
                var newChain = Chain(chainType: .FiveVer)
                for cookie in chain.cookies { newChain.addCookie(cookie) }
                set.removeElement(chain)
                set.addElement(newChain)
            }
        }
        return set
    }
    
    // To remove all the matches from the board
    func removeandReplaceMatches() -> (remove: MySet<Chain>,replace: [Cookie]) {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        
        var allChains = detectAllShapedMatches(horizontalChains, verticalMatches: verticalChains)
        let newChain = makeBoostingChain()
        if newChain.length > 0 {
            allChains.addElement(newChain)
        }
        //removeCookies(horizontalChains)
        //removeCookies(verticalChains)
        var chainCookies = reOrganizeCookies(allChains)
        
        calculateScores(chainCookies.remove)
        
        return (chainCookies.remove,chainCookies.replace)
    }
    
    // Helper method for removing the matches
    private func reOrganizeCookies(chains: MySet<Chain>) -> (remove: MySet<Chain>,replace:[Cookie]){
        var replaceCookies = [Cookie]()
        var newChains = chains
        var finalChains = MySet<Chain>()
        for chain in newChains {
            let length = chain.length
            let oldCookieType = chain.firstCookie().cookieType
            for idx in 0..<length {
                switch chain.returnCookie(idx).cookieType {
                case .CroissantHor, .CupcakeHor, .DonutHor, .DanishHor, .MacaroonHor, .SugarCookieHor:
                    finalChains = finalChains.unionSet(removeCookies("ROW", columnPosition: chain.returnCookie(idx).column, rowPosition: chain.returnCookie(idx).row))
                    break
                case .CroissantVer, .CupcakeVer, .DonutVer, .DanishVer, .MacaroonVer, .SugarCookieVer:
                    finalChains = finalChains.unionSet(removeCookies("COLUMN", columnPosition: chain.returnCookie(idx).column, rowPosition: chain.returnCookie(idx).row))
                    break
                case .CroissantBomb, .CupcakeBomb, .DonutBomb, .DanishBomb, .MacaroonBomb, .SugarCookieBomb:
                    finalChains = finalChains.unionSet(removeCookies("BOMB", columnPosition: chain.returnCookie(idx).column, rowPosition: chain.returnCookie(idx).row))
                default:
                    break
                }
            }
            for idx in 0..<length - 1 {
                if (cookies[chain.returnCookie(idx).column, chain.returnCookie(idx).row] != nil) {
                    cookies[chain.returnCookie(idx).column, chain.returnCookie(idx).row] = nil
                }
            }
            let newRow = chain.returnCookie(length-1).row
            let newColumn = chain.returnCookie(length-1).column
            chain.removeLastCookie()
            if cookies[newColumn,newRow] != nil {
                switch chain.chainType {
                case .LongVer:
                cookies[newColumn,newRow]?.changeCookieType(CookieType.returnGiftedVersion(oldCookieType,giftType: "VERTICAL"))
                    replaceCookies.append(cookies[newColumn, newRow]!)
                    break
                case .LongHor:
                cookies[newColumn,newRow]?.changeCookieType(CookieType.returnGiftedVersion(oldCookieType, giftType: "HORIZONTAL"))
                    replaceCookies.append(cookies[newColumn, newRow]!)
                    break
                case .LShape,.TShape:
                cookies[newColumn,newRow]?.changeCookieType(CookieType.returnGiftedVersion(oldCookieType, giftType: "BOMB"))
                    replaceCookies.append(cookies[newColumn, newRow]!)
                    break
                case .FiveHor, .FiveVer:
                    cookies[newColumn,newRow]?.changeCookieType(CookieType(rawValue: 25)!)
                    replaceCookies.append(cookies[newColumn, newRow]!)
                    break
                default:
                    if cookies[newColumn,newRow] != nil {
                        chain.addCookie(cookies[newColumn,newRow]!)
                        cookies[newColumn, newRow] = nil
                    }
                }
            }
        }
        finalChains = finalChains.unionSet(newChains)
        return (finalChains,replaceCookies)
    }
//    
//    private func findAllCookiesForRomoval(chains:MySet<Chain>) -> MySet<Chain> {
//        let newChains =
//    }
    
    // Filling the holes after a successful movement
    func fillHoles() -> [[Cookie]] {
        var columns = [[Cookie]]()
        // 1
        for column in 0..<NumColumns {
            var array = [Cookie]()
            for row in 0..<NumRows {
                // 2
                if tiles[column, row] != nil && cookies[column, row] == nil {
                    // 3
                    for lookup in (row + 1)..<NumRows {
                        if let cookie = cookies[column, lookup] {
                            // 4
                            cookies[column, lookup] = nil
                            cookies[column, row] = cookie
                            cookie.row = row
                            // 5
                            array.append(cookie)
                            // 6
                            break
                        }
                    }
                }
            }
            // 7
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    // To fill the top
    func topUpCookies() -> [[Cookie]] {
        var columns = [[Cookie]]()
        var cookieType: CookieType = .Unknown
        
        for column in 0..<NumColumns {
            var array = [Cookie]()
            // 1
            for var row = NumRows - 1; row >= 0 && cookies[column, row] == nil; --row {
                // 2
                if tiles[column, row] != nil {
                    // 3
                    var newCookieType: CookieType
                    do {
                        newCookieType = CookieType.random()
                    } while newCookieType == cookieType
                    cookieType = newCookieType
                    // 4
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                    array.append(cookie)
                }
            }
            //
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    // To calculate the score of the chain
    private func calculateScores(chains: MySet<Chain>) {
        // 3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on
        for chain in chains {
            switch chain.chainType {
            case .Horizontal, .Vertical:
                chain.score = 60 * comboMultiplier // To calculate the combos score
                ++comboMultiplier
                break
            case .LShape:
                chain.score = 150 * comboMultiplier
                ++comboMultiplier
                break
            case .TShape:
                chain.score = 140 * comboMultiplier
                ++comboMultiplier
                break
            case .LongHor, .LongVer:
                chain.score = 130 * comboMultiplier
                ++comboMultiplier
                break
            case .FiveHor, .FiveVer:
                chain.score = 170 * comboMultiplier
                ++comboMultiplier
                break
            case .OneColumn, .OneRow:
                chain.score = 200 * comboMultiplier
                ++comboMultiplier
                break
            case .OneRing:
                chain.score = 180 * comboMultiplier
                ++comboMultiplier
                break
            case .OneType:
                chain.score = chain.length * 50 * comboMultiplier
                ++comboMultiplier
                break
            default:
                break
            }
        }
    }
    
    func resetComboMultiplier() {
        comboMultiplier = 1
    }
    
    
    // working on boosts
    /*func resetBursts() {
        for i in 0..<NumColumns {
            for j in 0..<NumRows {
                cookies[i,j]?.bursted = false
            }
        }
    }*/
    
    
    // Helper function to remove cookies
    func removeCookies(toRemove: String, columnPosition: Int, rowPosition: Int) -> MySet<Chain> {
        var toBeRemoved = MySet<Chain>()
        if toRemove == "ROW" {
            var rowChain = Chain(chainType: .OneRow)
            for idx in 0..<NumColumns {
                if (cookies[idx, rowPosition] != nil) {
                    switch cookies[idx, rowPosition]!.cookieType {
                    case .SugarCookie,
                    .Croissant,
                    .Cupcake,
                    .Danish,
                    .Donut,
                    .Macaroon,
                    .CroissantHor,
                    .CupcakeHor,
                    .DonutHor,
                    .DanishHor,
                    .MacaroonHor,
                    .SugarCookieHor:
                        rowChain.addCookie(cookies[idx, rowPosition]!)
                        cookies[idx, rowPosition] = nil
                        break
                    case .CroissantVer, .CupcakeVer, .DonutVer, .DanishVer, .MacaroonVer, .SugarCookieVer:
                        toBeRemoved = toBeRemoved.unionSet(removeCookies("COLUMN", columnPosition: idx, rowPosition: rowPosition))
                        break
                    case .CroissantBomb, .CupcakeBomb, .DonutBomb, .DanishBomb, .MacaroonBomb, .SugarCookieBomb:
                        toBeRemoved = toBeRemoved.unionSet(removeCookies("BOMB", columnPosition: idx, rowPosition: rowPosition))
                        break
                    default:
                        print("the type is not")
                        break
                    }
                }
            }
            toBeRemoved.addElement(rowChain)
        }
        else if toRemove == "COLUMN" {
            var columnChain = Chain(chainType: .OneColumn)
            for idx in 0..<NumRows {
                if (cookies[columnPosition, idx] != nil) {
                    switch cookies[columnPosition, idx]!.cookieType {
                    case .SugarCookie,
                    .Croissant,
                    .Cupcake,
                    .Danish,
                    .Donut,
                    .Macaroon,
                    .CroissantVer,
                    .CupcakeVer,
                    .DonutVer,
                    .DanishVer,
                    .MacaroonVer,
                    .SugarCookieVer:
                        columnChain.addCookie(cookies[columnPosition, idx]!)
                        cookies[columnPosition, idx] = nil
                        break
                    case .CroissantHor, .CupcakeHor, .DonutHor, .DanishHor, .MacaroonHor, .SugarCookieHor:
                        toBeRemoved = toBeRemoved.unionSet(removeCookies("ROW", columnPosition: columnPosition, rowPosition: idx))
                        break
                    case .CroissantBomb, .CupcakeBomb, .DonutBomb, .DanishBomb, .MacaroonBomb, .SugarCookieBomb:
                        toBeRemoved = toBeRemoved.unionSet(removeCookies("BOMB", columnPosition: columnPosition, rowPosition: idx))
                        break
                    default:
                        print("the type is not")
                        break
                        
                    }
                }
            }
            toBeRemoved.addElement(columnChain)
        }
        else if toRemove == "BOMB" {
            var ringChain = Chain(chainType: .OneRing)
            for jdx in rowPosition-1...rowPosition+1 {
                for idx in columnPosition-1...columnPosition+1 {
                    if ((idx <= 8 && idx >= 0) && (jdx <= 8 && jdx >= 0) && (cookies[idx,jdx] != nil)) {
                        if (idx == columnPosition && jdx == rowPosition) {
                            ringChain.addCookie(cookies[idx,jdx]!)
                            cookies[idx,jdx] = nil
                            continue
                        }
                        switch cookies[idx,jdx]!.cookieType {
                        case .SugarCookie,
                        .Croissant,
                        .Cupcake,
                        .Danish,
                        .Donut,
                        .Macaroon:
                            ringChain.addCookie(cookies[idx,jdx]!)
                            cookies[idx,jdx] = nil
                            break
                        case .CroissantVer, .CupcakeVer, .DonutVer, .DanishVer, .MacaroonVer, .SugarCookieVer:
                            toBeRemoved = toBeRemoved.unionSet(removeCookies("COLUMN", columnPosition: idx, rowPosition: jdx))
                            break
                        case .CroissantHor, .CupcakeHor, .DonutHor, .DanishHor, .MacaroonHor, .SugarCookieHor:
                            toBeRemoved = toBeRemoved.unionSet(removeCookies("ROW", columnPosition: idx, rowPosition: jdx))
                            break
                        case .CroissantBomb, .CupcakeBomb, .DonutBomb, .DanishBomb, .MacaroonBomb, .SugarCookieBomb:
                            toBeRemoved = toBeRemoved.unionSet(removeCookies("BOMB", columnPosition: idx, rowPosition: jdx))
                            break
                        default:
                            print("the type is not")
                            break
                        }
                    }
                }
            }
            toBeRemoved.addElement(ringChain)
        }
        return toBeRemoved
    }
    
    
    //Helper function
    func cookiesAroundThisCookie(column: Int, row: Int) -> [Cookie] {
        var ringCookies = [Cookie]()
        for idx in column-1...column+1 {
            for jdx in row-1...row+1 {
                if ((idx <= NumColumns && idx >= 0) && (jdx <= NumRows && jdx >= 0) && (cookies[idx,jdx] != nil) && !(idx == column && jdx == row)) {
                    ringCookies.append(cookies[idx,jdx]!)
                }
            }
        }
        return ringCookies
    }
    

}
