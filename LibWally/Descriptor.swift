//
//  Descriptor.swift
//  Descriptor
//
//  Created by Sjors Provoost on 24/01/2022.
//  Copyright © 2022 Sjors Provoost. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
@_implementationOnly import CLibWally

public enum DescriptorError: Error {
    case invalid
    case noAddress // There is no address representation, e.g. pk()
    case notRanged // No index should be used for getAddress() when called on a non-ranged descriptor
    case ranged // Index must be used for getAddress() when called on a ranged descriptor
}


public struct Descriptor {
    // The descriptor string we were initialized with. Not normalized and not fully validated.
    var wally_descriptor: OpaquePointer?
    public var network: Network
    public var canonical: String
    public var isRanged: Bool
    public var miniscript: Bool
    
    // The descriptor is not fully validated.
    public init(_ descriptor: String, _ network: Network) throws {
        self.network = network

        // Parse descriptor
        if (wally_descriptor_parse(descriptor, nil, UInt32(network == .mainnet ? WALLY_NETWORK_BITCOIN_MAINNET : WALLY_NETWORK_BITCOIN_TESTNET), UInt32( WALLY_MINISCRIPT_REQUIRE_CHECKSUM), &wally_descriptor) != WALLY_OK) {
            throw DescriptorError.invalid
        }
        
        // Store properties
        let feature_flags = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        precondition(wally_descriptor_get_features(wally_descriptor, feature_flags) == WALLY_OK)
        self.isRanged = (feature_flags.pointee & UInt32(WALLY_MS_IS_RANGED)) != 0
        self.miniscript = (feature_flags.pointee & UInt32(WALLY_MS_IS_DESCRIPTOR)) == 0
    
        // Canonicalize the descriptor
        var output: UnsafeMutablePointer<Int8>?
        defer {
            wally_free_string(output)
        }
        if (wally_descriptor_canonicalize(wally_descriptor, 0, &output) != WALLY_OK) {
            throw DescriptorError.invalid
        } else {
            precondition(output != nil)
            self.canonical = String(cString: output!)
        }
    }
  
    /* Deinitializers may only be declared within a class or actor.
    /  I'm unsure if not freeing up the memory is safe. */
    
    // deinit {
    //   wally_descriptor_free(self.wally_descriptor)
    // }
    
    // May throw if something is wrong with the descriptor.
    // Will throw if descriptor can't be expressed as an address, e.g. pk().
    public func getAddress(_ index: UInt32) throws -> Address {
        if index != 0 && !self.isRanged {
            throw DescriptorError.notRanged
        }
        
        var output: UnsafeMutablePointer<Int8>?
        defer {
            wally_free_string(output)
        }

        let result = wally_descriptor_to_address(self.wally_descriptor, 0, 0, index, UInt32(0), &output)
        
        if result != WALLY_OK {
            throw DescriptorError.invalid
        }

        precondition(output != nil)
        if let address = Address(String(cString: output!)) {
            return address
        } else {
            // This code is not reached for pk() descriptors, because wally_descriptor_to_address will fail
            // TODO: catch descriptors that can't be expressed as an address earlier and explictly
            throw DescriptorError.noAddress
        }
    }
    
    public func getAddress() throws -> Address {
        if self.isRanged {
            throw DescriptorError.ranged
        }
        return try getAddress(0)
    }

}
