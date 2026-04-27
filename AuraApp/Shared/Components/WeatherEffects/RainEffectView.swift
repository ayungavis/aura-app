//
//  RainEffectView.swift
//  AuraApp
//
//  High-performance rain particle system using Canvas + TimelineView.
//  Canvas is Metal-backed, so this runs on the GPU.
//
//  Architecture: A reference-type ParticleSystem holds the mutable state.
//  TimelineView drives the animation loop. Canvas reads the particles
//  and draws them — no @State mutation inside the draw closure.
//

import SwiftUI

/// Observable particle system that manages rain drop positions.
/// Using a class (reference type) so Canvas can read particles
/// without triggering SwiftUI state invalidation loops.
private class RainParticleSystem {
    struct Drop {
        var x: CGFloat
        var y: CGFloat
        var length: CGFloat
        var speed: CGFloat
        var opacity: CGFloat
        var thickness: CGFloat
    }
    
    var drops: [Drop] = []
    var lastUpdate: Date?
    private let dropCount = 60
    
    func update(date: Date, in size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        
        // Initialize drops on first frame
        if drops.isEmpty {
            drops = (0..<dropCount).map { _ in
                makeDrop(in: size, randomizeY: true)
            }
            lastUpdate = date
            return
        }
        
        // Calculate delta time for frame-rate-independent movement
        let dt = lastUpdate.map { date.timeIntervalSince($0) } ?? 0
        lastUpdate = date
        
        // Cap dt to prevent huge jumps (e.g. when app comes from background)
        let clampedDt = min(dt, 0.05)
        
        for i in drops.indices {
            // Move drops downward
            drops[i].y += drops[i].speed * clampedDt * 60
            
            // Fade out as the drop reaches the lower portion of the visible area
            let fadeStart = size.height * 0.35
            let fadeEnd = size.height * 0.65
            if drops[i].y > fadeStart {
                let progress = (drops[i].y - fadeStart) / (fadeEnd - fadeStart)
                drops[i].opacity = max(0, drops[i].opacity * (1.0 - progress))
            }
            
            // Reset drop when it's invisible or past the screen
            if drops[i].y > size.height || drops[i].opacity <= 0.01 {
                drops[i] = makeDrop(in: size, randomizeY: false)
            }
        }
    }
    
    private func makeDrop(in size: CGSize, randomizeY: Bool) -> Drop {
        Drop(
            x: CGFloat.random(in: 0...size.width),
            y: randomizeY ? CGFloat.random(in: -size.height * 0.5...size.height * 0.3) : CGFloat.random(in: -80 ... -10),
            length: CGFloat.random(in: 12...30),
            speed: CGFloat.random(in: 8...18),
            opacity: CGFloat.random(in: 0.15...0.45),
            thickness: CGFloat.random(in: 0.8...1.5)
        )
    }
}

struct RainEffectView: View {
    // Reference type — not @State — so Canvas reads it without
    // creating a re-render loop.
    private let system = RainParticleSystem()
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                // Update positions based on current frame time
                system.update(date: timeline.date, in: size)
                
                // Draw each drop as a thin line
                for drop in system.drops {
                    var path = Path()
                    path.move(to: CGPoint(x: drop.x, y: drop.y))
                    path.addLine(to: CGPoint(x: drop.x - 1, y: drop.y + drop.length))
                    
                    context.stroke(
                        path,
                        with: .color(.black.opacity(drop.opacity)),
                        lineWidth: drop.thickness
                    )
                }
            }
        }
        .allowsHitTesting(false) // Don't block scroll gestures
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.purple.opacity(0.6), .white],
            startPoint: .top,
            endPoint: .bottom
        )
        RainEffectView()
    }
    .ignoresSafeArea()
}
