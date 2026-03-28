//
//  AuthService.swift
//  Project3
//
//  Created by Anushka R on 3/28/26.
//

import Foundation
import Supabase

class AuthService {
    func start() {
        let client = SupabaseClient(
            supabaseURL: URL(string: "https://xyzcompany.supabase.co")!,
            supabaseKey: "public-anon-key"
        )
    }
}
