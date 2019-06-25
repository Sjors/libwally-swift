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
    case signed
    case feeWorstCase
}

public enum WitnessType {
    case payToWitnessPubKeyHash(PubKey) // P2WPKH (native SegWit)
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

public struct ScriptSig : Equatable {
    // In order to produce a (P2PKH) scriptSig a public key is needed:
    let pubKey: PubKey

    // When used in a finalized transaction, scriptSig usually includes a signature:
    var signature: Signature?
    
    public init (_ type: ScriptSigType) {
        switch (type) {
        case .payToPubKeyHash(let pubKey):
            self.pubKey = pubKey
        }
    }
    
    public func render(_ purpose: ScriptSigPurpose) -> Data? {
        switch purpose {
        case .feeWorstCase:
             // DER encoded signature
            let dummySignature = Data([UInt8].init(repeating: 0, count: Int(EC_SIGNATURE_DER_MAX_LOW_R_LEN)))
            let sigHashByte = Data([UInt8(WALLY_SIGHASH_ALL)])
            let lengthPushSignature = Data([UInt8(dummySignature.count + 1)]) // DER encoded signature + sighash byte
            let lengthPushPubKey = Data([UInt8(self.pubKey.count)])
            return lengthPushSignature + dummySignature + sigHashByte + lengthPushPubKey + self.pubKey
        case .signed:
            if let signature = self.signature {
                let lengthPushSignature = Data([UInt8(signature.count + 1)]) // DER encoded signature + sighash byte
                let sigHashByte = Data([UInt8(WALLY_SIGHASH_ALL)])
                let lengthPushPubKey = Data([UInt8(self.pubKey.count)])
                return lengthPushSignature + signature + sigHashByte + lengthPushPubKey + self.pubKey
            } else {
                return nil
            }
        }
    }
}

public struct Witness {
    var stack: UnsafeMutablePointer<wally_tx_witness_stack>?
    var dummy: Bool = false
    
    let type: WitnessType
    
    public init (_ type: WitnessType, _ signature: Data) {
        switch (type) {
        case .payToWitnessPubKeyHash(let pubKey):
            self.type = type
            precondition(wally_tx_witness_stack_init_alloc(2, &self.stack) == WALLY_OK)
            let sigHashByte = Data([UInt8(WALLY_SIGHASH_ALL)])
            let signature_bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: signature.count + 1)
            (signature + sigHashByte).copyBytes(to: signature_bytes, count: signature.count + 1)
            let pubkey_bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: pubKey.count)
            pubKey.copyBytes(to: pubkey_bytes, count: pubKey.count)
            
            precondition(wally_tx_witness_stack_set(self.stack!, 0, signature_bytes, signature.count + 1) == WALLY_OK)
            precondition(wally_tx_witness_stack_set(self.stack!, 1, pubkey_bytes, pubKey.count) == WALLY_OK)
        }
    }
    
    // Initialize without signature argument to get a dummy signature for fee calculation
    public init (_ type: WitnessType) {
        let dummySignature = Data([UInt8].init(repeating: 0, count: Int(EC_SIGNATURE_DER_MAX_LOW_R_LEN)))
        self.init(type, dummySignature)
        self.dummy = true
    }
    
    func signed (_ signature: Data) -> Witness {
        return Witness(self.type, signature)
    }
    
    var scriptCode: Data {
        switch self.type {
        case .payToWitnessPubKeyHash(let pubKey):
            let pubkey_bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: pubKey.count)
            pubKey.copyBytes(to: pubkey_bytes, count: pubKey.count)
            var pubkey_hash_bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(HASH160_LEN))
            defer {
                pubkey_hash_bytes.deallocate()
            }
            precondition(wally_hash160(pubkey_bytes, pubKey.count, pubkey_hash_bytes, Int(HASH160_LEN)) == WALLY_OK)
            return Data("76a914")! + Data(bytes: pubkey_hash_bytes, count: Int(HASH160_LEN)) + Data("88ac")!
        }
    }

}
