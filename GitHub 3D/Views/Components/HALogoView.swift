//
//  HAFreelanceMark.swift
//  GitHub App
//
//  The "HA" brand mark from the profile artwork, drawn as vector shapes.
//

import SwiftUI

// MARK: - Letters

private struct HGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        // Left stem
        path.addRect(CGRect(x: 0.06 * w, y: 0.12 * h, width: 0.16 * w, height: 0.76 * h))
        // Right stem
        path.addRect(CGRect(x: 0.36 * w, y: 0.12 * h, width: 0.16 * w, height: 0.76 * h))
        // Crossbar
        path.addRect(CGRect(x: 0.06 * w, y: 0.44 * h, width: 0.46 * w, height: 0.16 * h))

        return path
    }
}

private struct ALetterShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        path.move(to: CGPoint(x: 0.70 * w, y: 0.10 * h))
        path.addLine(to: CGPoint(x: 0.47 * w, y: 0.90 * h))
        path.addLine(to: CGPoint(x: 0.93 * w, y: 0.90 * h))
        path.closeSubpath()

        return path
    }
}

private struct AAccentShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        path.move(to: CGPoint(x: 0.675 * w, y: 0.32 * h))
        path.addLine(to: CGPoint(x: 0.545 * w, y: 0.74 * h))
        path.addLine(to: CGPoint(x: 0.625 * w, y: 0.74 * h))
        path.closeSubpath()

        return path
    }
}

// MARK: - Mark

struct HAFreelanceMark: View {
    var size: CGFloat = 72

    private let navy = Color(hex: 0x141A2E)

    var body: some View {
        ZStack {
            HGlyph().fill(navy)
            ALetterShape().fill(navy)
            AAccentShape().fill(Color(hex: 0x5A3DD3))

            HGlyph()
                .stroke(Color.white, lineWidth: 1.6)
            ALetterShape()
                .stroke(Color.white, lineWidth: 1.6)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
