//
//  SwiftUIVersionApp.swift
//  SwiftUIVersion
//
//  Created by Даниил Кизельштейн on 20.07.2023.
//

import SwiftUI

@main
struct SwiftUIVersionApp: App {
    var body: some Scene {
        WindowGroup {
            ToDoListView(items: ToDoList.items)
        }
    }
}
