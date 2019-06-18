//
//  Script.swift
//  Script 
//
//  Created by Sjors on 14/06/2019.
//  Copyright © 2019 Blockchain. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation

let a = WALLY_SCRIPT_TYPE_OP_RETURN

public enum ScriptType {
    case opReturn // OP_RETURN
    case payToPubKeyHash // P2PKH (legacy)
    case payToScriptHash // P2SH (could be wrapped SegWit)
    case payToWitnessPubKeyHash // P2WPKH (native SegWit)
    case payToWitnessScriptHash // P2WS (native SegWit script)
    case multiSig
}

public typealias PubKey = Data
public typealias Signature = Data

public enum ScriptSigType {
    case payToPubKeyHash(PubKey) // P2PKH (legacy)
}

public enum ScriptSigPurpose {
    case signThisInput
    case signOtherInput
    case signed
}

public struct ScriptPubKey : LosslessStringConvertible, Equatable {
    var bytes: Data
    
    public lazy var type: ScriptType? = {
        var bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: self.bytes.count)
        let bytes_len = self.bytes.count
        let output = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        
        self.bytes.copyBytes(to: bytes, count: bytes_len)

        precondition(wally_scriptpubkey_get_type(bytes, bytes_len, output) == WALLY_OK)

        switch (Int32(output.pointee)) {
        case WALLY_SCRIPT_TYPE_OP_RETURN:
            return .opReturn
        case WALLY_SCRIPT_TYPE_P2PKH:
            return .payToPubKeyHash
        case WALLY_SCRIPT_TYPE_P2SH:
            return .payToScriptHash
        case WALLY_SCRIPT_TYPE_P2WPKH:
            return .payToWitnessPubKeyHash
        case WALLY_SCRIPT_TYPE_P2WSH:
            return .payToWitnessScriptHash
        case WALLY_SCRIPT_TYPE_MULTISIG:
            return .multiSig
        default:
            precondition(output.pointee == WALLY_SCRIPT_TYPE_UNKNOWN)
            return nil
        }
    }()

    public init?(_ description: String) {
        if let data = Data(description) {
            self.bytes = data
        } else {
            return nil
        }
    }
    
    public var description: String {
        return self.bytes.hexString
    }


    init(_ bytes: Data) {
        self.bytes = bytes
    }
    

}

public struct ScriptSig {
    // When signing an input, its scriptSig is replaced by scriptPubKey of the output being spent
    let scriptPubKey: ScriptPubKey
    
    // In order to produce a (P2PKH) scriptSig a public key is needed:
    let pubKey: PubKey

    // When used in a finalized transaction, scriptSig usually includes a signature:
    var signature: Signature?
    
    init (_ type: ScriptSigType, _ scriptPubKey: ScriptPubKey) {
        var mutableScriptPubKey = scriptPubKey
        switch (type) {
        case .payToPubKeyHash(let pubKey):
            precondition(mutableScriptPubKey.type == .payToPubKeyHash)
            self.pubKey = pubKey
        }
        
        self.scriptPubKey = scriptPubKey
    }
    
    public func render(_ purpose: ScriptSigPurpose) -> Data? {
        switch purpose {
        case .signThisInput:
            return self.scriptPubKey.bytes
        case .signOtherInput:
            return Data("")!
        case .signed:
            if let signature = self.signature {
                return Data([UInt8(signature.count)]) + signature + self.scriptPubKey.bytes
            } else {
                return nil
            }
        }
    }
}
