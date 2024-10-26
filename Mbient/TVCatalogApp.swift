/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The entry point for the app.
*/

import SwiftUI

@main
struct TVCatalogApp: App {
    
    var body: some Scene {
        WindowGroup {
                    ContentView()
                        .preferredColorScheme(.dark) // Enforce Dark Mode
                }
    }
}


