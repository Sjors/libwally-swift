//
//  BIP32.swift
//  BIP32 
//
//  Created by Sjors on 29/05/2019.
//  Copyright © 2019 Blockchain. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation

public enum BIP32Error: Error {
    case invalidIndex
    case hardenedDerivationWithoutPrivateKey
}

public enum BIP32Derivation : Equatable {
    // max 2^^31 - 1: enforced by the BIP32Path initializer
    case normal(UInt32)
    case hardened(UInt32)
    
    public var isHardened: Bool {
        switch self {
            case .normal(_):
                return false
            case .hardened(_):
                return true
        }
    }
}

public struct BIP32Path : LosslessStringConvertible {
    public let components: [BIP32Derivation]
    let rawPath: [UInt32]
    
    public init(_ components: [BIP32Derivation]) throws {
        var rawPath: [UInt32] = []

        for component in components {
            switch component {
            case .normal(let index):
                if index >= UINT32_MAX / 2 {
                    throw BIP32Error.invalidIndex
                }
                rawPath.append(index)
            case .hardened(let index):
                if index >= UINT32_MAX / 2 {
                    throw BIP32Error.invalidIndex
                }
                rawPath.append(BIP32_INITIAL_HARDENED_CHILD + index)
            }
        }
        self.components = components
        self.rawPath = rawPath
    }
    
    public init(_ component: BIP32Derivation) throws {
        try self.init([component])
    }
    
    public init(_ index: Int) throws {
        try self.init([.normal(UInt32(index))])
    }
    
    // LosslessStringConvertible does not permit this initializer to throw
    public init?(_ description: String) {
        guard description.count > 0 else {
            return nil
        }
        guard description.prefix(2) == "m/" else {
            return nil
        }
        var tmpComponents: [BIP32Derivation] = []

        for component in description.dropFirst(2).split(separator: "/") {
            let index: UInt32? = UInt32(component)
            if let i = index {
                tmpComponents.append(.normal(i))
            } else if component.suffix(1) == "h" || component.suffix(1) == "'" {
                let indexHardened: UInt32? = UInt32(component.dropLast(1))
                if let i = indexHardened {
                    tmpComponents.append(.hardened(i))
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        
        guard tmpComponents.count > 0 else {
            return nil
        }
        do {
            try self.init(tmpComponents)
        } catch {
            return nil
        }
    }
    
    public var description: String {
        var pathString = "m"
        for item in components {
            switch item {
            case .normal(let index):
                pathString += "/" + String(index)
            case .hardened(let index):
                pathString += "/" + String(index) + "h"
            }
        }
        return pathString
    }
    
}

public struct HDKey : LosslessStringConvertible {
    var wally_ext_key: ext_key
    
    init(_ key: ext_key) {
        self.wally_ext_key = key
    }

    public init?(_ description: String) {
        var output: UnsafeMutablePointer<ext_key>?
        defer {
            if let wally_ext_key = output {
                wally_ext_key.deallocate()
            }
        }
        let result = bip32_key_from_base58_alloc(description, &output)
        if (result == WALLY_OK) {
            precondition(output != nil)
            self.init(output!.pointee)
        } else {
            return nil
        }
    }

    public init?(_ seed: BIP39Seed) {
        var bytes_in = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(BIP39_SEED_LEN_512))
        var output: UnsafeMutablePointer<ext_key>?
        defer {
            bytes_in.deallocate()
            if let wally_ext_key = output {
                wally_ext_key.deallocate()
            }
        }
        seed.data.copyBytes(to: bytes_in, count: Int(BIP39_SEED_LEN_512))
        let result = bip32_key_from_seed_alloc(bytes_in, Int(BIP32_ENTROPY_LEN_512), UInt32(BIP32_VER_MAIN_PRIVATE), 0, &output)
        if (result == WALLY_OK) {
            precondition(output != nil)
            self.init(output!.pointee)
        } else {
            // From libwally-core docs:
            // The entropy passed in may produce an invalid key. If this happens, WALLY_ERROR will be returned
            // and the caller should retry with new entropy.
            return nil
        }
    }
    
    public var description: String {
        return isNeutered ? xpub : xpriv!
    }
    
    public var isNeutered: Bool {
        return self.wally_ext_key.version == BIP32_VER_MAIN_PUBLIC || self.wally_ext_key.version == BIP32_VER_TEST_PUBLIC
    }
    
    public var xpub: String {
        var hdkey = UnsafeMutablePointer<ext_key>.allocate(capacity: 1)
        var output: UnsafeMutablePointer<Int8>?
        defer {
            hdkey.deallocate()
            wally_free_string(output)
        }
        hdkey.initialize(to: self.wally_ext_key)
        
        precondition(bip32_key_to_base58(hdkey, UInt32(BIP32_FLAG_KEY_PUBLIC), &output) == WALLY_OK)
        precondition(output != nil)
        return String(cString: output!)
    }
    
    public var xpriv: String? {
        if self.isNeutered {
            return nil
        }
        var hdkey = UnsafeMutablePointer<ext_key>.allocate(capacity: 1)
        var output: UnsafeMutablePointer<Int8>?
        defer {
            hdkey.deallocate()
            wally_free_string(output)
        }
        hdkey.initialize(to: self.wally_ext_key)
        
        precondition(bip32_key_to_base58(hdkey, UInt32(BIP32_FLAG_KEY_PRIVATE), &output) == WALLY_OK)
        precondition(output != nil)
        return String(cString: output!)
    }
    
    
    public func derive (_ path: BIP32Path) throws -> HDKey {
        if self.isNeutered && path.components.first(where: { $0.isHardened }) != nil {
            throw BIP32Error.hardenedDerivationWithoutPrivateKey
        }
        
        var hdkey = UnsafeMutablePointer<ext_key>.allocate(capacity: 1)
        hdkey.initialize(to: self.wally_ext_key)
        
        var output: UnsafeMutablePointer<ext_key>?
        defer {
            hdkey.deallocate()
            if let wally_ext_key = output {
                wally_ext_key.deallocate()
            }
        }
        
        precondition(bip32_key_from_parent_path_alloc(hdkey, path.rawPath, path.rawPath.count, UInt32(self.isNeutered ? BIP32_FLAG_KEY_PUBLIC : BIP32_FLAG_KEY_PRIVATE), &output) == WALLY_OK)
        precondition(output != nil)
        return HDKey(output!.pointee)
    }
}
