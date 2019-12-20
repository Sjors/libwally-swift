//
//  PSBT.swift
//  PSBT 
//
//  Created by Sjors Provoost on 16/12/2019.
//  Copyright © 2019 Sjors Provoost. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import CLibWally

public struct KeyOrigin : Equatable {
    let fingerprint: Data
    let path: BIP32Path
}

func getOrigins (keypaths: wally_keypath_map, network: Network) -> [PubKey: KeyOrigin] {
    var origins: [PubKey: KeyOrigin] = [:]
    for i in 0..<keypaths.num_items {
        let item: wally_keypath_item = keypaths.items[i]
        let pubKey = PubKey(Data(bytes: [item.pubkey], count: Int(EC_PUBLIC_KEY_LEN)), network)!
        let fingerprint = Data(bytes: [item.origin.fingerprint], count: Int(FINGERPRINT_LEN))
        var components: [UInt32] = []
        for j in 0..<item.origin.path_len {
            let index = item.origin.path[j]
            components.append(index)
        }
        let path = try! BIP32Path(components, relative: false)
        origins[pubKey] = KeyOrigin(fingerprint: fingerprint, path: path)
    }
    return origins
}

struct PSBTInput {
    let wally_psbt_input: wally_psbt_input
    let origins: [PubKey: KeyOrigin]?
    
    init(_ wally_psbt_input: wally_psbt_input, network: Network) {
        self.wally_psbt_input = wally_psbt_input
        if (wally_psbt_input.keypaths != nil) {
            self.origins = getOrigins(keypaths: wally_psbt_input.keypaths.pointee, network: network)
        } else {
            self.origins = nil
        }
    }
    
    public func canSign(_ hdKey: HDKey) -> [PubKey: KeyOrigin]? {
        var result: [PubKey: KeyOrigin] = [:]
        if let origins = self.origins {
            for origin in origins {
                if hdKey.fingerprint == origin.value.fingerprint {
                    if let childKey = try? hdKey.derive(origin.value.path) {
                        if childKey.pubKey == origin.key {
                            result[origin.key] = origin.value
                        }
                    }
                }
            }
        }
        if result.count == 0 { return nil }
        return result
    }
    
    public func canSign(_ hdKey: HDKey) -> Bool {
        return canSign(hdKey) != nil
    }
}

struct PSBTOutput {
    let wally_psbt_output: wally_psbt_output
    let txOutput: TxOutput
    let origins: [PubKey: KeyOrigin]?
    
    init(_ wally_psbt_outputs: UnsafeMutablePointer<wally_psbt_output>, tx: wally_tx, index: Int, network: Network) {
        precondition(index >= 0 && index < tx.num_outputs)
        precondition(tx.num_outputs != 0 )
        self.wally_psbt_output = wally_psbt_outputs[index]
        if (wally_psbt_output.keypaths != nil) {
            self.origins = getOrigins(keypaths: wally_psbt_output.keypaths.pointee, network: network)
        } else {
            self.origins = nil
        }
        let output = tx.outputs![index]
        self.txOutput = TxOutput(output, network)
    }
}

public struct PSBT : Equatable {
    public static func == (lhs: PSBT, rhs: PSBT) -> Bool {
        lhs.network == rhs.network && lhs.data == rhs.data
    }
    

    enum ParseError: Error {
        case tooShort
        case invalidBase64
        case invalid
    }
    
    let network: Network
    let inputs: [PSBTInput]
    let outputs: [PSBTOutput]
    
    let wally_psbt: wally_psbt
    
    public init (_ psbt: Data, _ network: Network) throws {
        self.network = network
        var psbt_bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: psbt.count)
        let psbt_bytes_len = psbt.count
        psbt.copyBytes(to: psbt_bytes, count: psbt_bytes_len)
        var output: UnsafeMutablePointer<wally_psbt>?
        defer {
            if let wally_psbt = output {
                wally_psbt.deallocate()
            }
        }
        guard wally_psbt_from_bytes(psbt_bytes, psbt_bytes_len, &output) == WALLY_OK else {
            // libwally-core returns WALLY_EINVAL regardless of why parsing fails
            throw ParseError.invalid
        }
        precondition(output != nil)
        precondition(output!.pointee.tx != nil)
        self.wally_psbt = output!.pointee
        var inputs: [PSBTInput] = []
        for i in 0..<self.wally_psbt.inputs_allocation_len {
            inputs.append(PSBTInput(self.wally_psbt.inputs![i], network: network))
        }
        self.inputs = inputs
        var outputs: [PSBTOutput] = []
        for i in 0..<self.wally_psbt.outputs_allocation_len {
            outputs.append(PSBTOutput(self.wally_psbt.outputs, tx: self.wally_psbt.tx!.pointee, index: i, network: network))
        }
        self.outputs = outputs
    }
    
    public init (_ psbt: String, _ network: Network) throws {
        guard psbt.count != 0 else {
            throw ParseError.tooShort
        }
        
        guard let psbtData = Data(base64Encoded:psbt) else {
            throw ParseError.invalidBase64
        }
        
        try self.init(psbtData, network)
    }
    
    public var data: Data {
        var psbt = UnsafeMutablePointer<wally_psbt>.allocate(capacity: 1)
        psbt.initialize(to: self.wally_psbt)
        let len = 100000 // TODO: use psbt_get_length once it's public
        var bytes_out = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        var written = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        defer {
            psbt.deallocate()
            bytes_out.deallocate()
            written.deallocate()
        }
        precondition(wally_psbt_to_bytes(psbt, bytes_out, len, written) == WALLY_OK)
        return Data(bytes: bytes_out, count: written.pointee)
    }
    
    public var description: String {
        return data.base64EncodedString()
    }
    
    public var complete: Bool {
        // TODO: add function to libwally-core to check this directly
        return self.transaction != nil
    }
    
    public var transaction: Transaction? {
        var psbt = UnsafeMutablePointer<wally_psbt>.allocate(capacity: 1)
        psbt.initialize(to: self.wally_psbt)
        var output: UnsafeMutablePointer<wally_tx>?
        defer {
            psbt.deallocate()
            if let wally_tx = output {
                wally_tx.deallocate()
            }
        }
        guard wally_extract_psbt(psbt, &output) == WALLY_OK else {
            return nil
        }
        precondition(output != nil)
        return Transaction(output!.pointee)
    }
    
    public mutating func sign(_ privKey: Key) {
        var psbt = UnsafeMutablePointer<wally_psbt>.allocate(capacity: 1)
        psbt.initialize(to: self.wally_psbt)
        var key_bytes = UnsafeMutablePointer<UInt8>.allocate(capacity:Int(EC_PRIVATE_KEY_LEN))
        privKey.data.copyBytes(to: key_bytes, count: Int(EC_PRIVATE_KEY_LEN))
        defer {
           psbt.deallocate()
        }
        // TODO: sanity key for network
        precondition(wally_sign_psbt(psbt, key_bytes, Int(EC_PRIVATE_KEY_LEN)) == WALLY_OK)
    }
    
    public mutating func sign(_ hdKey: HDKey) {
        for input in self.inputs {
            if let origins: [PubKey : KeyOrigin] = input.canSign(hdKey) {
                for origin in origins {
                    if let childKey = try? hdKey.derive(origin.value.path) {
                        if let privKey = childKey.privKey {
                            precondition(privKey.pubKey == origin.key)
                            self.sign(privKey)
                        }
                    }
                }
            }
        }
    }
    
    public mutating func finalize() -> Bool {
        var psbt = UnsafeMutablePointer<wally_psbt>.allocate(capacity: 1)
        psbt.initialize(to: self.wally_psbt)
        defer {
            psbt.deallocate()
        }
        guard wally_finalize_psbt(psbt) == WALLY_OK else {
            return false
        }
        return true
    }
    
}
