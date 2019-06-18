//
//  Transaction.swift
//  Transaction 
//
//  Created by Sjors Provoost on 18/06/2019.
//  Copyright © 2019 Blockchain. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation

struct Transaction {
    let hash: Data
    
    init? (_ description: String) {
        if description.count == 64 { // Transaction hash
            if let hash = Data(description) {
                self.hash = hash
            } else {
                return nil
            }
        } else { // Transaction hex
            return nil
        }

    }

}
