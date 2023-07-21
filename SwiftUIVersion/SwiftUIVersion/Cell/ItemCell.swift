//
//  ItemCell.swift
//  SwiftUIVersion
//
//  Created by Даниил Кизельштейн on 20.07.2023.
//

import SwiftUI

struct ItemCell: View {
    @State var toDoItem: ToDoItem

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    }()

    var body: some View {
        HStack {
            Button {
                isDoneChanged(was: toDoItem.isDone)
            } label: {
                makeIsDoneImage
            }
            .padding(.trailing, 5)
            VStack(alignment: .leading) {
                makeText
                    .lineLimit(3)
                if toDoItem.deadLine != nil,
                   !toDoItem.isDone {
                    makeDeadLine
                }
            }
        }
    }

    private var makeIsDoneImage: some View {
        if toDoItem.isDone {
            return Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        } else {
            switch toDoItem.importance {
            case .important:
                return Image(systemName: "circle")
                    .foregroundColor(.red)
            default:
                return Image(systemName: "circle")
                    .foregroundColor(.gray)
            }
        }
    }

    private var makeText: some View {
        switch toDoItem.importance {
        case .common:
            return Text(toDoItem.text)
        default:
            return (
                Text(
                    Image(
                        systemName: toDoItem.importance == .important ? "exclamationmark.2" : "arrow.down"
                    )
                )
                .foregroundColor(toDoItem.importance == .important ? .red : .gray)
                .font(.system(size: 16, weight: .bold))
                + Text(toDoItem.text)
                    .foregroundColor(toDoItem.isDone ? Color(uiColor: Colors.labelTeritary.value) :
                                        Color(uiColor: Colors.labelPrimary.value))
            )
            .strikethrough(toDoItem.isDone ? true : false)
        }
    }

    private var makeDeadLine: some View {
        return (
            Text(
                Image(systemName: "calendar")
            )
            .font(.system(size: 16, weight: .bold))
            + Text(
                dateFormatter.string(from: toDoItem.deadLine ?? .now)
            )
        )
        .foregroundColor(Color(uiColor: Colors.colorGrayLight.value))
    }

    private func isDoneChanged(was: Bool) {
        toDoItem = .init(
            id: toDoItem.id,
            text: toDoItem.text,
            importance: toDoItem.importance,
            deadLineTimeIntervalSince1970: toDoItem.deadLine?.timeIntervalSince1970,
            isDone: was ? false : true,
            startTimeIntervalSince1970: toDoItem.startTime.timeIntervalSince1970,
            changeTimeIntervalSince1970: toDoItem.changeTime?.timeIntervalSince1970)
    }


    private func makeText(
        importance: Importance,
        text: String,
        isDone: Bool
    ) -> NSMutableAttributedString {
        let fullString: NSMutableAttributedString
        if importance == .common {
            fullString = NSMutableAttributedString(string: text)
        } else {
            let config = UIImage
                .SymbolConfiguration(
                    pointSize: importance == .important ? 16 : 14, weight: .bold, scale: .large
                )
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(
                systemName: importance == .important ? "exclamationmark.2" : "arrow.down",
                withConfiguration: config)?
                .withTintColor(
                    importance == .important ? Colors.colorRed.value : Colors.colorGray.value,
                    renderingMode: .alwaysOriginal)
            fullString = NSMutableAttributedString(string: "")
            fullString.append(NSAttributedString(attachment: imageAttachment))
            fullString.append(NSAttributedString(string: text))
        }
        if isDone {
            fullString
                .addAttribute(
                    NSAttributedString.Key.strikethroughStyle,
                    value: 2,
                    range: NSRange(location: 0, length: fullString.length)
                )
        }
        return fullString
    }
}

struct ItemCell_Previews: PreviewProvider {
    static var previews: some View {
        ItemCell(toDoItem: ToDoList.items[0])
    }
}
