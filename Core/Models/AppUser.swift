//
//  AppUser.swift
//  agendafinanciera
//
//  Created by Randy Molina on 21/5/26.
//


import Foundation

public struct AppUser: Codable, Identifiable {
    public let id: UUID
    public let email: String
    public let full_name: String
    public let avatar_url: String?
    public let fcm_token: String?
    public let created_at: Date?
}
