//
//  ScanData.swift
//  Scanner
//
//  Created by BERKAN NALBANT on 14.01.2023.
//

import Foundation

struct ScanData : Identifiable{
    var id = UUID()

    let content : String
    
    init( content: String) {
        self.content = content
       
    }
}

