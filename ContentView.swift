import SwiftUI

struct ContentView: View {
    @StateObject private var store = WordStore()
    @State private var isRevealed = false
    @State private var dragOffset: CGFloat = 0
    @State private var cardOpacity: Double = 1.0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(label: "全て", isSelected: store.selectedScoreBand == nil) {
                            store.setScoreBand(nil)
                            resetCard()
                        }
                        ForEach(store.availableScoreBands, id: \.self) { band in
                            FilterChip(label: "\(band)点", isSelected: store.selectedScoreBand == band) {
                                store.setScoreBand(band)
                                resetCard()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .background(Color(.secondarySystemBackground))

                // Progress
                if let word = store.currentWord {
                    HStack {
                        Text("\(store.currentIndex + 1) / \(store.filteredWords.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("No.\(word.id)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }

                Spacer()

                // Flashcard
                if let word = store.currentWord {
                    FlashCardView(word: word, isRevealed: $isRevealed)
                        .padding(.horizontal, 20)
                        .offset(x: dragOffset)
                        .opacity(cardOpacity)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation.width * 0.4
                                }
                                .onEnded { value in
                                    let threshold: CGFloat = 80
                                    if value.translation.width < -threshold {
                                        animateTransition(direction: .forward)
                                    } else if value.translation.width > threshold {
                                        animateTransition(direction: .backward)
                                    } else {
                                        withAnimation(.spring()) { dragOffset = 0 }
                                    }
                                }
                        )
                } else {
                    Text("単語がありません")
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Navigation buttons
                HStack(spacing: 20) {
                    NavButton(icon: "arrow.left", label: "前へ") {
                        animateTransition(direction: .backward)
                    }

                    NavButton(icon: "shuffle", label: "ランダム") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            cardOpacity = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            store.shuffle()
                            resetCard()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                cardOpacity = 1
                            }
                        }
                    }

                    NavButton(icon: "arrow.right", label: "次へ") {
                        animateTransition(direction: .forward)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .navigationTitle("英単語学習")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
    }

    private enum Direction { case forward, backward }

    private func animateTransition(direction: Direction) {
        let slideOut: CGFloat = direction == .forward ? -400 : 400
        let slideIn: CGFloat = direction == .forward ? 400 : -400

        withAnimation(.easeIn(duration: 0.18)) {
            dragOffset = slideOut
            cardOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            if direction == .forward { store.next() } else { store.previous() }
            dragOffset = slideIn
            withAnimation(.easeOut(duration: 0.18)) {
                dragOffset = 0
                cardOpacity = 1
            }
            isRevealed = false
        }
    }

    private func resetCard() {
        isRevealed = false
        dragOffset = 0
        cardOpacity = 1
    }
}

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.tertiarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

struct NavButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .foregroundColor(.primary)
    }
}
