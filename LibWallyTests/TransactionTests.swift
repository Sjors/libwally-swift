//
//  TransactionTests.swift
//  TransactionTests
//
//  Created by Sjors Provoost on 18/06/2019.
//  Copyright © 2019 Blockchain. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import XCTest
@testable import LibWally

class TransactionTests: XCTestCase {
    let scriptPubKey = ScriptPubKey("76a914bef5a2f9a56a94aab12459f72ad9cf8cf19c7bbe88ac")!
    let pubKey = PubKey("03501e454bf00751f24b1b489aa925215d66af2234e3891c3b21a52bedb3cd711c")!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFromHash() {
        let hash = ("0000000000000000000000000000000000000000000000000000000000000000")
        let tx = Transaction(hash)
        XCTAssertNotNil(tx)
        XCTAssertEqual(tx?.hash?.hexString, hash)

        XCTAssertNil(Transaction("00")) // Wrong length
    }

    func testOutput() {
        let output = TxOutput(scriptPubKey, 1000)
        XCTAssertNotNil(output)
        XCTAssertEqual(output.amount, 1000)
        XCTAssertEqual(output.scriptPubKey, scriptPubKey)
    }

    func testInput() {
        let tx = Transaction("0000000000000000000000000000000000000000000000000000000000000000")!
        let vout = UInt32(0)
        let scriptSig = ScriptSig(.payToPubKeyHash(pubKey), scriptPubKey)

        let input = TxInput(tx, vout, scriptSig)
        XCTAssertNotNil(input)
        XCTAssertEqual(input?.transaction.hash, tx.hash)
        XCTAssertEqual(input?.vout, 0)
        XCTAssertEqual(input?.sequence, 0xFFFFFFFF)
        XCTAssertEqual(input?.scriptSig, scriptSig)
        XCTAssertEqual(input?.witness, nil)
        XCTAssertEqual(input?.signed, false)
    }

    func testComposeTransaction() {
        // Input
        let prevTx = Transaction("0000000000000000000000000000000000000000000000000000000000000000")!
        let vout = UInt32(0)
        let scriptSig = ScriptSig(.payToPubKeyHash(pubKey), scriptPubKey)
        let txInput = TxInput(prevTx, vout, scriptSig)!

        // Output:
        let txOutput = TxOutput(scriptPubKey, 1000)

        // Transaction
        let tx = Transaction([txInput], [txOutput])
        XCTAssertNil(tx.hash)
        XCTAssertEqual(tx.wally_tx?.pointee.version, 1)
        XCTAssertEqual(tx.wally_tx?.pointee.num_inputs, 1)
        XCTAssertEqual(tx.wally_tx?.pointee.num_outputs, 1)
    }
    
}

class TransactionInstanceTests: XCTestCase {
    // Pay to legacy P2PKH address
    let scriptPubKey = ScriptPubKey("76a914bef5a2f9a56a94aab12459f72ad9cf8cf19c7bbe88ac")!
    let pubKey = PubKey("03501e454bf00751f24b1b489aa925215d66af2234e3891c3b21a52bedb3cd711c")!
    var tx: Transaction? = nil
    
    override func setUp() {
        // Input (legacy P2PKH)
        let prevTx = Transaction("0000000000000000000000000000000000000000000000000000000000000000")!
        let vout = UInt32(0)
        let scriptSig = ScriptSig(.payToPubKeyHash(pubKey), scriptPubKey)
        let txInput = TxInput(prevTx, vout, scriptSig)!
        
        // Output:
        let txOutput = TxOutput(scriptPubKey, 1000)
        
        // Transaction
        tx = Transaction([txInput], [txOutput])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTotalOut() {
        XCTAssertEqual(tx?.totalOut, 1000)
        
        let tx2 = Transaction("0000000000000000000000000000000000000000000000000000000000000000")
        XCTAssertNil(tx2?.totalOut)

    }
    
    func testSize() {
        XCTAssertEqual(tx?.vbytes, 183)
        
        let tx2 = Transaction("0000000000000000000000000000000000000000000000000000000000000000")
        XCTAssertNil(tx2?.vbytes)
        
    }

}
