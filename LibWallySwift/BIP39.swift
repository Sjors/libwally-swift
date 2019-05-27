//
//  BIP39.swift
//  LibWally
//
//  Created by Sjors on 27/05/2019.
//  Copyright © 2019 Blockchain. All rights reserved.
//

import Foundation

typealias BIP39Word = String

struct BIP39Mnemonic {
    let words: [BIP39Word]
    
    init(words: [BIP39Word]) {
        self.words = words
    }
    
}

struct BIP39WordList {
    static var all: [BIP39Word] {
        let filler = Array(repeating: "", count: 2046)
        let words = ["abandon", "ability"]
        return words + filler
    }
}
