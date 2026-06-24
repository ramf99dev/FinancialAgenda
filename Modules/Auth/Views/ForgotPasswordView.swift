import SwiftUI

/// Vista de recuperacion de contraseña con estilo Apple minimalista y ligero
struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appleBackground.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Mensaje Informativo
                    VStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(Color.appleBlue)
                            .padding(.top, 24)
                        
                        Text("Recuperar contraseña")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.applePrimary)
                        
                        Text("Introduce tu correo electrónico registrado y te enviaremos las instrucciones necesarias para restablecer tu cuenta.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appleSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    
                    // Card del Formulario
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CORREO ELECTRÓNICO")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.appleSecondary)
                            .tracking(1.0)
                            .padding(.leading, 4)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(Color.appleSecondary)
                                .frame(width: 20)
                            
                            TextField("correo@ejemplo.com", text: $viewModel.email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .foregroundStyle(Color.applePrimary)
                        }
                        .appleTextFieldStyle()
                        
                        if let validationError = viewModel.emailValidationError {
                            Text(validationError)
                                .font(.caption2)
                                .foregroundStyle(Color.appleRed)
                                .padding(.leading, 8)
                        }
                    }
                    .padding(20)
                    .appleCardStyle()
                    
                    // Boton de envio de correo
                    Button {
                        Task {
                            _ = await viewModel.sendPasswordReset()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Enviar enlace de restauración")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 16)
                        .background(viewModel.isLoading ? Color.appleBlue.opacity(0.6) : Color.appleBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .appleShadow()
                    }
                    .disabled(viewModel.isLoading)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Recuperación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundStyle(Color.appleBlue)
                }
            }
            // Alerta de Exito
            .alert("Enlace Enviado", isPresented: $viewModel.showSuccessAlert) {
                Button("Entendido") {
                    dismiss()
                }
            } message: {
                Text(viewModel.successMessage ?? "Revisa tu correo para continuar.")
            }
            // Alerta de Error
            .alert("Error de Envío", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Ocurrió un error inesperado.")
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}
