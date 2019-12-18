//
//  PSBTTests.swift
//  PSBTTests 
//
//  Created by Sjors Provoost on 16/12/2019.
//  Copyright © 2019 Sjors Provoost. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import XCTest
@testable import LibWally
import CLibWally

class PSBTTests: XCTestCase {
    // Test vectors from https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
    let fingerprint = Data("d90c6a4f")!
    
    let validPSBT = "cHNidP8BAHUCAAAAASaBcTce3/KF6Tet7qSze3gADAVmy7OtZGQXE8pCFxv2AAAAAAD+////AtPf9QUAAAAAGXapFNDFmQPFusKGh2DpD9UhpGZap2UgiKwA4fUFAAAAABepFDVF5uM7gyxHBQ8k0+65PJwDlIvHh7MuEwAAAQD9pQEBAAAAAAECiaPHHqtNIOA3G7ukzGmPopXJRjr6Ljl/hTPMti+VZ+UBAAAAFxYAFL4Y0VKpsBIDna89p95PUzSe7LmF/////4b4qkOnHf8USIk6UwpyN+9rRgi7st0tAXHmOuxqSJC0AQAAABcWABT+Pp7xp0XpdNkCxDVZQ6vLNL1TU/////8CAMLrCwAAAAAZdqkUhc/xCX/Z4Ai7NK9wnGIZeziXikiIrHL++E4sAAAAF6kUM5cluiHv1irHU6m80GfWx6ajnQWHAkcwRAIgJxK+IuAnDzlPVoMR3HyppolwuAJf3TskAinwf4pfOiQCIAGLONfc0xTnNMkna9b7QPZzMlvEuqFEyADS8vAtsnZcASED0uFWdJQbrUqZY3LLh+GFbTZSYG2YVi/jnF6efkE/IQUCSDBFAiEA0SuFLYXc2WHS9fSrZgZU327tzHlMDDPOXMMJ/7X85Y0CIGczio4OFyXBl/saiK9Z9R5E5CVbIBZ8hoQDHAXR8lkqASECI7cr7vCWXRC+B3jv7NYfysb3mk6haTkzgHNEZPhPKrMAAAAAAAAA"
    
    let finalizedPSBT = "cHNidP8BAJoCAAAAAljoeiG1ba8MI76OcHBFbDNvfLqlyHV5JPVFiHuyq911AAAAAAD/////g40EJ9DsZQpoqka7CwmK6kQiwHGyyng1Kgd5WdB86h0BAAAAAP////8CcKrwCAAAAAAWABTYXCtx0AYLCcmIauuBXlCZHdoSTQDh9QUAAAAAFgAUAK6pouXw+HaliN9VRuh0LR2HAI8AAAAAAAEAuwIAAAABqtc5MQGL0l+ErkALaISL4J23BurCrBgpi6vucatlb4sAAAAASEcwRAIgWPb8fGoz4bMVSNSByCbAFb0wE1qtQs1neQ2rZtKtJDsCIEoc7SYExnNbY5PltBaR3XiwDwxZQvufdRhW+qk4FX26Af7///8CgPD6AgAAAAAXqRQPuUY0IWlrgsgzryQceMF9295JNIfQ8gonAQAAABepFCnKdPigj4GZlCgYXJe12FLkBj9hh2UAAAABB9oARzBEAiB0AYrUGACXuHMyPAAVcgs2hMyBI4kQSOfbzZtVrWecmQIgc9Npt0Dj61Pc76M4I8gHBRTKVafdlUTxV8FnkTJhEYwBSDBFAiEA9hA4swjcHahlo0hSdG8BV3KTQgjG0kRUOTzZm98iF3cCIAVuZ1pnWm0KArhbFOXikHTYolqbV2C+ooFvZhkQoAbqAUdSIQKVg785rgpgl0etGZrd1jT6YQhVnWxc05tMIYPxq5bgfyEC2rYf9JoU22p9ArDNH7t4/EsYMStbTlTa5Nui+/71NtdSrgABASAAwusLAAAAABepFLf1+vQOPUClpFmx2zU18rcvqSHohwEHIyIAIIwjUxc3Q7WV37Sge3K6jkLjeX2nTof+fZ10l+OyAokDAQjaBABHMEQCIGLrelVhB6fHP0WsSrWh3d9vcHX7EnWWmn84Pv/3hLyyAiAMBdu3Rw2/LwhVfdNWxzJcHtMJE+mWzThAlF2xIijaXwFHMEQCIGX0W6WZi1mif/4ae+0BavHx+Q1Us6qPdFCqX1aiUQO9AiB/ckcDrR7blmgLKEtW1P/LiPf7dZ6rvgiqMPKbhROD0gFHUiEDCJ3BDHrG21T5EymvYXMz2ziM6tDCMfcjN50bmQMLAtwhAjrdkE89bc9Z3bkGsN7iNSm3/7ntUOXoYVGSaGAiHw5zUq4AIgIDqaTDf1mW06ol26xrVwrwZQOUSSlCRgs1R1Ptnuylh3EQ2QxqTwAAAIAAAACABAAAgAAiAgJ/Y5l1fS7/VaE2rQLGhLGDi2VW5fG2s0KCqUtrUAUQlhDZDGpPAAAAgAAAAIAFAACAAA=="

    // Test vector at "An updater which adds SIGHASH_ALL to the above PSBT must create this PSBT"
    let unsignedPSBT = "cHNidP8BAJoCAAAAAljoeiG1ba8MI76OcHBFbDNvfLqlyHV5JPVFiHuyq911AAAAAAD/////g40EJ9DsZQpoqka7CwmK6kQiwHGyyng1Kgd5WdB86h0BAAAAAP////8CcKrwCAAAAAAWABTYXCtx0AYLCcmIauuBXlCZHdoSTQDh9QUAAAAAFgAUAK6pouXw+HaliN9VRuh0LR2HAI8AAAAAAAEAuwIAAAABqtc5MQGL0l+ErkALaISL4J23BurCrBgpi6vucatlb4sAAAAASEcwRAIgWPb8fGoz4bMVSNSByCbAFb0wE1qtQs1neQ2rZtKtJDsCIEoc7SYExnNbY5PltBaR3XiwDwxZQvufdRhW+qk4FX26Af7///8CgPD6AgAAAAAXqRQPuUY0IWlrgsgzryQceMF9295JNIfQ8gonAQAAABepFCnKdPigj4GZlCgYXJe12FLkBj9hh2UAAAABAwQBAAAAAQRHUiEClYO/Oa4KYJdHrRma3dY0+mEIVZ1sXNObTCGD8auW4H8hAtq2H/SaFNtqfQKwzR+7ePxLGDErW05U2uTbovv+9TbXUq4iBgKVg785rgpgl0etGZrd1jT6YQhVnWxc05tMIYPxq5bgfxDZDGpPAAAAgAAAAIAAAACAIgYC2rYf9JoU22p9ArDNH7t4/EsYMStbTlTa5Nui+/71NtcQ2QxqTwAAAIAAAACAAQAAgAABASAAwusLAAAAABepFLf1+vQOPUClpFmx2zU18rcvqSHohwEDBAEAAAABBCIAIIwjUxc3Q7WV37Sge3K6jkLjeX2nTof+fZ10l+OyAokDAQVHUiEDCJ3BDHrG21T5EymvYXMz2ziM6tDCMfcjN50bmQMLAtwhAjrdkE89bc9Z3bkGsN7iNSm3/7ntUOXoYVGSaGAiHw5zUq4iBgI63ZBPPW3PWd25BrDe4jUpt/+57VDl6GFRkmhgIh8OcxDZDGpPAAAAgAAAAIADAACAIgYDCJ3BDHrG21T5EymvYXMz2ziM6tDCMfcjN50bmQMLAtwQ2QxqTwAAAIAAAACAAgAAgAAiAgOppMN/WZbTqiXbrGtXCvBlA5RJKUJGCzVHU+2e7KWHcRDZDGpPAAAAgAAAAIAEAACAACICAn9jmXV9Lv9VoTatAsaEsYOLZVbl8bazQoKpS2tQBRCWENkMak8AAACAAAAAgAUAAIAA"
    
    let masterKeyXpriv = "tprv8ZgxMBicQKsPd9TeAdPADNnSyH9SSUUbTVeFszDE23Ki6TBB5nCefAdHkK8Fm3qMQR6sHwA56zqRmKmxnHk37JkiFzvncDqoKmPWubu7hDF"
    
    // Paths
    let path0 = BIP32Path("m/0'/0'/0'")!
    let path1 = BIP32Path("m/0'/0'/1'")!
    let path2 = BIP32Path("m/0'/0'/2'")!
    let path3 = BIP32Path("m/0'/0'/3'")!
    let path4 = BIP32Path("m/0'/0'/4'")!
    let path5 = BIP32Path("m/0'/0'/5'")!
    
    // Private keys (testnet)
    let WIF_0 = "cP53pDbR5WtAD8dYAW9hhTjuvvTVaEiQBdrz9XPrgLBeRFiyCbQr" // m/0'/0'/0'
    let WIF_1 = "cT7J9YpCwY3AVRFSjN6ukeEeWY6mhpbJPxRaDaP5QTdygQRxP9Au" // m/0'/0'/1'
    let WIF_2 = "cR6SXDoyfQrcp4piaiHE97Rsgta9mNhGTen9XeonVgwsh4iSgw6d" // m/0'/0'/2'
    let WIF_3 = "cNBc3SWUip9PPm1GjRoLEJT6T41iNzCYtD7qro84FMnM5zEqeJsE" // m/0'/0'/3'
    
    // Public keys
    let pubKey0 = PubKey(Data("029583bf39ae0a609747ad199addd634fa6108559d6c5cd39b4c2183f1ab96e07f")!, .testnet)!
    let pubKey1 = PubKey(Data("02dab61ff49a14db6a7d02b0cd1fbb78fc4b18312b5b4e54dae4dba2fbfef536d7")!, .testnet)!
    let pubKey2 = PubKey(Data("03089dc10c7ac6db54f91329af617333db388cead0c231f723379d1b99030b02dc")!, .testnet)!
    let pubKey3 = PubKey(Data("023add904f3d6dcf59ddb906b0dee23529b7ffb9ed50e5e86151926860221f0e73")!, .testnet)!
    let pubKey4 = PubKey(Data("03a9a4c37f5996d3aa25dbac6b570af0650394492942460b354753ed9eeca58771")!, .testnet)!
    let pubKey5 = PubKey(Data("027f6399757d2eff55a136ad02c684b1838b6556e5f1b6b34282a94b6b50051096")!, .testnet)!
    
    // Singed with keys m/0'/0'/0' and m/0'/0'/2'
    let signedPSBT_0_2 = "cHNidP8BAJoCAAAAAljoeiG1ba8MI76OcHBFbDNvfLqlyHV5JPVFiHuyq911AAAAAAD/////g40EJ9DsZQpoqka7CwmK6kQiwHGyyng1Kgd5WdB86h0BAAAAAP////8CcKrwCAAAAAAWABTYXCtx0AYLCcmIauuBXlCZHdoSTQDh9QUAAAAAFgAUAK6pouXw+HaliN9VRuh0LR2HAI8AAAAAAAEAuwIAAAABqtc5MQGL0l+ErkALaISL4J23BurCrBgpi6vucatlb4sAAAAASEcwRAIgWPb8fGoz4bMVSNSByCbAFb0wE1qtQs1neQ2rZtKtJDsCIEoc7SYExnNbY5PltBaR3XiwDwxZQvufdRhW+qk4FX26Af7///8CgPD6AgAAAAAXqRQPuUY0IWlrgsgzryQceMF9295JNIfQ8gonAQAAABepFCnKdPigj4GZlCgYXJe12FLkBj9hh2UAAAAiAgKVg785rgpgl0etGZrd1jT6YQhVnWxc05tMIYPxq5bgf0cwRAIgdAGK1BgAl7hzMjwAFXILNoTMgSOJEEjn282bVa1nnJkCIHPTabdA4+tT3O+jOCPIBwUUylWn3ZVE8VfBZ5EyYRGMAQEDBAEAAAABBEdSIQKVg785rgpgl0etGZrd1jT6YQhVnWxc05tMIYPxq5bgfyEC2rYf9JoU22p9ArDNH7t4/EsYMStbTlTa5Nui+/71NtdSriIGApWDvzmuCmCXR60Zmt3WNPphCFWdbFzTm0whg/GrluB/ENkMak8AAACAAAAAgAAAAIAiBgLath/0mhTban0CsM0fu3j8SxgxK1tOVNrk26L7/vU21xDZDGpPAAAAgAAAAIABAACAAAEBIADC6wsAAAAAF6kUt/X69A49QKWkWbHbNTXyty+pIeiHIgIDCJ3BDHrG21T5EymvYXMz2ziM6tDCMfcjN50bmQMLAtxHMEQCIGLrelVhB6fHP0WsSrWh3d9vcHX7EnWWmn84Pv/3hLyyAiAMBdu3Rw2/LwhVfdNWxzJcHtMJE+mWzThAlF2xIijaXwEBAwQBAAAAAQQiACCMI1MXN0O1ld+0oHtyuo5C43l9p06H/n2ddJfjsgKJAwEFR1IhAwidwQx6xttU+RMpr2FzM9s4jOrQwjH3IzedG5kDCwLcIQI63ZBPPW3PWd25BrDe4jUpt/+57VDl6GFRkmhgIh8Oc1KuIgYCOt2QTz1tz1nduQaw3uI1Kbf/ue1Q5ehhUZJoYCIfDnMQ2QxqTwAAAIAAAACAAwAAgCIGAwidwQx6xttU+RMpr2FzM9s4jOrQwjH3IzedG5kDCwLcENkMak8AAACAAAAAgAIAAIAAIgIDqaTDf1mW06ol26xrVwrwZQOUSSlCRgs1R1Ptnuylh3EQ2QxqTwAAAIAAAACABAAAgAAiAgJ/Y5l1fS7/VaE2rQLGhLGDi2VW5fG2s0KCqUtrUAUQlhDZDGpPAAAAgAAAAIAFAACAAA=="
    
    // Singed with keys m/0'/0'/1' (test vector modified for EC_FLAG_GRIND_R) and m/0'/0'/3'
    let signedPSBT_1_3 = "cHNidP8BAJoCAAAAAljoeiG1ba8MI76OcHBFbDNvfLqlyHV5JPVFiHuyq911AAAAAAD/////g40EJ9DsZQpoqka7CwmK6kQiwHGyyng1Kgd5WdB86h0BAAAAAP////8CcKrwCAAAAAAWABTYXCtx0AYLCcmIauuBXlCZHdoSTQDh9QUAAAAAFgAUAK6pouXw+HaliN9VRuh0LR2HAI8AAAAAAAEAuwIAAAABqtc5MQGL0l+ErkALaISL4J23BurCrBgpi6vucatlb4sAAAAASEcwRAIgWPb8fGoz4bMVSNSByCbAFb0wE1qtQs1neQ2rZtKtJDsCIEoc7SYExnNbY5PltBaR3XiwDwxZQvufdRhW+qk4FX26Af7///8CgPD6AgAAAAAXqRQPuUY0IWlrgsgzryQceMF9295JNIfQ8gonAQAAABepFCnKdPigj4GZlCgYXJe12FLkBj9hh2UAAAAiAgLath/0mhTban0CsM0fu3j8SxgxK1tOVNrk26L7/vU210cwRAIgYxqYn+c4qSrQGYYCMxLBkhT+KAKznly8GsNniAbGksMCIDnbbDh70mdxbf2z1NjaULjoXSEzJrp8faqkwM5B65IjAQEDBAEAAAABBEdSIQKVg785rgpgl0etGZrd1jT6YQhVnWxc05tMIYPxq5bgfyEC2rYf9JoU22p9ArDNH7t4/EsYMStbTlTa5Nui+/71NtdSriIGApWDvzmuCmCXR60Zmt3WNPphCFWdbFzTm0whg/GrluB/ENkMak8AAACAAAAAgAAAAIAiBgLath/0mhTban0CsM0fu3j8SxgxK1tOVNrk26L7/vU21xDZDGpPAAAAgAAAAIABAACAAAEBIADC6wsAAAAAF6kUt/X69A49QKWkWbHbNTXyty+pIeiHIgICOt2QTz1tz1nduQaw3uI1Kbf/ue1Q5ehhUZJoYCIfDnNHMEQCIGX0W6WZi1mif/4ae+0BavHx+Q1Us6qPdFCqX1aiUQO9AiB/ckcDrR7blmgLKEtW1P/LiPf7dZ6rvgiqMPKbhROD0gEBAwQBAAAAAQQiACCMI1MXN0O1ld+0oHtyuo5C43l9p06H/n2ddJfjsgKJAwEFR1IhAwidwQx6xttU+RMpr2FzM9s4jOrQwjH3IzedG5kDCwLcIQI63ZBPPW3PWd25BrDe4jUpt/+57VDl6GFRkmhgIh8Oc1KuIgYCOt2QTz1tz1nduQaw3uI1Kbf/ue1Q5ehhUZJoYCIfDnMQ2QxqTwAAAIAAAACAAwAAgCIGAwidwQx6xttU+RMpr2FzM9s4jOrQwjH3IzedG5kDCwLcENkMak8AAACAAAAAgAIAAIAAIgIDqaTDf1mW06ol26xrVwrwZQOUSSlCRgs1R1Ptnuylh3EQ2QxqTwAAAIAAAACABAAAgAAiAgJ/Y5l1fS7/VaE2rQLGhLGDi2VW5fG2s0KCqUtrUAUQlhDZDGpPAAAAgAAAAIAFAACAAA=="
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInvalidPSBT(_ psbt: String, _ expectedError: Error) {
        XCTAssertThrowsError(try PSBT(psbt, .testnet)) {error in
            XCTAssertEqual(String(describing: error), String(describing: expectedError))
        }
    }
    
    func testParseTooShortPSBT() {
        testInvalidPSBT("", PSBT.ParseError.tooShort)
    }
    
    func testInvalidCharacters() {
        testInvalidPSBT("💩", PSBT.ParseError.invalidBase64)
    }

    func testParseBase64() {
        let psbt = try! PSBT(validPSBT, .testnet)
        XCTAssertEqual(psbt.description, validPSBT)
    }
    
    func testParseBinary() {
        let psbtData = Data(base64Encoded: validPSBT)!
        let psbt = try! PSBT(psbtData, .testnet)
        XCTAssertEqual(psbt.description, validPSBT)
        XCTAssertEqual(psbt.data, psbtData)
    }
    
    func testInvalidPSBT() {
    testInvalidPSBT("AgAAAAEmgXE3Ht/yhek3re6ks3t4AAwFZsuzrWRkFxPKQhcb9gAAAABqRzBEAiBwsiRRI+a/R01gxbUMBD1MaRpdJDXwmjSnZiqdwlF5CgIgATKcqdrPKAvfMHQOwDkEIkIsgctFg5RXrrdvwS7dlbMBIQJlfRGNM1e44PTCzUbbezn22cONmnCry5st5dyNv+TOMf7///8C09/1BQAAAAAZdqkU0MWZA8W6woaHYOkP1SGkZlqnZSCIrADh9QUAAAAAF6kUNUXm4zuDLEcFDyTT7rk8nAOUi8eHsy4TAA==", PSBT.ParseError.invalid)
    }
    
    func testComplete() {
        let incompletePSBT = try! PSBT(validPSBT, .testnet)
        let completePSBT = try! PSBT(finalizedPSBT, .testnet)
        XCTAssertFalse(incompletePSBT.complete)
        XCTAssertFalse(try! PSBT(unsignedPSBT, .testnet).complete)
        XCTAssertFalse(try! PSBT(signedPSBT_0_2, .testnet).complete)
        XCTAssertTrue(completePSBT.complete)
    }
    
    func testExtractTransaction() {
        let incompletePSBT = try! PSBT(validPSBT, .testnet)
        XCTAssertNil(incompletePSBT.transaction)
        
        let completePSBT = try! PSBT(finalizedPSBT, .testnet)
        if let transaction = completePSBT.transaction {
            XCTAssertEqual(transaction.description, "0200000000010258e87a21b56daf0c23be8e7070456c336f7cbaa5c8757924f545887bb2abdd7500000000da00473044022074018ad4180097b873323c0015720b3684cc8123891048e7dbcd9b55ad679c99022073d369b740e3eb53dcefa33823c8070514ca55a7dd9544f157c167913261118c01483045022100f61038b308dc1da865a34852746f015772934208c6d24454393cd99bdf2217770220056e675a675a6d0a02b85b14e5e29074d8a25a9b5760bea2816f661910a006ea01475221029583bf39ae0a609747ad199addd634fa6108559d6c5cd39b4c2183f1ab96e07f2102dab61ff49a14db6a7d02b0cd1fbb78fc4b18312b5b4e54dae4dba2fbfef536d752aeffffffff838d0427d0ec650a68aa46bb0b098aea4422c071b2ca78352a077959d07cea1d01000000232200208c2353173743b595dfb4a07b72ba8e42e3797da74e87fe7d9d7497e3b2028903ffffffff0270aaf00800000000160014d85c2b71d0060b09c9886aeb815e50991dda124d00e1f5050000000016001400aea9a2e5f0f876a588df5546e8742d1d87008f000400473044022062eb7a556107a7c73f45ac4ab5a1dddf6f7075fb1275969a7f383efff784bcb202200c05dbb7470dbf2f08557dd356c7325c1ed30913e996cd3840945db12228da5f01473044022065f45ba5998b59a27ffe1a7bed016af1f1f90d54b3aa8f7450aa5f56a25103bd02207f724703ad1edb96680b284b56d4ffcb88f7fb759eabbe08aa30f29b851383d20147522103089dc10c7ac6db54f91329af617333db388cead0c231f723379d1b99030b02dc21023add904f3d6dcf59ddb906b0dee23529b7ffb9ed50e5e86151926860221f0e7352ae00000000")
        } else { XCTFail() }
        
    }
    
    func testSignWithKey() {
        let privKey0 = Key(WIF_0, .testnet)
        let privKey1 = Key(WIF_1, .testnet)
        let privKey2 = Key(WIF_2, .testnet)
        let privKey3 = Key(WIF_3, .testnet)
        var psbt1 = try! PSBT(unsignedPSBT, .testnet)
        var psbt2 = try! PSBT(unsignedPSBT, .testnet)
        let expectedPSBT_0_2 = try! PSBT(signedPSBT_0_2, .testnet)
        let expectedPSBT_1_3 = try! PSBT(signedPSBT_1_3, .testnet)

        psbt1.sign(privKey0!)
        psbt1.sign(privKey2!)
        XCTAssertEqual(psbt1.description, expectedPSBT_0_2.description)
        psbt2.sign(privKey1!)
        psbt2.sign(privKey3!)
        XCTAssertEqual(psbt2.description, expectedPSBT_1_3.description)
    }
    
    func testInputs() {
        let psbt = try! PSBT(unsignedPSBT, .testnet)
        XCTAssertEqual(psbt.inputs.count, 2)
    }
    
    func testOutput() {
        let psbt = try! PSBT(unsignedPSBT, .testnet)
        XCTAssertEqual(psbt.outputs.count, 2)
    }
    
    func testKeyPaths() {
        let expectedOrigin0 = KeyOrigin(fingerprint: fingerprint, path: path0)
        let expectedOrigin1 = KeyOrigin(fingerprint: fingerprint, path: path1)
        let expectedOrigin2 = KeyOrigin(fingerprint: fingerprint, path: path2)
        let expectedOrigin3 = KeyOrigin(fingerprint: fingerprint, path: path3)
        let expectedOrigin4 = KeyOrigin(fingerprint: fingerprint, path: path4)
        let expectedOrigin5 = KeyOrigin(fingerprint: fingerprint, path: path5)
        let psbt = try! PSBT(unsignedPSBT, .testnet)
        // Check inputs
        XCTAssertEqual(psbt.inputs.count, 2)
        XCTAssertNotNil(psbt.inputs[0].origins)
        XCTAssertEqual(psbt.inputs[0].origins!.count, 2)
        XCTAssertEqual(psbt.inputs[0].origins![pubKey0], expectedOrigin0)
        XCTAssertEqual(psbt.inputs[0].origins![pubKey1], expectedOrigin1)
        XCTAssertEqual(psbt.inputs[1].origins!.count, 2)
        XCTAssertEqual(psbt.inputs[1].origins![pubKey3], expectedOrigin3)
        XCTAssertEqual(psbt.inputs[1].origins![pubKey2], expectedOrigin2)
        // Check outputs
        XCTAssertEqual(psbt.outputs.count, 2)
        XCTAssertNotNil(psbt.outputs[0].origins)
        XCTAssertEqual(psbt.outputs[0].origins!.count, 1)
        XCTAssertEqual(psbt.outputs[0].origins![pubKey4], expectedOrigin4)
        XCTAssertEqual(psbt.outputs[1].origins!.count, 1)
        XCTAssertEqual(psbt.outputs[1].origins![pubKey5], expectedOrigin5)
    }
   
    func testCanSign() {
        let masterKey = HDKey(masterKeyXpriv)!
        let psbt = try! PSBT(unsignedPSBT, .testnet)
        for input in psbt.inputs {
            XCTAssertTrue(input.canSign(masterKey))
        }
    }
}
