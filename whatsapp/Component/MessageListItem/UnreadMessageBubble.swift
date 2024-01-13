//
//  UnreadMessageBubble.swift
//  whatsapp
//
//  Created by 김수아 on 1/13/24.
//

import Foundation
import SwiftUI

struct UnreadMessageBubble: View{
    var count: Int
    
    var body: some View{
        ZStack(alignment: .center){
            Circle().fill(Color.key)
            Text("\(count)")
                .font(Font.custom(.regular, size: 14))
                .foregroundStyle(Color.white100)
        }.frame(width: 22, height: 22)
    }
}
