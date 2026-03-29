import SwiftUI

struct FlashCardView: View {
    let word: Word
    @Binding var isRevealed: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Score band badge
            HStack {
                Label("TOEIC \(word.scoreBand)", systemImage: "chart.bar.fill")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(bandColor(word.scoreBand).opacity(0.2))
                    .foregroundColor(bandColor(word.scoreBand))
                    .clipShape(Capsule())

                Spacer()

                Text(word.importance)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(importanceColor(word.importance).opacity(0.2))
                    .foregroundColor(importanceColor(word.importance))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Spacer()

            // Word
            Text(word.word)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Spacer()

            Divider()
                .padding(.horizontal, 20)

            // Meaning & Example (revealed)
            if isRevealed {
                VStack(spacing: 12) {
                    Text(word.meaning)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                    Text(word.example)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .italic()
                }
                .padding(20)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.25)) {
                        isRevealed = true
                    }
                }) {
                    Label("意味を表示", systemImage: "eye.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(20)
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)
    }

    private func bandColor(_ band: Int) -> Color {
        switch band {
        case 500: return .green
        case 600: return .blue
        case 700: return .orange
        case 800: return .purple
        default:  return .red
        }
    }

    private func importanceColor(_ importance: String) -> Color {
        switch importance {
        case "必須": return .red
        case "重要": return .orange
        default:    return .gray
        }
    }
}
