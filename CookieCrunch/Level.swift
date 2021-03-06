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
                var newChain = Chain(chainType: .LongHori)
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
    func removeMatches() -> MySet<Chain> {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        
        let allChains = detectAllShapedMatches(horizontalChains, verticalMatches: verticalChains)
        //removeCookies(horizontalChains)
        //removeCookies(verticalChains)
        removeCookies(allChains)
        
        calculateScores(allChains)
        
        return allChains
    }
    
    // Helper method for removing the matches
    private func removeCookies(chains: MySet<Chain>) {
        for chain in chains {
            for cookie in chain.cookies {
                cookies[cookie.column, cookie.row] = nil
            }
        }
    }
    
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
            if chain.chainType == .Horizontal || chain.chainType == .Vertical {
                chain.score = 60 * (chain.length - 2) * comboMultiplier // To calculate the combos score
                ++comboMultiplier
            } else if chain.chainType == .LShape {
                chain.score = 150 * comboMultiplier
                ++comboMultiplier
            } else if chain.chainType == .TShape {
                chain.score = 140 * comboMultiplier
                ++comboMultiplier
            } else if chain.chainType == .LongHori || chain.chainType == .LongVer {
                chain.score = 130 * comboMultiplier
                ++comboMultiplier
            } else if chain.chainType == .FiveHor || chain.chainType == .FiveVer {
                chain.score = 170 * comboMultiplier
                ++comboMultiplier
            }
        }
    }
    
    func resetComboMultiplier() {
        comboMultiplier = 1
    }

}
