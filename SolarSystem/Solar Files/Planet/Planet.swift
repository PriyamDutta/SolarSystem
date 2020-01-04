//
//  Planet.swift
//
//  Created by Priyam Dutta on 28/12/19.
//

import UIKit

final public class Planet: UIControl {
    
    public var planetId: String!
    private let duration: Double = 5.0
    private var percent: Double = 0.0
    private var displayLink: CADisplayLink?
    private var start: CFAbsoluteTime?
    private var arcCenter: CGPoint!
    private var radius: CGFloat!
    private var arcRadius: CGFloat!
    private var dynamicFactor: Double = 0.0
    private var didRevolvingStarted: Bool = false
    private var isClockwise: Bool = true
    private var touchEvents: (didBegan: Bool, didEnd: Bool) = (false, true)
    private var orbitPath: UIBezierPath!
    private var isUpperHem = false
    
    weak var delegate: SolarViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = frame.width / 2.0
        self.isUserInteractionEnabled = true
    }
    
    convenience init(withPlanet configuration: PlanetConfig) {
        self.init(frame: CGRect(x: 0.0, y: 0.0, width: configuration.radius, height: configuration.radius))
        self.planetId = configuration.id
        self.radius = configuration.radius
        self.arcCenter = configuration.arcCenter
        self.arcRadius = configuration.arcRadius
        self.orbitPath = configuration.orbitPath
        self.isClockwise = configuration.isClockwise
        self.backgroundColor = configuration.color
        self.alpha = 0.0
        self.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.placePlanetInOrbit()
            self?.presentingPlanet()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deinit: \(self.tag)")
    }
}

typealias CoordinatePlacing = Planet
extension CoordinatePlacing {
    
    private func presentingPlanet() {
        self.alpha = 1.0
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
            self.transform = .identity
        }) { (done) in
            self.startDisplayLink()
        }
    }
    
    private func placePlanetInOrbit() {
        dynamicFactor = drand48()
        let degree = CGFloat(dynamicFactor * 360.0).radian
        let xAxis = arcCenter.x + arcRadius! * cos(degree)
        let yAxis = arcCenter.y + arcRadius! * sin(degree)
        self.center = CGPoint(x: xAxis, y: yAxis)
    }
    
    private func revolvePlanet(withFactor factor: Double) {
        let degree = isClockwise ? CGFloat(factor * 360.0).radian : -CGFloat(factor * 360.0).radian
        let xAxis = arcCenter.x + arcRadius! * cos(degree)
        let yAxis = arcCenter.y + arcRadius! * sin(degree)
        self.center = CGPoint(x: xAxis, y: yAxis)
//        debugPrint(factor)
    }
}

typealias DisplayLink = Planet
extension DisplayLink {
    func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(displayLink:)))
        start = CFAbsoluteTimeGetCurrent() + (1.0 - percent) * duration
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc func handleDisplayLink(displayLink: CADisplayLink) {
        let elapsed = CFAbsoluteTimeGetCurrent() - start!
        percent = (elapsed.truncatingRemainder(dividingBy: duration)) / duration
        if dynamicFactor > 1.0 {
            dynamicFactor = 0.0
        }
        if touchEvents.didEnd {
            dynamicFactor += 0.002
            revolvePlanet(withFactor: fabs(dynamicFactor))
        }
    } 
}

typealias TouchHandle = Planet
extension TouchHandle {
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchEvents = (true, false)
        displayLink?.isPaused = true
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        }) { (done) in
        }
        delegate?.didBeginTouchPlanet(planet: self)
//        print("Touch Began")
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first?.location(in: self.superview);
        let earthX = Double(point!.x)
        let earthY = Double(point!.y)
        let midViewXDouble = Double(self.superview!.frame.midX)
        let midViewYDouble = Double(self.superview!.frame.minY)
        let angleX = (earthX - midViewXDouble)
        let angleY = (earthY - midViewYDouble)
        let angle = atan2(angleY, angleX)
        let earthX2 = Double(arcCenter.x) + cos(angle) * Double(arcRadius)
        let earthY2 = Double(arcCenter.y) + sin(angle) * Double(arcRadius)
        self.center = CGPoint(x: earthX2, y: earthY2)
        
        let dynamicAngleCos = acos((earthX2 - Double(arcCenter.x)) / Double(arcRadius))
        let dynamicAngleSin = asin((earthY2 - Double(arcCenter.y)) / Double(arcRadius))
        isUpperHem = CGFloat(dynamicAngleSin).degree < 0
        if isClockwise {
            if isUpperHem {
                dynamicFactor = 1 - Double(CGFloat(dynamicAngleCos).degree / 360.0)
            } else {
                dynamicFactor = Double(CGFloat(dynamicAngleCos).degree / 360.0)
            }
        } else {
            if isUpperHem {
                dynamicFactor = Double(CGFloat(dynamicAngleCos).degree / 360.0)
            } else {
                dynamicFactor = 1 - Double(CGFloat(dynamicAngleCos).degree / 360.0)
            }
        }
        dynamicFactor = fabs(dynamicFactor)
        delegate?.didMovingPlanet(planet: self)
//        print("Cos: \(CGFloat(dynamicAngleCos).radiansToDegree), Sin: \(CGFloat(dynamicAngleSin).radiansToDegree)")
//        print("Dynamic factor: \(dynamicFactor)")
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let degree = isClockwise ? CGFloat(dynamicFactor * 360.0).radian : -CGFloat(dynamicFactor * 360.0).radian
        let xAxis = arcCenter.x + arcRadius! * cos(degree)
        let yAxis = arcCenter.y + arcRadius! * sin(degree)
        self.center = CGPoint(x: xAxis, y: yAxis)
        touchEvents = (false, true)
        displayLink?.isPaused = false
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.transform = .identity
        }) { (done) in
        }
        delegate?.didFinishTouchPlanet(planet: self)
        print("Last Degree: \(degree)")
//        print("Touch Ended")
    }
}

extension CGFloat {
    var radian: CGFloat { return CGFloat(self) * .pi / 180 }
    var degree: CGFloat { return CGFloat(self) * 180 / .pi }
}

func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    let xDist = a.x - b.x
    let yDist = a.y - b.y
    return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
}
