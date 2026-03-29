import Foundation

class WordStore: ObservableObject {
    @Published var allWords: [Word] = []
    @Published var currentIndex: Int = 0
    @Published var selectedScoreBand: Int? = nil

    var filteredWords: [Word] {
        guard let band = selectedScoreBand else { return allWords }
        return allWords.filter { $0.scoreBand == band }
    }

    var currentWord: Word? {
        guard !filteredWords.isEmpty else { return nil }
        return filteredWords[currentIndex]
    }

    var availableScoreBands: [Int] {
        Array(Set(allWords.map { $0.scoreBand })).sorted()
    }

    init() {
        loadWords()
    }

    func loadWords() {
        guard let url = Bundle.main.url(forResource: "words", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Word].self, from: data)
        else { return }
        allWords = decoded
        currentIndex = 0
    }

    func next() {
        guard !filteredWords.isEmpty else { return }
        currentIndex = (currentIndex + 1) % filteredWords.count
    }

    func previous() {
        guard !filteredWords.isEmpty else { return }
        currentIndex = (currentIndex - 1 + filteredWords.count) % filteredWords.count
    }

    func shuffle() {
        // Shuffle by picking a random next index
        guard filteredWords.count > 1 else { return }
        var next: Int
        repeat {
            next = Int.random(in: 0..<filteredWords.count)
        } while next == currentIndex
        currentIndex = next
    }

    func setScoreBand(_ band: Int?) {
        selectedScoreBand = band
        currentIndex = 0
    }
}
