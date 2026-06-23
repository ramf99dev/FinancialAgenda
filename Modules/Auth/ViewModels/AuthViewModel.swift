//
//  AuthViewModel.swift
//  agendafinanciera
//
//  Created by Randy Molina on 20/5/26.
//

import SwiftUI
import Combine
import Supabase

@MainActor
public final class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var email = ""
    @Published public var password = ""
    @Published public var confirmPassword = ""
    @Published public var fullName = ""
    
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var showErrorAlert = false
    @Published public var successMessage: String?
    @Published public var showSuccessAlert = false
    
    // MARK: - Validation Properties
    @Published public var emailValidationError: String?
    @Published public var passwordValidationError: String?
    @Published public var confirmPasswordValidationError: String?
    @Published public var fullNameValidationError: String?
    
    private let authService = AuthService.shared
    
    public init() {}
    
    // MARK: - Form Validations
    public func validateLoginForm() -> Bool {
        var isValid = true
        
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            emailValidationError = "El correo electrónico es obligatorio"
            isValid = false
        } else if !isValidEmail(email) {
            emailValidationError = "Formato de correo electrónico inválido"
            isValid = false
        } else {
            emailValidationError = nil
        }
        
        if password.isEmpty {
            passwordValidationError = "La contraseña es obligatoria"
            isValid = false
        } else {
            passwordValidationError = nil
        }
        
        return isValid
    }
    
    public func validateRegisterForm() -> Bool {
        var isValid = true
        
        if fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            fullNameValidationError = "El nombre completo es obligatorio"
            isValid = false
        } else {
            fullNameValidationError = nil
        }
        
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            emailValidationError = "El correo electrónico es obligatorio"
            isValid = false
        } else if !isValidEmail(email) {
            emailValidationError = "Formato de correo electrónico inválido"
            isValid = false
        } else {
            emailValidationError = nil
        }
        
        if password.isEmpty {
            passwordValidationError = "La contraseña es obligatoria"
            isValid = false
        } else if password.count < 6 {
            passwordValidationError = "La contraseña debe tener al menos 6 caracteres"
            isValid = false
        } else {
            passwordValidationError = nil
        }
        
        if confirmPassword.isEmpty {
            confirmPasswordValidationError = "Confirma tu contraseña"
            isValid = false
        } else if confirmPassword != password {
            confirmPasswordValidationError = "Las contraseñas no coinciden"
            isValid = false
        } else {
            confirmPasswordValidationError = nil
        }
        
        return isValid
    }
    
    public func validateForgotPasswordForm() -> Bool {
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            emailValidationError = "El correo electrónico es obligatorio"
            return false
        } else if !isValidEmail(email) {
            emailValidationError = "Formato de correo electrónico inválido"
            return false
        } else {
            emailValidationError = nil
            return true
        }
    }
    
    // MARK: - Auth Operations
    
    /// Iniciar sesión
    public func login() async -> Bool {
        guard validateLoginForm() else { return false }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signIn(email: email, password: password)
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = mapAuthError(error)
            showErrorAlert = true
            return false
        }
    }
    
    /// Registrar un nuevo usuario
    public func register() async -> Bool {
        guard validateRegisterForm() else { return false }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signUp(email: email, password: password, fullName: fullName)
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = mapAuthError(error)
            showErrorAlert = true
            return false
        }
    }
    
    /// Recuperar contraseña
    public func sendPasswordReset() async -> Bool {
        guard validateForgotPasswordForm() else { return false }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.sendPasswordReset(email: email)
            isLoading = false
            successMessage = "Se ha enviado un enlace para restablecer tu contraseña a tu correo electrónico."
            showSuccessAlert = true
            return true
        } catch {
            isLoading = false
            errorMessage = mapAuthError(error)
            showErrorAlert = true
            return false
        }
    }
    
    // MARK: - Helpers
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func mapAuthError(_ error: Error) -> String {
        let localizedDescription = error.localizedDescription
        
        if localizedDescription.contains("Invalid login credentials") || localizedDescription.contains("invalid_credentials") {
            return "Correo o contraseña incorrectos."
        } else if localizedDescription.contains("Email not confirmed") || localizedDescription.contains("email_not_confirmed") {
            return "Por favor, confirma tu correo electrónico antes de iniciar sesión."
        } else if localizedDescription.contains("User already registered") || localizedDescription.contains("user_already_exists") {
            return "Ya existe un usuario registrado con este correo electrónico."
        } else if localizedDescription.contains("signup_disabled") {
            return "El registro de cuentas está deshabilitado temporalmente."
        } else if localizedDescription.contains("Email address is invalid") {
            return "El formato del correo electrónico no es válido."
        }
        
        return localizedDescription
    }
}
