import SwiftUI

public struct GenieModifier: ViewModifier {
    var active: Bool
    
    public func body(content: Content) -> some View {
        content
            // Efecto asimétrico: El ancho y el alto escalan de forma independiente
            // para emular la 'succión/estiramiento' del genio.
            .scaleEffect(
                x: active ? 0.15 : 1.0,
                y: active ? 0.05 : 1.0,
                anchor: .top
            )
            // Añadimos un desenfoque de movimiento durante la contracción
            .blur(radius: active ? 10 : 0)
            // Atenuado de opacidad para que no aparezca bruscamente
            .opacity(active ? 0 : 1)
    }
}

extension AnyTransition {
    /// Una transición personalizada inspirada en el efecto Aladino/Genie de macOS,
    /// anclada al borde superior (ideal para dropdowns y popovers de la barra de menú).
    public static var genie: AnyTransition {
        .modifier(
            active: GenieModifier(active: true),
            identity: GenieModifier(active: false)
        )
    }
}

extension Animation {
    /// Aplica una animación spring optimizada para el efecto Aladino
    public static func genieAnimation() -> Animation {
        // Un resorte amortiguado con una velocidad de respuesta de medio segundo
        // provee el efecto de estiramiento de goma característico de macOS.
        .spring(response: 0.42, dampingFraction: 0.76, blendDuration: 0)
    }
}
