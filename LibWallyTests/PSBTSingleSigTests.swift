//
//  PSBTSingleSigTests.swift
//  PSBTSingleSigTests 
//
//  Created by Peter on 22/02/20.
//  Copyright © 2020 Blockchain. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import XCTest
@testable import LibWally
import CLibWally

class PSBTSingleSigTests: XCTestCase {
    
    let unsignedSingleSigPSBT = "cHNidP8BAH0CAAAAAaUzN3xZkB2YfVHxZSCjCgexuCQnaG8N80n/cpFVWfDyAAAAAAD9////AhAnAAAAAAAAIgAg49yAFHlKIAYs3rNfW2vA4ZOIOHtW7TrY9YdfftTjBKL3XgEAAAAAABYAFFb1p5mofMojooI4wLWIHhWFZ4E5AAAAAAABAR+ghgEAAAAAABYAFDbuJQf0taOE3ENY73ebWvMzH0C3IgYDbQqzxNNep6EipUEGuAQAYxDlRYw+TKCWlnGeImPa7SkInBWHlwEAAAAAACICAj19pZvok8gSY0WCPsDhP9HXu0pi3Z7MzI9l0W/10xx4CJwVh5foAwAAAA=="
    
    let masterTprv = "tprv8hoZj3z3ZLHgcxdZpsQ5ptmdacZYqpJCCqqAVBBrP7J24GDGC3bYRZeRnM9WLLpKrtTMULQE1fftYH4UhAKtXFQSVXY6dMMXbSuQJjoBUmY"
    
    let wifToSign = "cNjKJq38o16bji8UZ4yTaZMXpn6sWPhquPDSJSPCAEGuLbHpovfh" // m/1
    
    func testSignWithKey() {
        let privKey1 = Key(wifToSign, .testnet)
        var psbt1 = try! PSBT(unsignedSingleSigPSBT, .testnet)
        psbt1.sign(privKey1!)
        XCTAssertTrue(psbt1.finalize())
        XCTAssertTrue(psbt1.complete)
    }
    
}
