//
//  DescriptorTests.swift
//  DescriptorTests
//
//  Created by Sjors Provoost on 24/01/2022.
//  Copyright © 2022 Sjors Provoost. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import XCTest
@testable import LibWally

class DescriptorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testChecksum() throws {
        XCTAssertThrowsError(try Descriptor("pkh([3442193e/0']xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw/1)", .mainnet)) { error in
            XCTAssertEqual(error as! DescriptorError, DescriptorError.invalid)
        }
        
        XCTAssertNoThrow(try Descriptor("pkh([3442193e/0']xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw/1)#62cpuxwx", .mainnet))
        
        XCTAssertThrowsError(try Descriptor("pkh([3442193e/0']xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw/1)#00000000", .mainnet)) { error in
            XCTAssertEqual(error as! DescriptorError, DescriptorError.invalid)
        }
    }
    
    func testAddress() throws {
        let desc = try! Descriptor("pkh([3442193e/0']xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw/1)#62cpuxwx", .mainnet)
        XCTAssertEqual(try! desc.getAddress().description, "1JQheacLPdM5ySCkrZkV66G2ApAXe1mqLj")
    }
    
    func testAddressFromRange() throws {
        let desc = try! Descriptor("pkh([3442193e/0']xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw/*)#p44786lk", .mainnet)
        XCTAssertEqual(try! desc.getAddress(1).description, "1JQheacLPdM5ySCkrZkV66G2ApAXe1mqLj")
    }
    
    func testMatchingNetwork() throws {        
        XCTAssertThrowsError(try Descriptor("pkh([3442193e/0']xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw/1)#62cpuxwx", .testnet)) { error in
            XCTAssertEqual(error as! DescriptorError, DescriptorError.invalid)
        }
    }

    func testNonAddressDescriptor() throws {
        let desc = try! Descriptor("pk([3442193e/0']xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw/1)#397dme97", .mainnet)
        
        XCTAssertThrowsError(try desc.getAddress()) { error in
            // TODO: have it throw noAddress
            XCTAssertEqual(error as! DescriptorError, DescriptorError.invalid)
        }
        
    }
    
    func testIndexForNonRangedDescriptor() throws {
        let desc = try! Descriptor("pkh([3442193e/0']xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw/1)#62cpuxwx", .mainnet)
        
        XCTAssertThrowsError(try desc.getAddress(2)) { error in
            XCTAssertEqual(error as! DescriptorError, DescriptorError.notRanged)
        }
    }
    
    func testMissingIndexForRangedDescriptor() throws {
        let desc = try! Descriptor("pkh([3442193e/0']xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw/*)#p44786lk", .mainnet)
        
        XCTAssertThrowsError(try desc.getAddress()) { error in
            XCTAssertEqual(error as! DescriptorError, DescriptorError.ranged)
        }
    }
    
}
