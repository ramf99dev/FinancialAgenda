//
//  SupabaseClient.swift
//  agendafinanciera
//
//  Created by Randy Molina on 20/5/26.
//

import Foundation
import Supabase

public final class AppSupabaseClient {
    public static let shared = AppSupabaseClient()
    
    public let client: SupabaseClient
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: Secrets.supabaseURL)!,
            supabaseKey: Secrets.supabaseKey,
            options: SupabaseClientOptions(
                auth: SupabaseClientOptions.AuthOptions(
                    storage: AuthClient.Configuration.defaultLocalStorage,
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }
}
