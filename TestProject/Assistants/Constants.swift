//
//  Constants.swift
//  TestProject
//
//  Created by Timur Kadiev on 02.10.2024.
//

import Foundation
import UIKit

struct Constants {
    static let paddingHorizontal = Device.iPhone ? 16.0 : 40.0
    static let paddingVertical = Device.iPhone ? 10.0 : 20.0
    static let paddingOnAlert = Device.iPhone ? 20.0 : 80.0
    static let padding = Device.iPhone ? 8.0 : 16.0
    static let paddingItems = Device.iPhone ? 5.0 : 10.0
    
    static let textСontinued = "Читать подробнее"
    
}

enum Device {
    static var iPhone: Bool {
        guard UIDevice().userInterfaceIdiom == .phone else {
                return false
        }
        return true
    }
}

enum ScreenSize {
    static var width = UIScreen.main.bounds.size.width
    static var height = UIScreen.main.bounds.size.height
}
