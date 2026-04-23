//
//  Layout.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 21/04/26.
//

import SwiftUI

let DEFAULT_HORIZONTAL_PADDING: CGFloat = 0

struct Layout<Content: View>: View {
  enum Direction {
    case vertical, horizontal
  }
    
  enum JustifyContent {
    case start, center, end, spaceBetween, spaceAround
  }
    
  enum AlignItems {
    case leading, center, trailing, stretch
  }
  
  enum SizeMode: Equatable {
    case fill, fit, fixed(CGFloat)
  }
    
  private let direction: Direction
  private let justify: JustifyContent
  private let align: AlignItems
  private let spacing: CGFloat
  private let horizontalPadding: CGFloat
  private let verticalPadding: CGFloat
  private let width: SizeMode
  private let height: SizeMode
  private let content: Content
    
  init(
    direction: Direction = .vertical,
    justify: JustifyContent = .start,
    align: AlignItems = .leading,
    spacing: CGFloat = 0,
    horizontalPadding: CGFloat = DEFAULT_HORIZONTAL_PADDING,
    verticalPadding: CGFloat = 0,
    width: SizeMode = .fit,
    height: SizeMode = .fit,
    @ViewBuilder content: () -> Content
  ) {
    self.direction = direction
    self.justify = justify
    self.align = align
    self.spacing = spacing
    self.horizontalPadding = horizontalPadding
    self.verticalPadding = verticalPadding
    self.width = width
    self.height = height
    self.content = content()
  }
    
  // MARK: - Body

  var body: some View {
    Group {
      switch direction {
      case .vertical:
        VStack(alignment: horizontalAlignment, spacing: stackSpacing) {
          justifiedContent
        }
        .frame(
          minWidth: resolveFrame(width).min,
          idealWidth: resolveFrame(width).ideal,
          maxWidth: resolveFrame(width).max,
          minHeight: resolveFrame(height).min,
          idealHeight: resolveFrame(height).ideal,
          maxHeight: resolveFrame(height).max,
          alignment: frameAlignment
        )
        
      case .horizontal:
        HStack(alignment: verticalAlignment, spacing: stackSpacing) {
          justifiedContent
        }
        .frame(
          minWidth: resolveFrame(width).min,
          idealWidth: resolveFrame(width).ideal,
          maxWidth: resolveFrame(width).max,
          minHeight: resolveFrame(height).min,
          idealHeight: resolveFrame(height).ideal,
          maxHeight: resolveFrame(height).max,
          alignment: frameAlignment
        )
      }
    }
    .padding(.horizontal, horizontalPadding)
    .padding(.vertical, verticalPadding)
  }
    
  // MARK: Justify Content

  @ViewBuilder
  private var justifiedContent: some View {
    switch justify {
    case .start:
      content
      if direction == .vertical && height == .fill {
        Spacer(minLength: 0)
      } else if direction == .horizontal && width == .fill {
        Spacer(minLength: 0)
      }
            
    case .center:
      Spacer(minLength: 0)
      content
      Spacer(minLength: 0)
            
    case .end:
      Spacer(minLength: 0)
      content

    // spaceBetween: children are spread out, first at start, last at end
    // We use the spacing from the stack + Spacers injected
    // between children via a custom modifier or rely on
    // the native behavior with frame expansion
    case .spaceBetween:
      content

    case .spaceAround:
      // spaceAround: equal space around each child
      Spacer(minLength: 0)
      content
      Spacer(minLength: 0)
    }
  }
    
  // MARK: - Computed Properties

  /// For spaceBetween/spaceAround, we don't pass custom spacing
  /// the Spacers handle distribution. Otherwise use the user's spacing
  private var stackSpacing: CGFloat {
    switch justify {
    case .spaceBetween: return nil ?? spacing // Let spacers fill: use spacing as minimum
    case .spaceAround: return spacing
    default: return spacing
    }
  }
    
  /// Maps AlignItems to HorizontalAlignment (for VStack)
  private var horizontalAlignment: HorizontalAlignment {
    switch align {
    case .leading, .stretch: return .leading
    case .center: return .center
    case .trailing: return .trailing
    }
  }
    
  /// Maps AlignItems to VerticalAlignment (for HStack)
  private var verticalAlignment: VerticalAlignment {
    switch align {
    case .leading: return .top
    case .center, .stretch: return .center
    case .trailing: return .bottom
    }
  }
    
  /// Maps the combination of justify + align to a single Alignment for the frame
  private var frameAlignment: Alignment {
    switch (direction, justify, align) {
    // Vertical direction
    case (.vertical, .start, .leading), (.vertical, .start, .stretch): return .topLeading
    case (.vertical, .start, .center): return .top
    case (.vertical, .start, .trailing): return .topTrailing
    case (.vertical, .center, .leading), (.vertical, .center, .stretch): return .leading
    case (.vertical, .center, .center): return .center
    case (.vertical, .center, .trailing): return .trailing
    case (.vertical, .end, .leading), (.vertical, .end, .stretch): return .bottomLeading
    case (.vertical, .end, .center): return .bottom
    case (.vertical, .end, .trailing): return .bottomTrailing
    // Horizontal direction
    case (.horizontal, .start, .leading), (.horizontal, .start, .stretch): return .topLeading
    case (.horizontal, .start, .center): return .leading
    case (.horizontal, .start, .trailing): return .bottomLeading
    case (.horizontal, .center, .leading), (.horizontal, .center, .stretch): return .top
    case (.horizontal, .center, .center): return .center
    case (.horizontal, .center, .trailing): return .bottom
    case (.horizontal, .end, .leading), (.horizontal, .end, .stretch): return .topTrailing
    case (.horizontal, .end, .center): return .trailing
    case (.horizontal, .end, .trailing): return .bottomTrailing
    // Default fallback
    case (.vertical, _, .leading), (.vertical, _, .stretch): return .topLeading
    case (.vertical, _, .center): return .top
    case (.vertical, _, .trailing): return .topTrailing
    case (.horizontal, _, .leading), (.horizontal, _, .stretch): return .topLeading
    case (.horizontal, _, .center): return .leading
    case (.horizontal, _, .trailing): return .bottomLeading
    }
  }
  
  private func resolveFrame(_ mode: SizeMode) -> (min: CGFloat?, ideal: CGFloat?, max: CGFloat?) {
    switch mode {
    case .fill: return (nil, nil, .infinity)
    case .fit: return (nil, nil, nil)
    case .fixed(let size): return (size, size, size)
    }
  }
}

#Preview {
  Layout(
    direction: .horizontal,
    justify: .spaceBetween,
    align: .center,
    spacing: 2,
    width: .fill
  ) {
    CustomText("Hello")
    Spacer()
    CustomText("World")
  }
}
