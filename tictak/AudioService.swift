import Foundation
import AVFoundation

final class AudioService {
    private let session = AVAudioSession.sharedInstance()
    private var pools: [String: [AVAudioPlayer]] = [:]
    private var hold: AVAudioPlayer?
    private let queue = DispatchQueue(label: "AudioService.pool")

    init() {
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("AudioService: audio session error: \(error.localizedDescription)")
        }
    }

    func playSound(named fileName: String) {
        guard let url = url(for: fileName) else { return }
        fileName.contains("move") ? playPooled(file: fileName, url: url) : playOnce(url: url)
    }

    func stopNonMoveSounds() {
        DispatchQueue.main.async { [weak self] in
            self?.hold?.stop()
            self?.hold = nil
        }
    }
}

private extension AudioService {
    func url(for fileName: String) -> URL? {
        let parts = fileName.split(separator: ".", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return nil }
        return Bundle.main.url(forResource: parts[0], withExtension: parts[1])
    }

    func makePlayer(url: URL) throws -> AVAudioPlayer {
        let p = try AVAudioPlayer(contentsOf: url)
        p.prepareToPlay()
        p.currentTime = 0
        return p
    }

    func playOnMain(_ player: AVAudioPlayer) {
        DispatchQueue.main.async { player.play() }
    }

    func playPooled(file: String, url: URL) {
        queue.async { [weak self] in
            guard let self else { return }
            var pool = self.pools[file, default: []]
            if let p = pool.first(where: { !$0.isPlaying }) {
                p.currentTime = 0
                self.playOnMain(p)
                self.pools[file] = pool
                return
            }
            if let new = try? self.makePlayer(url: url) {
                self.playOnMain(new)
                pool.append(new)
                self.pools[file] = pool
            }
        }
    }

    func playOnce(url: URL) {
        if let p = try? makePlayer(url: url) {
            hold = p
            playOnMain(p)
        }
    }
}
