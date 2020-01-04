//
//  SolarSystem.swift
//
//  Created by Priyam Dutta on 28/12/19.
//  Copyright © 2019 Priyam Dutta. All rights reserved.
//

import UIKit

final public class SolarView: UIView {
    
    public var orbits: [UIBezierPath] = []
    public var planets: [Planet] = []
    public weak var delegate: SolarViewDelegate?
    
    private var didOrbitCreated = false
    private var configuration: SolarConfiguration!
    
    public convenience init(frame: CGRect,
                            configuration: SolarConfiguration) {
        self.init(frame: frame)
        self.configuration = configuration
        self.createLayout()
    }
    
    public func destroy() {
        self.planets.forEach { (planet) in
            planet.stopDisplayLink()
        }
    }
    
    deinit {
        print("Deinit solarView")
    }
    
    private func createLayout() {
        for index in 1...configuration.planetsCount {
            drawOrbits(withRadius: CGFloat(index) * configuration.orbitDistance,
                       andCenter: CGPoint(x: self.bounds.width / 2.0,
                                          y: self.bounds.height / 2.0))
        }
    }
    
    private func drawOrbits(withRadius radius: CGFloat,
                            andCenter center: CGPoint) {
        let circleBezier = UIBezierPath()
        circleBezier.addArc(withCenter: center, radius: radius, startAngle: CGFloat(0).radian, endAngle: CGFloat(360).radian, clockwise: true)
        orbits.append(circleBezier)
        self.layer.addSublayer(addShapeLayer(lineWidth: 2.0, path: circleBezier.cgPath, keyPath: "circle"))
    }
    
    private func addShapeLayer(lineWidth: CGFloat,
                               path: CGPath,
                               keyPath: String) -> CAShapeLayer {
        let shapeLayer1 = CAShapeLayer()
        shapeLayer1.lineWidth = lineWidth
        shapeLayer1.strokeColor = configuration.orbitColor.cgColor
        shapeLayer1.fillColor = UIColor.clear.cgColor
        shapeLayer1.path = path
        shapeLayer1.strokeStart = 0
        shapeLayer1.strokeEnd = 1
        shapeLayer1.lineCap = .round
        self.addBasicAnimation(keyPath: keyPath, layer: shapeLayer1)
        return shapeLayer1
    }
    
    private func addBasicAnimation(keyPath: String,
                                   layer: CAShapeLayer) {
        let linearAnimate = CABasicAnimation(keyPath: "strokeEnd")
        linearAnimate.duration = 3.0
        linearAnimate.fromValue = 0
        linearAnimate.toValue = 1
        linearAnimate.repeatCount = 1
        linearAnimate.autoreverses = false;
        linearAnimate.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        linearAnimate.fillMode = .forwards
        linearAnimate.delegate = self
        linearAnimate.setValue(keyPath, forKey: "id")
        layer.add(linearAnimate, forKey: "linear")
    }
    
    private func assignPlanetsToOrbits(withPlanets planets: [UIView]?) {
        guard let planets = planets, !planets.isEmpty else { return }
        for (index, planet) in planets.enumerated() {
            let planetAnimate = CAKeyframeAnimation()
            planetAnimate.keyPath = "position"
            planetAnimate.beginTime = CFTimeInterval(arc4random_uniform(100))
            planetAnimate.path = orbits[index].cgPath
            planetAnimate.speed = index % 2 == 0 ? 2 : 1
            planetAnimate.duration = index % 2 == 0 ? 4.0 : 5.0
            planetAnimate.rotationMode = .rotateAuto
            planetAnimate.tensionValues = [-1, 1]
            planetAnimate.continuityValues = [0, -1]
            planetAnimate.biasValues = [1, -1]
            planetAnimate.autoreverses = false
            planetAnimate.repeatCount = 0//Float.infinity
            planetAnimate.timingFunction = CAMediaTimingFunction(name: .linear)
            planetAnimate.fillMode = .forwards
            planetAnimate.isRemovedOnCompletion = false
            planet.layer.add(planetAnimate, forKey: "imageAnimate")
        }
    }
}

typealias AnimationProtocols = SolarView
extension AnimationProtocols: CAAnimationDelegate {
    
    public func animationDidStart(_ anim: CAAnimation) {}
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !didOrbitCreated {
            if let planets = configuration.planets {
                self.planets = planets
            } else {
                self.planets = makePlanets(withDiameter: 20.0, totalNumber: configuration.planetsCount)
            }
            didOrbitCreated = true
        }
    }
}

typealias Planets = SolarView
extension Planets {
    
    private func makePlanets(withDiameter diameter: CGFloat, totalNumber: Int) -> [Planet] {
        guard totalNumber > 0 else { return [] }
        var planets = [Planet]()
        for index in 1...totalNumber {
            let planetStruct = PlanetConfig(id: UUID().uuidString,
                                            radius: 20.0,
                                            arcRadius: CGFloat(index) * configuration.orbitDistance,
                                            arcCenter: CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0),
                                            revolutionSpeed: 2.0,
                                            orbitPath: orbits[index - 1],
                                            isClockwise: true,
                                            color: UIColor(hue: CGFloat(drand48()), saturation: CGFloat(drand48()), brightness: 1, alpha: 1))
            let planet = Planet(withPlanet: planetStruct)
            planet.tag = index
            planet.delegate = self.delegate
            planets.append(planet)
            self.addSubview(planet)
        }
        return planets
    }
}

