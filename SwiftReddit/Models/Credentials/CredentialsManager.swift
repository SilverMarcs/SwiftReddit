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
    private let credentialsKey = "reddit_credential" // Changed to singular
    
    // Single credential instead of array
    var credential: RedditCredential? = nil
    
    // For backward compatibility, expose as array but only with single item
//    var credentials: [RedditCredential] {
//        return credential != nil ? [credential!] : []
//    }
    
    var selectedCredential: RedditCredential? {
        get {
            return credential
        }
        set {
            credential = newValue
            saveToUserDefaults()
        }
    }
    
    var validCredentials: [RedditCredential] {
        return credential?.validationStatus == .authorized ? [credential!] : []
    }
    
    private init() {
        loadCredentials()
    }
    
    func saveCredential(_ newCredential: RedditCredential) {
        // Replace any existing credential with the new one
        credential = newCredential
        saveToUserDefaults()
    }
    
    func deleteCredential(_ credentialToDelete: RedditCredential) {
        // Only delete if it matches the current credential
        if credential?.id == credentialToDelete.id {
            credential = nil
            saveToUserDefaults()
        }
    }
    
    func deleteAllCredentials() {
        credential = nil
        saveToUserDefaults()
    }
    
    private func loadCredentials() {
        // Try to load single credential first
        if let data = userDefaults.data(forKey: credentialsKey),
           let loadedCredential = try? JSONDecoder().decode(RedditCredential.self, from: data) {
            self.credential = loadedCredential
            return
        }
        
        // Migration: Try to load from old multiple credentials format
        if let data = userDefaults.data(forKey: "reddit_credentials"),
           let loadedCredentials = try? JSONDecoder().decode([RedditCredential].self, from: data),
           let firstCredential = loadedCredentials.first {
            self.credential = firstCredential
            // Clear old format and save in new format
            userDefaults.removeObject(forKey: "reddit_credentials")
            userDefaults.removeObject(forKey: "selected_credential_id")
            saveToUserDefaults()
        }
    }
    
    private func saveToUserDefaults() {
        if let credential = credential,
           let data = try? JSONEncoder().encode(credential) {
            userDefaults.set(data, forKey: credentialsKey)
        } else {
            userDefaults.removeObject(forKey: credentialsKey)
        }
    }
}
