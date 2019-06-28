//
//  ScriptTests.swift
//  ScriptTests 
//
//  Created by Sjors on 14/06/2019.
//  Copyright © 2019 Blockchain. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import XCTest
@testable import LibWally
import CLibWally

class ScriptTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDetectScriptPubKeyTypeP2PKH() {
        var scriptPubKey = ScriptPubKey("76a914bef5a2f9a56a94aab12459f72ad9cf8cf19c7bbe88ac")!
        XCTAssertEqual(scriptPubKey.type, .payToPubKeyHash)
    }
    
    func testDetectScriptPubKeyTypeP2SH() {
        var scriptPubKey = ScriptPubKey("a91486cc442a97817c245ce90ed0d31d6dbcde3841f987")!
        XCTAssertEqual(scriptPubKey.type, .payToScriptHash)
    }
    
    func testDetectScriptPubKeyTypeNativeSegWit() {
        var scriptPubKey = ScriptPubKey("0014bef5a2f9a56a94aab12459f72ad9cf8cf19c7bbe")!
        XCTAssertEqual(scriptPubKey.type, .payToWitnessPubKeyHash)
    }
    
    func testDetectScriptPubKeyTypeOpReturn() {
        var scriptPubKey = ScriptPubKey("6a13636861726c6579206c6f766573206865696469")!
        XCTAssertEqual(scriptPubKey.type, .opReturn)
    }
    
    func testScriptSigP2PKH() {
        let pubKey = PubKey("03501e454bf00751f24b1b489aa925215d66af2234e3891c3b21a52bedb3cd711c")!
        var scriptSig = ScriptSig(.payToPubKeyHash(pubKey))
        XCTAssertEqual(scriptSig.type, ScriptSigType.payToPubKeyHash(pubKey))
        XCTAssertEqual(scriptSig.render(.signed), nil)

        XCTAssertEqual(scriptSig.signature, nil)
        
        XCTAssertEqual(scriptSig.render(.feeWorstCase)?.count, 2 + Int(EC_SIGNATURE_DER_MAX_LOW_R_LEN) + 1 + pubKey.count)
        
        scriptSig.signature = Signature("01")!
        let sigHashByte = Data("01")! // SIGHASH_ALL
        let signaturePush = Data("02")! + scriptSig.signature! + sigHashByte
        let pubKeyPush = Data([UInt8(pubKey.count)]) + pubKey
        XCTAssertEqual(scriptSig.render(.signed)?.hexString, (signaturePush + pubKeyPush).hexString)
    }

    func testWitnessP2WPKH() {
        let pubKey = PubKey("03501e454bf00751f24b1b489aa925215d66af2234e3891c3b21a52bedb3cd711c")!
        let witness = Witness(.payToWitnessPubKeyHash(pubKey))
        XCTAssertEqual(witness.dummy, true)
        XCTAssertEqual(witness.stack?.pointee.num_items, 2)
        XCTAssertEqual(witness.scriptCode.hexString, "76a914bef5a2f9a56a94aab12459f72ad9cf8cf19c7bbe88ac")
        let signedWitness = Witness(.payToWitnessPubKeyHash(pubKey), Signature("01")!)
        XCTAssertEqual(signedWitness.stack?.pointee.num_items, 2)
        
    }
}
