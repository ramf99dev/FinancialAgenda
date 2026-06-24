import SwiftUI

/// Vista de registro de cuenta nueva estilo Apple ligera
struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            Color.appleBackground.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Encabezado de la Vista
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Crear Cuenta")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.applePrimary)
                        Text("Únete hoy y automatiza la administración de tus recursos.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appleSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    // Tarjeta de Registro
                    VStack(spacing: 16) {
                        // Nombre Completo
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(Color.appleSecondary)
                                    .frame(width: 20)
                                TextField("Nombre completo", text: $viewModel.fullName)
                                    .foregroundStyle(Color.applePrimary)
                            }
                            .appleTextFieldStyle()
                            
                            if let error = viewModel.fullNameValidationError {
                                Text(error)
                                    .font(.caption2)
                                    .foregroundStyle(Color.appleRed)
                                    .padding(.leading, 8)
                            }
                        }
                        
                        // Correo Electronico
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .foregroundStyle(Color.appleSecondary)
                                    .frame(width: 20)
                                TextField("Correo electrónico", text: $viewModel.email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .foregroundStyle(Color.applePrimary)
                            }
                            .appleTextFieldStyle()
                            
                            if let error = viewModel.emailValidationError {
                                Text(error)
                                    .font(.caption2)
                                    .foregroundStyle(Color.appleRed)
                                    .padding(.leading, 8)
                            }
                        }
                        
                        // Contraseña
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(Color.appleSecondary)
                                    .frame(width: 20)
                                SecureField("Contraseña", text: $viewModel.password)
                                    .foregroundStyle(Color.applePrimary)
                            }
                            .appleTextFieldStyle()
                            
                            if let error = viewModel.passwordValidationError {
                                Text(error)
                                    .font(.caption2)
                                    .foregroundStyle(Color.appleRed)
                                    .padding(.leading, 8)
                            }
                        }
                        
                        // Confirmar Contraseña
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundStyle(Color.appleSecondary)
                                    .frame(width: 20)
                                SecureField("Confirmar contraseña", text: $viewModel.confirmPassword)
                                    .foregroundStyle(Color.applePrimary)
                            }
                            .appleTextFieldStyle()
                            
                            if let error = viewModel.confirmPasswordValidationError {
                                Text(error)
                                    .font(.caption2)
                                    .foregroundStyle(Color.appleRed)
                                    .padding(.leading, 8)
                            }
                        }
                        
                        // Boton de Registro
                        Button {
                            Task {
                                _ = await viewModel.register()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Registrar Cuenta")
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
                        .padding(.top, 8)
                    }
                    .padding(24)
                    .appleCardStyle()
                    .padding(.horizontal, 24)
                    
                    // Boton para volver
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Text("¿Ya tienes una cuenta?")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.appleSecondary)
                            Text("Inicia sesión")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.appleBlue)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Atrás")
                    }
                    .foregroundStyle(Color.appleBlue)
                }
            }
        }
        .alert("Error de registro", isPresented: $viewModel.showErrorAlert) {
            Button("Entendido", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "No se pudo registrar la cuenta.")
        }
        .alert("Registro Exitoso", isPresented: $viewModel.showSuccessAlert) {
            Button("Entendido") {
                dismiss()
            }
        } message: {
            Text(viewModel.successMessage ?? "Cuenta registrada exitosamente. Por favor confirme el correo con el link enviado.")
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
}
