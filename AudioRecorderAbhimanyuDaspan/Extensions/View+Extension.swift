import SwiftUI

extension View {
    /// Sets the text color for a navigation bar title.
    /// - Parameter color: Color the title should be
    ///
    /// Supports both regular and large titles.
    @available(iOS 14, *)
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
    
        // Set appearance for both normal and large sizes.
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor ]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor ]
    
        return self
    }
    
    func setDarkBlueBackground() -> some View {
        // Blue background for entire screen
        GeometryReader.init(content: { geometry in
            VStack{
            }
            .frame(width: geometry.size.width,height: geometry.size.height)
            .background(Color("BlueDark", bundle: nil))
        })
    }
    
}
