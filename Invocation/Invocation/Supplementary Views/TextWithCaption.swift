//
//  TextWithCaption.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/4/20.
//

import SwiftUI

struct TextWithCaption: View {
    
    var text: String
    var caption: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
            if let caption = caption,
               !caption.isEmpty {
                Text(caption)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
}

struct TextWithCaption_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                TextWithCaption(text: "Text", caption: "Caption")
                TextWithCaption(text: "Text with no caption", caption: nil)
            }
        }
    }
}
