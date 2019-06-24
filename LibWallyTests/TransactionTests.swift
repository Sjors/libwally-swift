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
        let scriptSig = ScriptSig(.payToPubKeyHash(pubKey))

        let input = TxInput(tx, vout, scriptSig, scriptPubKey)
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
        let scriptSig = ScriptSig(.payToPubKeyHash(pubKey))
        let txInput = TxInput(prevTx, vout, scriptSig, scriptPubKey)!

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
    // From: legacy P2PKH address 1JQheacLPdM5ySCkrZkV66G2ApAXe1mqLj
    // To: legacy P2PKH address 1JQheacLPdM5ySCkrZkV66G2ApAXe1mqLj
    let scriptPubKey = ScriptPubKey("76a914bef5a2f9a56a94aab12459f72ad9cf8cf19c7bbe88ac")!
    let pubKey = PubKey("03501e454bf00751f24b1b489aa925215d66af2234e3891c3b21a52bedb3cd711c")!
    var tx: Transaction? = nil
    var hdKey: HDKey? = nil // private key for signing
    
    override func setUp() {
        // Input (legacy P2PKH)
        let prevTx = Transaction("0000000000000000000000000000000000000000000000000000000000000000")!
        let vout = UInt32(0)
        let scriptSig = ScriptSig(.payToPubKeyHash(pubKey))
        let txInput = TxInput(prevTx, vout, scriptSig, scriptPubKey)!
        
        // Output:
        let txOutput = TxOutput(scriptPubKey, 1000)
        
        // Transaction
        tx = Transaction([txInput], [txOutput])
        
        // Corresponding private key
       hdKey = HDKey("xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs")!
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
        XCTAssertEqual(tx?.vbytes, 192)
        
        let tx2 = Transaction("0000000000000000000000000000000000000000000000000000000000000000")
        XCTAssertNil(tx2?.vbytes)
        
    }
    
    func testSign() {
        XCTAssertTrue(tx!.sign([hdKey!]))
        XCTAssertEqual(tx!.inputs?[0].signed, true)
        XCTAssertEqual(tx!.inputs?[0].scriptSig.signature?.hexString, "304402203d274300310c06582d0186fc197106120c4838fa5d686fe3aa0478033c35b97802205379758b11b869ede2f5ab13a738493a93571268d66b2a875ae148625bd20578")
        XCTAssertEqual(tx!.description, "01000000010000000000000000000000000000000000000000000000000000000000000000000000006a47304402203d274300310c06582d0186fc197106120c4838fa5d686fe3aa0478033c35b97802205379758b11b869ede2f5ab13a738493a93571268d66b2a875ae148625bd20578012103501e454bf00751f24b1b489aa925215d66af2234e3891c3b21a52bedb3cd711cffffffff01e8030000000000001976a914bef5a2f9a56a94aab12459f72ad9cf8cf19c7bbe88ac00000000")
    }

}
