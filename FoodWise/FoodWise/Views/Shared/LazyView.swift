//
//  LazyView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 28/11/21.
//

import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
