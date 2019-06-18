//
//  TransactionTests.swift
//  TransactionTests
//
//  Created by Sjors Provoost on 18/06/2019.
//  Copyright © 2019 Blockchain. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import XCTest
@testable import LibWally

class TransctionTests: XCTestCase {

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
        XCTAssertEqual(tx?.hash.hexString, hash)

        XCTAssertNil(Transaction("00")) // Wrong length
    }

    func testOutput() {
        let scriptPubKey = ScriptPubKey("76a914bef5a2f9a56a94aab12459f72ad9cf8cf19c7bbe88ac")!
        let output = TxOutput(scriptPubKey, 1000)
        XCTAssertNotNil(output)
        XCTAssertEqual(output.amount, 1000)
        XCTAssertEqual(output.scriptPubKey, scriptPubKey)
    }

    func testInput() {
        let tx = Transaction("0000000000000000000000000000000000000000000000000000000000000000")!
        let vout = UInt32(0)
        let pubKey = PubKey("03501e454bf00751f24b1b489aa925215d66af2234e3891c3b21a52bedb3cd711c")!
        let scriptPubKey = ScriptPubKey("76a914bef5a2f9a56a94aab12459f72ad9cf8cf19c7bbe88ac")!
        let scriptSig = ScriptSig(.payToPubKeyHash(pubKey), scriptPubKey)

        let input = TxInput(tx, vout, scriptSig)
        XCTAssertNotNil(input)
        XCTAssertEqual(input.transaction.hash, tx.hash)
        XCTAssertEqual(input.vout, 0)
        XCTAssertEqual(input.sequence, 0)
        XCTAssertEqual(input.scriptSig, scriptSig)
        XCTAssertEqual(input.witness, nil)
        XCTAssertEqual(input.signed, false)
    }

}
