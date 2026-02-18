import AVFoundation

/// Generates simple square-wave tones matching the original Pascal Sound() calls.
/// Frequencies: Miss=300Hz, Wall=500Hz, Paddle=800Hz, Surprise=1000Hz
final class SoundManager {
    static let shared = SoundManager()

    private let engine = AVAudioEngine()
    private let sourceNode: AVAudioSourceNode
    private var currentFrequency: Double = 0
    private var phase: Double = 0
    private var isPlaying = false
    private let sampleRate: Double

    private init() {
        let outputFormat = engine.outputNode.outputFormat(forBus: 0)
        sampleRate = outputFormat.sampleRate

        var localPhase: Double = 0
        var localFreq: Double = 0

        sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let freq = localFreq
            let sr = outputFormat.sampleRate
            let increment = freq / sr

            for frame in 0..<Int(frameCount) {
                // Square wave: +0.15 or -0.15 (low volume to avoid harshness)
                let value: Float = localPhase < 0.5 ? 0.15 : -0.15
                localPhase += increment
                if localPhase >= 1.0 { localPhase -= 1.0 }
                for buffer in ablPointer {
                    let buf = buffer.mData!.assumingMemoryBound(to: Float.self)
                    buf[frame] = freq > 0 ? value : 0
                }
            }
            return noErr
        }

        // Capture references for the closure
        let node = sourceNode
        engine.attach(node)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.connect(node, to: engine.mainMixerNode, format: format)

        // Keep a way to update frequency from outside the closure
        self.frequencySetter = { freq in
            localFreq = freq
            localPhase = 0
        }

        do {
            try engine.start()
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }

    private var frequencySetter: ((Double) -> Void)?

    /// Play a tone at the given frequency for the given duration in milliseconds.
    func playTone(frequency: Double, durationMs: Int, enabled: Bool) {
        guard enabled else { return }
        frequencySetter?(frequency)

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(durationMs) / 1000.0) { [weak self] in
            self?.frequencySetter?(0)
        }
    }

    // Convenience methods matching original constants
    func miss(enabled: Bool)     { playTone(frequency: 300,  durationMs: 25, enabled: enabled) }
    func wall(enabled: Bool)     { playTone(frequency: 500,  durationMs: 10, enabled: enabled) }
    func paddle(enabled: Bool)   { playTone(frequency: 800,  durationMs: 15, enabled: enabled) }
    func surprise(enabled: Bool) { playTone(frequency: 1000, durationMs: 10, enabled: enabled) }
}
