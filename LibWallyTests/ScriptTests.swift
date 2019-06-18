//
//  ScriptTests.swift
//  ScriptTests 
//
//  Created by Sjors on 14/06/2019.
//  Copyright © 2019 Blockchain. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import XCTest
@testable import LibWally

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
        let scriptPubKey = ScriptPubKey("76a914bef5a2f9a56a94aab12459f72ad9cf8cf19c7bbe88ac")!
        var scriptSig = ScriptSig(.payToPubKeyHash(pubKey), scriptPubKey)
        XCTAssertEqual(scriptSig.pubKey, pubKey)
        XCTAssertEqual(scriptSig.scriptPubKey, scriptPubKey)
        XCTAssertEqual(scriptSig.render(.signOtherInput), Data(""))
        XCTAssertEqual(scriptSig.render(.signThisInput), scriptPubKey.bytes)
        XCTAssertEqual(scriptSig.render(.signed), nil)

        XCTAssertEqual(scriptSig.signature, nil)
        scriptSig.signature = Signature("01")!
        let signaturePush = Data("01")! + scriptSig.signature!
        XCTAssertEqual(scriptSig.render(.signed), signaturePush + scriptPubKey.bytes)
    }

}
