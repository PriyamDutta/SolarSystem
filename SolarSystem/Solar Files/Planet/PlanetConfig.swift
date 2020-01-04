//
//  PlanetConfig.swift
//  SolarSystem
//
//  Created by Priyam Dutta on 05/01/20.
//  Copyright © 2020 Priyam Dutta. All rights reserved.
//

import Foundation
import UIKit

struct PlanetConfig {
    let id: String
    let radius: CGFloat
    let arcRadius: CGFloat
    let arcCenter: CGPoint
    let revolutionSpeed: CGFloat
    let orbitPath: UIBezierPath
    let isClockwise: Bool
    let color: UIColor
}
