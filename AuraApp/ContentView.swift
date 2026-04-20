//
//  ContentView.swift
//  AuraApp
//
//  Created by Wahyu Kurniawan on 16/04/26.
//
//  UPDATED: Temporarily shows the ListView directly for testing.
//  Your friend will later replace this with the real Home Page
//  that navigates to ListView with different categories.
//
//  WHAT'S IMPORTANT HERE:
//  NavigationStack is the container that enables navigation in SwiftUI.
//  It must wrap the view hierarchy for NavigationLink (in ListView) to work.
//  Without it, tapping a place row would do nothing.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // MARK: - NavigationStack
        // This is the navigation container. It manages a stack of views:
        // 1. ListView is the "root" (first screen)
        // 2. When you tap a place, DetailView gets "pushed" on top
        // 3. The back button automatically appears to go back
        //
        // Your friend will later add the Home Page here and navigate
        // to ListView like: NavigationLink("Running", destination: ListView(category: "Running"))
        NavigationStack {
            ListView(category: "Running")
        }
    }
}

#Preview {
    ContentView()
}
