// Barra de navegacion con estetica Liquid Glass para iOS 26
// Simplificada para aprovechar el sistema nativo de material translucido.
// Se mantiene como componente reutilizable para vistas que requieran cabecera personalizada.

import SwiftUI

/// Barra de navegacion personalizada con efecto de cristal liquido
struct LiquidGlassNavbar: View {
    let title: String
    var onProfileTap: (() -> Void)? = nil
    var onNotificationTap: (() -> Void)? = nil

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.applePrimary)
            }

            Spacer()

            HStack(spacing: 12) {
                if let notificationAction = onNotificationTap {
                    Button(action: notificationAction) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.appleSecondary)
                    }
                }

                if let profileAction = onProfileTap {
                    Button(action: profileAction) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.appleBlue)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}
