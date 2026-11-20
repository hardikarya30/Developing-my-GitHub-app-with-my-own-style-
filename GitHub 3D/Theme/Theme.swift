//
//  Theme.swift
//  GitHub 3D
//
//  Colours, glass surfaces and press feedback shared by every screen.
//

import SwiftUI
import UIKit

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

enum Palette {
    /// The app canvas.
    static let canvas = Color(hex: 0x3B35AF)
    static let canvasTop = Color(hex: 0x4A43C4)
    static let canvasDeep = Color(hex: 0x1B1468)

    /// The background for webpage surfaces and sections.
    static let webpageBackground = Color(hex: 0x32288C)
    static let surface = webpageBackground

    /// The background used behind app icons.
    static let iconBackground = Color(hex: 0x9DACFB)

    /// Violet accents.
    static let accent = Color(hex: 0x5A3DD3)
    static let accentBright = Color(hex: 0x8B5CF6)
    static let gradientStart = Color(hex: 0x3100F6)
    static let gradientEnd = Color(hex: 0x32288C)

    /// Type.
    static let ink = Color.white
    static let inkMuted = Color(hex: 0xC7C2F2)
    static let inkFaint = Color(hex: 0x9E98DC)

    /// Lines.
    static let hairline = Color.white.opacity(0.10)
    static let hairlineStrong = Color.white.opacity(0.18)
}

// MARK: - Backdrop

struct AppBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Palette.canvasTop, Palette.canvas, Palette.canvasDeep],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [Palette.accentBright.opacity(0.45), .clear],
                center: UnitPoint(x: 0.08, y: 0.02),
                startRadius: 0,
                endRadius: 360
            )

            RadialGradient(
                colors: [Palette.accent.opacity(0.40), .clear],
                center: UnitPoint(x: 0.95, y: 0.45),
                startRadius: 0,
                endRadius: 320
            )

            RadialGradient(
                colors: [Palette.gradientStart.opacity(0.30), .clear],
                center: UnitPoint(x: 0.45, y: 1.02),
                startRadius: 0,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Glass surface

private struct GlassCardModifier: ViewModifier {
    var fill: Color
    var radius: CGFloat
    var glow: Bool

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(fill)
                    .overlay {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.14), .white.opacity(0.02), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.30), .white.opacity(0.07), .white.opacity(0.16)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: Color(hex: 0x140D4D).opacity(0.55), radius: 24, x: 0, y: 16)
            .shadow(color: glow ? Palette.accentBright.opacity(0.22) : .clear, radius: 18, x: 0, y: 8)
    }
}

extension View {
    func glassCard(fill: Color = Palette.surface, radius: CGFloat = 28, glow: Bool = false) -> some View {
        modifier(GlassCardModifier(fill: fill, radius: radius, glow: glow))
    }
}

// MARK: - Press feedback

struct PressableStyle: ButtonStyle {
    var scale: CGFloat = 0.975

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .brightness(configuration.isPressed ? 0.05 : 0)
            .shadow(
                color: Palette.accentBright.opacity(configuration.isPressed ? 0.45 : 0),
                radius: configuration.isPressed ? 22 : 0
            )
            .animation(.spring(response: 0.32, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    static func select() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}


// MARK: - Light glass surface

private struct LightGlassModifier: ViewModifier {
    var fill: Color
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(fill)
                    .overlay {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.55), .white.opacity(0.0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.85), lineWidth: 1)
            }
            .shadow(color: Color(hex: 0x1B2A55).opacity(0.10), radius: 18, x: 0, y: 10)
    }
}

extension View {
    func lightGlass(fill: Color = .white, radius: CGFloat = 28) -> some View {
        modifier(LightGlassModifier(fill: fill, radius: radius))
    }
}
