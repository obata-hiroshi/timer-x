import SwiftUI

struct ContentView: View {
    @StateObject private var timer = CountdownTimer()
    @State private var isAlertPresented = false

    private let presetOptions: [(title: String, seconds: Int)] = [
        ("3分", 180),
        ("5分", 300),
        ("10分", 600),
        ("15分", 900)
    ]

    var body: some View {
        VStack(spacing: 48) {
            Spacer(minLength: 48)

            Text(timer.formattedTime)
                .font(.system(size: 80, weight: .semibold, design: .monospaced))
                .monospacedDigit()
                .kerning(2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)

            presetGrid

            startStopButton

            Spacer(minLength: 48)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 32)
        .background(Color(.systemBackground))
        .onChange(of: timer.state) { state in
            if state == .finished {
                isAlertPresented = true
            }
        }
        .alert("時間になりました", isPresented: $isAlertPresented) {
            Button("OK", role: .cancel) {
                isAlertPresented = false
            }
        }
    }

    private var presetGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 24),
            GridItem(.flexible(), spacing: 24)
        ]

        return LazyVGrid(columns: columns, spacing: 24) {
            ForEach(presetOptions, id: \.title) { option in
                presetButton(title: option.title, seconds: option.seconds)
            }
        }
    }

    private func presetButton(title: String, seconds: Int) -> some View {
        let isSelected = timer.selectedPresetSeconds == seconds && timer.state != .finished

        return Button {
            isAlertPresented = false
            timer.applyPreset(seconds: seconds)
        } label: {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? Color.white : Color.accentColor)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(isSelected ? Color.accentColor : Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }

    private var startStopButton: some View {
        Button(timer.startStopButtonTitle) {
            timer.toggleStartStop()
        }
        .font(.title3.weight(.semibold))
        .frame(maxWidth: .infinity, minHeight: 64)
        .foregroundColor(.white)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.accentColor)
        )
        .shadow(color: Color.accentColor.opacity(0.24), radius: 14, y: 8)
        .buttonStyle(.plain)
        .accessibilityIdentifier("startStopButton")
    }
}

#Preview {
    ContentView()
}
