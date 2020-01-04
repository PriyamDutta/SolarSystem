//
//  ViewController.swift
//  SolarSystem
//
//  Created by Priyam Dutta on 04/01/20.
//  Copyright © 2020 Priyam Dutta. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SolarViewProtocol {
    
    private var solarSystem: SolarView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createSolarSystem()
    }

    private func createSolarSystem() {
        let config = SolarConfiguration(planetsCount: 8, orbitColor: .systemBlue, orbitDistance: 25)
        let solarSystem = SolarView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.width), configuration: config)
        solarSystem.center = self.view.center
        solarSystem.delegate = self
        solarSystem.backgroundColor = .black
        self.solarSystem = solarSystem
        self.view.addSubview(solarSystem)
    }
    
    /// MARK: `SolarViewProtocol` functions
    func didBeginTouchPlanet(planet: Planet) {
        print("Did touch: \(planet.tag)")
    }
    
    func didMovingPlanet(planet: Planet) {
        print("Did move: \(planet.tag)")
    }
    
    func didFinishTouchPlanet(planet: Planet) {
        print("Did finish: \(planet.tag)")
    }
}

