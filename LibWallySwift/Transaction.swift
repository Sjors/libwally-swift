//
//  Transaction.swift
//  Transaction
//
//  Created by Sjors Provoost on 18/06/2019.
//  Copyright © 2019 Blockchain. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation

typealias Satoshi = UInt64

struct TxOutput {
    let wally_tx_output: wally_tx_output
    public var amount: Satoshi {
        return self.wally_tx_output.satoshi
    }
    public let scriptPubKey: ScriptPubKey

    init (_ scriptPubKey: ScriptPubKey, _ amount: Satoshi) {
        self.scriptPubKey = scriptPubKey

        var scriptpubkey_bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: scriptPubKey.bytes.count)
        let scriptpubkey_bytes_len = scriptPubKey.bytes.count

        scriptPubKey.bytes.copyBytes(to: scriptpubkey_bytes, count: scriptpubkey_bytes_len)

        var output: UnsafeMutablePointer<wally_tx_output>?
        defer {
            if let wally_tx_output = output {
                wally_tx_output.deallocate()
            }
        }
        precondition(wally_tx_output_init_alloc(amount, scriptpubkey_bytes, scriptpubkey_bytes_len, &output) == WALLY_OK)
        precondition(output != nil)
        self.wally_tx_output = output!.pointee
    }
}

struct Transaction {
    let hash: Data

    init? (_ description: String) {
        if description.count == 64 { // Transaction hash
            if let hash = Data(description) {
                self.hash = hash
            } else {
                return nil
            }
        } else { // Transaction hex
            return nil
        }

    }

}
