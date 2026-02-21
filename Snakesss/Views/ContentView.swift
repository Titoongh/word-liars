import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.10, blue: 0.06)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("🐍")
                    .font(.system(size: 72))

                Text("Snakesss")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.24, green: 0.73, blue: 0.42))

                Text("TRUST NOBODY")
                    .font(.system(.caption2, design: .rounded).weight(.bold))
                    .foregroundStyle(Color(red: 0.48, green: 0.62, blue: 0.50))
                    .kerning(3)
            }
        }
    }
}

#Preview {
    ContentView()
}
