//
//  PSBT.swift
//  PSBT 
//
//  Created by Sjors Provoost on 16/12/2019.
//  Copyright © 2019 Sjors Provoost. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import CLibWally

public struct PSBT {

    enum ParseError: Error {
        case tooShort
        case invalidBase64
        case invalid
    }
    
    let wally_psbt: wally_psbt
    
    public init (_ psbt: Data) throws {
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
        self.wally_psbt = output!.pointee
    }
    
    public init (_ psbt: String) throws {
        guard psbt.count != 0 else {
            throw ParseError.tooShort
        }
        
        guard let psbtData = Data(base64Encoded:psbt) else {
            throw ParseError.invalidBase64
        }
        
        try self.init(psbtData)
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
    
}
