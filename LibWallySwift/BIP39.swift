//
//  BIP39.swift
//  LibWally
//
//  Created by Sjors on 27/05/2019.
//  Copyright © 2019 Blockchain. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md.
//

import Foundation

public var BIP39Words: [String] = {
    // Implementation based on Blockstream Green Development Kit
    var words: [String] = []
    var WL: OpaquePointer?
    precondition(bip39_get_wordlist(nil, &WL) == WALLY_OK)
    for i in 0..<BIP39_WORDLIST_LEN {
        var word: UnsafeMutablePointer<Int8>?
        defer {
            wally_free_string(word)
        }
        precondition(bip39_get_word(WL, Int(i), &word) == WALLY_OK)
        words.append(String(cString: word!))
    }
    return words
}()

public struct BIP39Seed : LosslessStringConvertible, Equatable {
    var data: Data
    
    public init?(_ description: String) {
        if let data = Data(description) {
            self.data = data
        } else {
            return nil
        }
    }
    
    init(_ data: Data) {
        self.data = data
    }
    
    public var description: String { return data.hexString }
}

public struct BIP39Mnemonic : LosslessStringConvertible {
    public let words: [String]
    public var description: String { return words.joined(separator: " ") }

    public init?(_ words: [String]) {
        if (!BIP39Mnemonic.isValid(words)) { return nil }
        self.words = words
    }
    
    public init?(_ words: String) {
        self.init(words.components(separatedBy: " "))
    }
    
    public func seedHex(_ passphrase: String? = nil) -> BIP39Seed {
        let mnemonic = words.joined(separator: " ")
        
        var bytes_out = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(BIP39_SEED_LEN_512))
        var written = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        defer {
            bytes_out.deallocate()
            written.deallocate()
        }
        precondition(bip39_mnemonic_to_seed(mnemonic, passphrase, bytes_out, Int(BIP39_SEED_LEN_512), written) == WALLY_OK)
        return BIP39Seed(Data(bytes: bytes_out, count: written.pointee))
    }

    static func isValid(_ words: [String]) -> Bool {
        // Check that each word appears in the BIP39 dictionary:
        if (!Set(words).subtracting(Set(BIP39Words)).isEmpty) {
            return false
        }
        let mnemonic = words.joined(separator: " ")
        return bip39_mnemonic_validate(nil, mnemonic) == WALLY_OK
    }
    
    static func isValid(_ words: String) -> Bool {
        return self.isValid(words.components(separatedBy: " "))
    }

}
