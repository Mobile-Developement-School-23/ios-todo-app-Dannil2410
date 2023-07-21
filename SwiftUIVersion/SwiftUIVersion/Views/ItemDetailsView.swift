//
//  ItemDetailsView.swift
//  SwiftUIVersion
//
//  Created by Даниил Кизельштейн on 21.07.2023.
//

import SwiftUI

struct ItemDetailsView: View {
    var body: some View {
        ZStack {
            backgroundView
            ScrollView {
                VStack {
                    Text("Hello, world!")
                    
                }
            }
        }
    }

    private var backgroundView: some View {
        Color(uiColor: Colors.backPrimary.value)
            .ignoresSafeArea()
    }
}

struct ItemDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ItemDetailsView()
    }
}
