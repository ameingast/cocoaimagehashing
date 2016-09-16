import Cocoa
import CocoaImageHashing

let imageHashing = OSImageHashing.sharedInstance()

// Image Comparison

if let lhs = NSImage(named: "blurred_architecture1.bmp"), let rhs = NSImage(named: "compressed_architecture1.jpg") {
    let lhsHash = imageHashing.hashImage(lhs, with: .dHash)
    let rhsHash = imageHashing.hashImage(rhs, with: .dHash)
    let distance = imageHashing.hashDistance(lhsHash, to: rhsHash, with: .dHash)
    print("Similar : ", distance < imageHashing.hashDistanceSimilarityThreshold(withProvider: .dHash))
}
