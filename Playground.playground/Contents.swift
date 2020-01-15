import Cocoa
import CocoaImageHashing

let imageHashing = OSImageHashing.sharedInstance()

// Image Comparison using dHash

let lhs = NSImage(named: NSImage.Name("blurred_architecture1.bmp"))!
let rhs = NSImage(named: NSImage.Name("compressed_architecture1.jpg"))!
let lhsHash = imageHashing.hashImage(lhs, with: .dHash)
let rhsHash = imageHashing.hashImage(rhs, with: .dHash)
let distance = imageHashing.hashDistance(lhsHash, to: rhsHash, with: .dHash)
print("Similar : ", distance < imageHashing.hashDistanceSimilarityThreshold(withProvider: .dHash))

// Similarity search using pHash

var names = ["blurred_architecture1.bmp",
             "compressed_architecture1.jpg",
             "blurred_architecture_2.bmp",
             "compressed_architecture_2.jpg"]
let similarImages = imageHashing.similarImages(withProvider: .pHash) {
    if names.count > 0 {
        let name = names.removeFirst()
        let url = Bundle.main.urlForImageResource(NSImage.Name(name))!
        let data = try! Data(contentsOf: url)
        return OSTuple<NSString, NSData>(first: name as NSString,
                                         andSecond: data as NSData)
    } else {
        return nil
    }
}
print("Similar Images", similarImages)
