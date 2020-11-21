//
//  TimePicker.swift
//  Invocation
//
//  Created by Isaac Lyons on 11/10/20.
//

import SwiftUI

struct TimePicker: View {
    
    @Binding var hourSelection: Int
    @Binding var minuteSelection: Int
    
    var height: CGFloat = 150
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack {
                Rectangle().opacity(0)
                
                HStack(spacing: 0) {
                    Picker(selection: $hourSelection, label: Text("")) {
                        ForEach(0..<24) { index in
                            Text("\(index) hour\(index == 1 ? "" : "s")").tag(index)
                        }
                    }
                    .frame(width: geo.size.width / 2, height: height)
                    .clipped()
                    Picker(selection: $minuteSelection, label: Text("")) {
                        ForEach(0..<60) { index in
                            Text("\(index) min").tag(index)
                        }
                    }
                    .frame(width: geo.size.width / 2, height: height)
                    .clipped()
                }
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
            }
        }
        .frame(height: height)
    }
}

struct TimePicker_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            TimePicker(hourSelection: .constant(2), minuteSelection: .constant(13))
        }
    }
}
