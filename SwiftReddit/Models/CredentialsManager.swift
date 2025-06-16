//
//  CredentialsManager.swift
//  winston
//
//  Created by Winston Team on 16/06/25.
//

import Foundation
import SwiftUI
import Combine

class CredentialsManager: ObservableObject {
    static let shared = CredentialsManager()
    
    private let userDefaults = UserDefaults.standard
    private let credentialsKey = "reddit_credentials"
    private let selectedCredentialKey = "selected_credential_id"
    
    private(set) var credentials: [RedditCredential] = []
    
    var selectedCredential: RedditCredential? {
        get {
            if let selectedID = userDefaults.object(forKey: selectedCredentialKey) as? Data,
               let uuid = try? JSONDecoder().decode(UUID.self, from: selectedID) {
                return credentials.first { $0.id == uuid }
            }
            return credentials.first
        }
        set {
            if let credential = newValue,
               let encodedID = try? JSONEncoder().encode(credential.id) {
                userDefaults.set(encodedID, forKey: selectedCredentialKey)
            } else {
                userDefaults.removeObject(forKey: selectedCredentialKey)
            }
        }
    }
    
    var validCredentials: [RedditCredential] {
        credentials.filter { $0.validationStatus == .authorized }
    }
    
    private init() {
        loadCredentials()
    }
    
    func saveCredential(_ credential: RedditCredential) {
        if let index = credentials.firstIndex(where: { $0.id == credential.id }) {
            credentials[index] = credential
        } else {
            credentials.append(credential)
        }
        saveToUserDefaults()
    }
    
    func deleteCredential(_ credential: RedditCredential) {
        credentials.removeAll { $0.id == credential.id }
        
        // If this was the selected credential, clear the selection
        if selectedCredential?.id == credential.id {
            selectedCredential = nil
        }
        
        saveToUserDefaults()
    }
    
    func deleteAllCredentials() {
        credentials.removeAll()
        selectedCredential = nil
        saveToUserDefaults()
    }
    
    private func loadCredentials() {
        guard let data = userDefaults.data(forKey: credentialsKey),
              let loadedCredentials = try? JSONDecoder().decode([RedditCredential].self, from: data) else {
            return
        }
        self.credentials = loadedCredentials
    }
    
    private func saveToUserDefaults() {
        if let data = try? JSONEncoder().encode(credentials) {
            userDefaults.set(data, forKey: credentialsKey)
        }
    }
}
