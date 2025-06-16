//
//  LightweightGIFView.swift
//  winston
//
//  Created for memory optimization - lightweight GIF display
//

import SwiftUI

struct LightweightGIFView: View {
  let imageURL: String?
  
  var body: some View {
    ZStack {
      LightweightImageView(imageURL: imageURL)
      
      // Always show GIF badge
      VStack {
        Spacer()
        HStack {
          Image(systemName: "livephoto")
            .font(.caption)
          Text("GIF")
            .font(.caption)
            .fontWeight(.medium)
          Spacer()
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.8))
        .cornerRadius(4)
        .padding(8)
      }
    }
  }
}
