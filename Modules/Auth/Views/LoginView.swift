import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showForgotPassword = false
    
    var body: some View {
        ZStack {
            Color.appleBackground.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Logotipo de la App
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .appleShadow()
                        
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.appleBlue)
                    }
                    
                    Text("Agenda Financiera")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.applePrimary)
                    
                    Text("Control inteligente y minimalista")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appleSecondary)
                }
                
                // Formulario de Credenciales
                VStack(spacing: 16) {
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
                    
                    // Boton Olvidé mi contraseña
                    HStack {
                        Spacer()
                        Button("¿Olvidaste tu contraseña?") {
                            showForgotPassword = true
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.appleBlue)
                    }
                    .padding(.top, 4)
                    
                    // Boton de Enviar
                    Button {
                        Task {
                            _ = await viewModel.login()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Iniciar Sesión")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 16)
                        .background(viewModel.isLoading ? Color.appleBlue.opacity(0.6) : Color.appleBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .appleShadow()
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.top, 8)
                }
                .padding(24)
                .appleCardStyle()
                .padding(.horizontal, 24)
                
                // Atajo biometrico
                Button {
                    // Implementación biométrica futura
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "faceid")
                            .font(.system(size: 18))
                        Text("Ingresar con Face ID")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color.applePrimary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .appleShadow()
                }
                    
                Spacer()
                // Botón de Sign in with Apple
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            print("Authorization successful: \(authorization)")
                        case .failure(let error):
                            print("Authorization failed: \(error.localizedDescription)")
                        }
                    }
                )
                .frame(width: 220, height: 40)
                .cornerRadius(16)
                
                // Enlace de registro
                HStack(spacing: 4) {
                    Text("¿No tienes cuenta?")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appleSecondary)
                    
                    NavigationLink(destination: RegisterView()) {
                        Text("Regístrate aquí")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.appleBlue)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
        .alert("Error de ingreso", isPresented: $viewModel.showErrorAlert) {
            Button("Entendido", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Las credenciales no coinciden.")
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
