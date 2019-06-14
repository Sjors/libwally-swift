//
//  Address.swift
//  Address 
//
//  Created by Sjors on 14/06/2019.
//  Copyright © 2019 Blockchain. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation

public enum AddressType {
    case payToPubKeyHash // P2PKH (legacy)
    case payToScriptHashPayToWitnessPubKeyHash // P2SH-P2WPKH (wrapped SegWit)
    case payToWitnessPubKeyHash // P2WPKH (native SegWit)
}

public protocol AddressProtocol : LosslessStringConvertible {
    var scriptPubKey: ScriptPubKey { get }
}

public struct Address : AddressProtocol {
    public var scriptPubKey: ScriptPubKey
    var address: String
    
    public init?(_ description: String) {
        self.address = description

        // base58 and bech32 use more bytes in string form, so description.count should be safe:
        var bytes_out = UnsafeMutablePointer<UInt8>.allocate(capacity: description.count)
        var written = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        defer {
            bytes_out.deallocate()
            written.deallocate()
        }
        
        // Try if this is a bech32 Bitcoin address:
        let family: String = "bc"
        var result = wally_addr_segwit_to_bytes(description, family, 0, bytes_out, description.count, written)
        
        if (result != WALLY_OK) {
            // Try if this is a base58 addresses (P2PKH or P2SH)
            result = wally_address_to_scriptpubkey(description, UInt32(WALLY_NETWORK_BITCOIN_MAINNET), bytes_out, description.count, written)

            if (result != WALLY_OK) {
                return nil
            }
        }
        
        self.scriptPubKey = ScriptPubKey(Data(bytes: bytes_out, count: written.pointee))
    }
    
    init(_ hdKey: HDKey, _ type: AddressType) {
        let wally_type: Int32 = {
            switch type {
            case .payToPubKeyHash:
                return WALLY_ADDRESS_TYPE_P2PKH
            case .payToScriptHashPayToWitnessPubKeyHash:
                return WALLY_ADDRESS_TYPE_P2SH_P2WPKH
            case .payToWitnessPubKeyHash:
                return WALLY_ADDRESS_TYPE_P2WPKH
            }
        }()
        
        var key = UnsafeMutablePointer<ext_key>.allocate(capacity: 1)
        key.initialize(to: hdKey.wally_ext_key)
        var output: UnsafeMutablePointer<Int8>?
        defer {
            key.deallocate()
            wally_free_string(output)
        }
        
        if (wally_type == WALLY_ADDRESS_TYPE_P2PKH || wally_type == WALLY_ADDRESS_TYPE_P2SH_P2WPKH) {
            let version: UInt32 = wally_type == WALLY_ADDRESS_TYPE_P2PKH ? 0x00 : 0x05
            precondition(wally_bip32_key_to_address(key, UInt32(wally_type), version, &output) == WALLY_OK)
            precondition(output != nil)
        } else {
            precondition(wally_type == WALLY_ADDRESS_TYPE_P2WPKH)
            let family: String = "bc"
            precondition(wally_bip32_key_to_addr_segwit(key, family, 0, &output) == WALLY_OK)
            precondition(output != nil)
        }
        
        let address = String(cString: output!)
        
        // TODO: get scriptPubKey directly from libwally (requires a new function) instead parsing the string
        self.init(address)! // libwally generated this string, so it's safe to force unwrap
    }
    
    public var description: String {
        return address
    }

}

extension HDKey {
    public func address (_ type: AddressType) -> Address {
        return Address(self, type)
    }
}
