import CoreGraphics

extension UIFont {
    /// Registers the described font with the font manager.
    ///
    /// This is helpful to load a font in runtime with having to control the plist file
    /// via the `UIAppFonts` key.
    /// Cf. [Loading iOS fonts dynamically](https://marco.org/2012/12/21/ios-dynamic-font-loading).
    ///
    /// - Parameters:
    ///   - bundle: the bundle to use to load the font
    ///   - fontName: the name of the font file
    ///   - fontExtension: the extension of the font file
    /// - Returns: `true` if registration of the font was successful, otherwise `false` (registering
    /// the same font twice will return `false` the second time).
    static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) -> Bool {
        guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension) else {
            fatalError("Couldn't find font \(fontName)")
        }
        
        guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL) else {
            fatalError("Couldn't load data from the font \(fontName)")
        }
        
        guard let font = CGFont(fontDataProvider) else {
            fatalError("Couldn't create font from data")
        }
        
        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterGraphicsFont(font, &error)
        guard success else {
            print("Error registering font: maybe it was already registered.")
            return false
        }
        
        return true
    }
    
    /// Outputs all font names from all font families via `debugPrint`.
    static func debugLogFonts() {
        debugPrint("--- Begin All Fonts")
        for familyName in UIFont.familyNames {
            for fontName in UIFont.fontNames(forFamilyName: familyName) {
                debugPrint("* \(fontName)")
            }
        }
        debugPrint("--- End All Fonts")
    }
}
