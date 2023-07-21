//
//  ToDoListView.swift
//  SwiftUIVersion
//
//  Created by Даниил Кизельштейн on 20.07.2023.
//

import SwiftUI

struct ToDoListView: View {
    var items: [ToDoItem]

    private var isDoneItems: [ToDoItem] {
        items.filter({ $0.isDone == true })
    }

    private var isNotDoneItems: [ToDoItem] {
        items.filter({ $0.isDone != true })
    }

    @State private var isShow: Bool = true

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                backgroundView
                VStack {
                    listHeader
                    makeList
                }
                ZStack {
                    Color(.white)
                        .frame(width: 50, height: 50)
                        .cornerRadius(25)
                    addNewItem
                }
            }
            .navigationTitle("Мои дела")
        }

    }

    private var title: some View {
        Text("Мои дела")
            .padding(.leading, 40)
    }

    private var backgroundView: some View {
        Color(uiColor: Colors.backPrimary.value)
            .ignoresSafeArea()
    }

    private var listHeader: some View {
        HStack(alignment: .top) {
            isDoneCountView
            Spacer()
            showOrHideView
        }
        .padding([.leading, .trailing], 32)
        .padding(.bottom, -40)
        .padding(.top, 20)
    }

    private var isDoneCountView: some View {
        Text("Выполнено - \(isDoneItems.count)")
            .foregroundColor(
                Color(
                    uiColor: Colors.colorGray.value
                )
            )
    }

    private var showOrHideView: some View {
        Button(isShow ? "Показать" : "Скрыть") {
            isShow.toggle()
        }
        .foregroundColor(Color(uiColor: Colors.colorBlue.value))
    }

    private var makeList: some View {
        let usingItems = (isShow ? isNotDoneItems : items).sorted { $0.startTime > $1.startTime }
        return List {
            ForEach(usingItems, id: \.id) { item in
                NavigationLink {
                    ItemDetailsView()
                } label: {
                    ItemCell(toDoItem: item)
                }
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button {
                 print("isDone")
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                }
                .tint(.green)
              }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                   print("Trash")
                  } label: {
                      Image(systemName: "trash")
                  }
                  .tint(.red)
                }
            NavigationLink {
                ItemDetailsView()
            } label: {
                Text("Новое")
                    .padding(.leading, 32)
                    .foregroundColor(Color(uiColor: Colors.colorGray.value))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scrollContentBackground(.hidden)
    }

    private var addNewItem: some View {
        Button {
            print("add new item")
        } label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
        }.shadow(radius: 16)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoListView(items: ToDoList.items)
    }
}
