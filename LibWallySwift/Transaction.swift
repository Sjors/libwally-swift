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

struct TxInput {
    let wally_tx_input: wally_tx_input
    let transaction: Transaction
    public var vout: UInt32 {
        return self.wally_tx_input.index
    }
    public var sequence: UInt32 {
        return self.wally_tx_input.sequence
    }
    public var scriptSig: ScriptSig

    public var witness: Data? {
        // TODO: obtain from wally_tx_input.witness
        return nil
    }

    init? (_ tx: Transaction, _ vout: UInt32, _ scriptSig: ScriptSig) {
        if tx.hash == nil {
            return nil
        }

        // We initialize self.wally_tx_input with an empty scriptSig, which is what's used when signing
        // for other inputs. We update it from self.scriptSig as needed during the signing process.
        self.scriptSig = scriptSig

        let sequence: UInt32 = 0

        var tx_hash_bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: tx.hash!.count)
        let tx_hash_bytes_len = tx.hash!.count

        tx.hash!.copyBytes(to: tx_hash_bytes, count: tx_hash_bytes_len)

        var output: UnsafeMutablePointer<wally_tx_input>?
        defer {
            if let wally_tx_input = output {
                wally_tx_input.deallocate()
            }
        }
        precondition(wally_tx_input_init_alloc(tx_hash_bytes, tx_hash_bytes_len, vout, sequence, nil, 0, nil, &output) == WALLY_OK)
        precondition(output != nil)
        self.wally_tx_input = output!.pointee

        self.transaction = tx
    }

    public var signed: Bool {
        return self.scriptSig.signature != nil
    }
}

struct Transaction {
    var hash: Data? = nil
    
    var wally_tx: UnsafeMutablePointer<wally_tx>?
    
    var inputs: [TxInput]? = nil
    var outputs: [TxOutput]? = nil

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
    
    init (_ inputs: [TxInput], _ outputs: [TxOutput]) {
        self.inputs = inputs
        self.outputs = outputs
        
        let version: UInt32 = 1
        let lockTime: UInt32 = 0
        
        precondition(wally_tx_init_alloc(version, lockTime, inputs.count, outputs.count, &self.wally_tx) == WALLY_OK)
        precondition(self.wally_tx != nil)
        
        for input in inputs {
            self.addInput(input)
        }
        
        for output in outputs {
            self.addOutput(output)
        }
    }
    
    mutating func addInput (_ input: TxInput) {
        let tx_input = UnsafeMutablePointer<wally_tx_input>.allocate(capacity: 1)
        defer {
            tx_input.deallocate()
        }
        tx_input.pointee = input.wally_tx_input

        precondition(wally_tx_add_input(self.wally_tx, tx_input) == WALLY_OK)
    }
    
    mutating func addOutput (_ output: TxOutput) {
        let tx_output = UnsafeMutablePointer<wally_tx_output>.allocate(capacity: 1)
        defer {
            tx_output.deallocate()
        }
        tx_output.pointee = output.wally_tx_output
        
        precondition(wally_tx_add_output(self.wally_tx, tx_output) == WALLY_OK)
    }
    }

}
