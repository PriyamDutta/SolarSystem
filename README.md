# Solar System
A planetary animated UI with intractable planets in their respective orbits.

![alt tag](https://github.com/PriyamDutta/SolarSystem/blob/master/Screenshots/Planets.gif)

### Configure SolarView
```swift
public struct SolarConfiguration {
    let planetsCount: Int
    let orbitColor: UIColor
    let orbitDistance: CGFloat
    let planets: [Planet]? = nil
}
```

### Delegation
```swift
public protocol SolarViewDelegate: AnyObject {
    func didBeginTouchPlanet(planet: Planet)
    func didMovingPlanet(planet: Planet)
    func didFinishTouchPlanet(planet: Planet)
}
```

### Configure Planet
```swift
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
```

### Initilization
```swift
func createSolarSystem() {
        let config = SolarConfiguration(planetsCount: 8, orbitColor: .systemBlue, orbitDistance: 25)
        let solarView = SolarView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.width), configuration: config)
        solarView.center = self.view.center
        solarView.delegate = self
        solarView.backgroundColor = .black
        self.solarView = solarView
        self.view.addSubview(solarView)
    }
```

### Deallocation
```swift
self.solarView.destroy()
```
