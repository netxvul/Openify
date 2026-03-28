import SwiftUI

struct LiquidGlassCard: ViewModifier {
    var cornerRadius: CGFloat = 16
    var tint: Color = .white
    var borderOpacity: Double = 0.38

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        tint.opacity(0.30),
                                        tint.opacity(0.08),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(borderOpacity), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 10)
            )
    }
}

extension View {
    func liquidGlassCard(
        cornerRadius: CGFloat = 16,
        tint: Color = .white,
        borderOpacity: Double = 0.38
    ) -> some View {
        modifier(
            LiquidGlassCard(
                cornerRadius: cornerRadius,
                tint: tint,
                borderOpacity: borderOpacity
            )
        )
    }
}

struct LiquidGlassBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.20, green: 0.31, blue: 0.43),
                    Color(red: 0.07, green: 0.11, blue: 0.17),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(Color.cyan.opacity(0.35))
                .frame(width: 420, height: 420)
                .blur(radius: 48)
                .offset(x: -230, y: -180)
            Circle()
                .fill(Color.blue.opacity(0.28))
                .frame(width: 360, height: 360)
                .blur(radius: 46)
                .offset(x: 260, y: -120)
            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 280, height: 280)
                .blur(radius: 40)
                .offset(x: 180, y: 260)
        }
        .ignoresSafeArea()
    }
}
