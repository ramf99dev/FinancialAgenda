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
            supabaseURL: URL(string: "https://lmqwnicomyeievxvcpih.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxtcXduaWNvbXllaWV2eHZjcGloIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkyODc5MjYsImV4cCI6MjA5NDg2MzkyNn0.lw7NVgwP2KGUPHxc8FmIJ1WJfly-ky5qkdz5wLOLbYY",
            options: SupabaseClientOptions(
                auth: SupabaseClientOptions.AuthOptions(
                    storage: AuthClient.Configuration.defaultLocalStorage,
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }
}
