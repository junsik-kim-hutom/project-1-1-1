#!/usr/bin/swift

import AppKit
import Foundation

struct IconTarget {
  let path: String
  let size: Int
}

func color(hex: UInt32) -> NSColor {
  let r = CGFloat((hex >> 16) & 0xFF) / 255.0
  let g = CGFloat((hex >> 8) & 0xFF) / 255.0
  let b = CGFloat(hex & 0xFF) / 255.0
  return NSColor(calibratedRed: r, green: g, blue: b, alpha: 1.0)
}

func tintedSymbol(name: String, pointSize: CGFloat, color: NSColor) -> NSImage? {
  guard let symbol = NSImage(systemSymbolName: name, accessibilityDescription: nil) else { return nil }
  let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .regular)
  guard let configured = symbol.withSymbolConfiguration(config) else { return nil }

  let img = NSImage(size: configured.size)
  img.lockFocus()
  let rect = NSRect(origin: .zero, size: configured.size)
  configured.draw(in: rect)
  color.set()
  rect.fill(using: .sourceAtop)
  img.unlockFocus()
  return img
}

func renderIcon(size: Int) -> NSImage {
  let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
    let start = CGPoint(x: rect.minX, y: rect.maxY)
    let end = CGPoint(x: rect.maxX, y: rect.minY)
    let gradient = NSGradient(colors: [color(hex: 0xFF6B6B), color(hex: 0xFFB86B)])!
    gradient.draw(from: start, to: end, options: [])

    let pad = CGFloat(size) * 0.18
    let symbolRect = rect.insetBy(dx: pad, dy: pad)
    if let sparkle = tintedSymbol(name: "sparkles", pointSize: symbolRect.height * 0.78, color: .white) {
      let drawSize = sparkle.size
      let drawRect = NSRect(
        x: symbolRect.midX - drawSize.width / 2,
        y: symbolRect.midY - drawSize.height / 2,
        width: drawSize.width,
        height: drawSize.height
      )
      sparkle.draw(in: drawRect, from: .zero, operation: .sourceOver, fraction: 1.0)
    } else {
      // Fallback: simple star shape
      let path = NSBezierPath()
      let cx = symbolRect.midX
      let cy = symbolRect.midY
      let rOuter = min(symbolRect.width, symbolRect.height) * 0.34
      let rInner = rOuter * 0.42
      for i in 0..<10 {
        let angle = (CGFloat(i) * .pi / 5) - (.pi / 2)
        let r = (i % 2 == 0) ? rOuter : rInner
        let p = CGPoint(x: cx + cos(angle) * r, y: cy + sin(angle) * r)
        if i == 0 { path.move(to: p) } else { path.line(to: p) }
      }
      path.close()
      NSColor.white.setFill()
      path.fill()
    }
    return true
  }
  return image
}

func renderSplashMark(size: Int) -> NSImage {
  let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
    NSColor.clear.setFill()
    rect.fill()

    let symbolRect = rect.insetBy(dx: CGFloat(size) * 0.10, dy: CGFloat(size) * 0.10)
    if let sparkle = tintedSymbol(name: "sparkles", pointSize: symbolRect.height * 0.82, color: .white) {
      let drawSize = sparkle.size
      let drawRect = NSRect(
        x: symbolRect.midX - drawSize.width / 2,
        y: symbolRect.midY - drawSize.height / 2,
        width: drawSize.width,
        height: drawSize.height
      )
      sparkle.draw(in: drawRect, from: .zero, operation: .sourceOver, fraction: 1.0)
    }
    return true
  }
  return image
}

func pngData(from image: NSImage) -> Data? {
  guard let tiff = image.tiffRepresentation else { return nil }
  guard let rep = NSBitmapImageRep(data: tiff) else { return nil }
  return rep.representation(using: .png, properties: [:])
}

func writePng(_ image: NSImage, to path: String) throws {
  guard let data = pngData(from: image) else {
    throw NSError(domain: "icon", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode PNG"])
  }
  let url = URL(fileURLWithPath: path)
  try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
  try data.write(to: url, options: .atomic)
}

let root = FileManager.default.currentDirectoryPath

let androidTargets: [IconTarget] = [
  .init(path: "\(root)/android/app/src/main/res/mipmap-mdpi/ic_launcher.png", size: 48),
  .init(path: "\(root)/android/app/src/main/res/mipmap-hdpi/ic_launcher.png", size: 72),
  .init(path: "\(root)/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png", size: 96),
  .init(path: "\(root)/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png", size: 144),
  .init(path: "\(root)/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png", size: 192),
]

let androidSplashTargets: [IconTarget] = [
  .init(path: "\(root)/android/app/src/main/res/drawable/splash_icon.png", size: 256),
]

let iosTargets: [IconTarget] = [
  .init(path: "\(root)/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png", size: 20),
  .init(path: "\(root)/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png", size: 40),
  .init(path: "\(root)/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png", size: 60),
  .init(path: "\(root)/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png", size: 29),
  .init(path: "\(root)/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png", size: 58),
  .init(path: "\(root)/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png", size: 87),
  .init(path: "\(root)/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png", size: 40),
  .init(path: "\(root)/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png", size: 80),
  .init(path: "\(root)/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png", size: 120),
  .init(path: "\(root)/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png", size: 120),
  .init(path: "\(root)/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png", size: 180),
  .init(path: "\(root)/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png", size: 76),
  .init(path: "\(root)/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png", size: 152),
  .init(path: "\(root)/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png", size: 167),
  .init(path: "\(root)/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png", size: 1024),
]

let targets = androidTargets + androidSplashTargets + iosTargets

for t in targets {
  let image: NSImage
  if t.path.hasSuffix("/android/app/src/main/res/drawable/splash_icon.png") {
    image = renderSplashMark(size: t.size)
  } else {
    image = renderIcon(size: t.size)
  }
  try writePng(image, to: t.path)
  print("✅ wrote \(t.size)x\(t.size) -> \(t.path.replacingOccurrences(of: root + "/", with: ""))")
}
