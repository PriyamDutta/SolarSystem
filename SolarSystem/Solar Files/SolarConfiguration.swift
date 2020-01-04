//
//  SolarConfiguration.swift
//  SolarSystem
//
//  Created by Priyam Dutta on 05/01/20.
//  Copyright © 2020 Priyam Dutta. All rights reserved.
//

import Foundation
import UIKit

public protocol SolarViewProtocol: AnyObject {
    func didBeginTouchPlanet(planet: Planet)
    func didMovingPlanet(planet: Planet)
    func didFinishTouchPlanet(planet: Planet)
}

public struct SolarConfiguration {
    let planetsCount: Int
    let orbitColor: UIColor
    let orbitDistance: CGFloat
    let planets: [Planet]? = nil
}
