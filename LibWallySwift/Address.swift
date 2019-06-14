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

public protocol Address : CustomStringConvertible {
}

protocol WallyAddress : Address {
    init(_ address: String)
    init(_ hdKey: HDKey)
    var address: String { get }
}

extension WallyAddress {
    public var description: String {
        return address
    }

    init(_ hdKey: HDKey, _ type: Int32) {
        var key = UnsafeMutablePointer<ext_key>.allocate(capacity: 1)
        key.initialize(to: hdKey.wally_ext_key)
        var output: UnsafeMutablePointer<Int8>?
        defer {
            key.deallocate()
            wally_free_string(output)
        }
        
        if (type == WALLY_ADDRESS_TYPE_P2PKH || type == WALLY_ADDRESS_TYPE_P2SH_P2WPKH) {
            let version: UInt32 = type == WALLY_ADDRESS_TYPE_P2PKH ? 0x00 : 0x05
            precondition(wally_bip32_key_to_address(key, UInt32(type), version, &output) == WALLY_OK)
            precondition(output != nil)
            self.init(String(cString: output!))
        } else {
            precondition(type == WALLY_ADDRESS_TYPE_P2WPKH)
            let family: String = "bc"
            precondition(wally_bip32_key_to_addr_segwit(key, family, 0, &output) == WALLY_OK)
            precondition(output != nil)
            self.init(String(cString: output!))
        }
    }
}

public struct AddressP2PKH : WallyAddress {
    var address: String
    
    init(_ address: String) {
        self.address = address
    }
    
    init(_ hdKey: HDKey) {
        self.init(hdKey, WALLY_ADDRESS_TYPE_P2PKH)
    }
}

public struct AddressP2SH_P2PKH : WallyAddress {
    var address: String
    
    init(_ address: String) {
        self.address = address
    }

    init(_ hdKey: HDKey) {
        self.init(hdKey, WALLY_ADDRESS_TYPE_P2SH_P2WPKH)
    }
}

public struct AddressP2WPKH : WallyAddress {
    var address: String

    init(_ address: String) {
        self.address = address
    }
    
    init(_ hdKey: HDKey) {
        self.init(hdKey, WALLY_ADDRESS_TYPE_P2WPKH)
    }
}

extension HDKey {
    public func address (_ type: AddressType) -> Address {
        switch type {
        case .payToPubKeyHash:
            return AddressP2PKH(self)
        case .payToScriptHashPayToWitnessPubKeyHash:
            return AddressP2SH_P2PKH(self)
        case .payToWitnessPubKeyHash:
            return AddressP2WPKH(self)
        }
    }
}
