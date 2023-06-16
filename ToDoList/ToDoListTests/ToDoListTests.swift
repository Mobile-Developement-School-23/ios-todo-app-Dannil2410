//
//  ToDoListTests.swift
//  ToDoListTests
//
//  Created by Даниил Кизельштейн on 12.06.2023.
//

import XCTest
@testable import ToDoList

final class ToDoListTests: XCTestCase {

    var fileCache: FileCache!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        fileCache = FileCache()
    }

    override func tearDownWithError() throws {
        fileCache = nil
        
        try super.tearDownWithError()
        
    }

    func testExample() throws {
        
        // testing ToDoItem class
        // testing function parse for json
        testJsonValid()
        
        testJsonInvalid()
        
        testJsonWithoutId()
        
        testJsonWithInvalidTextType()
        
        testJsonWithoutStartTime()
        
        testJsonStartTimeMoreEqualDeadLine()
        
        testJsonStartTimeMoreEqualDeadLine()
        
        testJsonStartTimeMoreEqualChangeTime()
        
        testJsonChangeTimeMoreEqualDeadLine()
        
        testJsonImportant()
        
        testJsonUnimportant()
        
        testJsonCommon()
        
        
        // testing function parse for csv
        testCsvValid()
        
        testCsvHasNotSevenFeatures()
        
        testCsvWithoutId()
        
        testCsvWithoutText()
        
        testCsvWithoutStartTime()
        
        testCsvImportant()
        
        testCsvUnimportant()
        
        testCsvCommon()
        
        // testing FileCache class
        // testing function appendItem
        testFileCacheAppendItem()
        
        testFileCacheAppendItemOnDublicates()
        
        testFileCacheDeleteItem()
        
        testFileCacheDeleteItemIfIdDoNotExist()
    }

    func testPerformanceExample() throws {
    }
    
    func testJsonValid() {
        // given
        let valid: [String: Any] = [
            "id": "fghfsdas324",
            "text": "dfcghjd",
            "importance": "важная",
            "isDone": true,
            "startTime": 4353788.0
        ]
        
        // when
        let toDoItem = ToDoItem.parse(json: valid)
        
        // then
        XCTAssert((toDoItem != nil), "JSON валидный")
    }
    
    func testJsonInvalid() {
        // given
        let jsonInvalid: [String] = ["1", "2", "3"]
        
        // when
        let toDoItem = ToDoItem.parse(json: jsonInvalid)
        
        // then
        XCTAssert((toDoItem == nil), "Тест на невалидный json")
    }
    
    func testJsonWithoutId() {
        // given
        let withoutId: [String: Any] = [
            "text": "dfcghjd",
            "importance": "важная",
            "isDone": true,
            "startTime": 4353788.0
        ]
        
        
        // when
        let toDoItem = ToDoItem.parse(json: withoutId)
        
        // then
        XCTAssert((toDoItem == nil), "JSON без id")
    }
    
    func testJsonWithInvalidTextType() {
        // given
        let invalidTextType: [String: Any] = [
            "id": "fghfsdas324",
            "text": 123,
            "importance": "важная",
            "isDone": true,
            "startTime": 4353788.0
        ]
        
        // when
        let toDoItem = ToDoItem.parse(json: invalidTextType)
        
        // then
        XCTAssert((toDoItem == nil), "JSON c невалидным типом text")
    }
    
    func testJsonWithoutStartTime() {
        // given
        let withoutStartTime: [String: Any] = [
            "id": "fghfsdas324",
            "text": "hffhkffj",
            "importance": "важная",
            "isDone": true,
        ]
        
        // when
        let toDoItem = ToDoItem.parse(json: withoutStartTime)
        
        // then
        XCTAssert((toDoItem == nil), "JSON без startTime")
    }
    
    func testJsonStartTimeMoreEqualDeadLine() {
        // given
        let startTimeMoreEqualDeadLine: [String: Any] = [
            "id": "fghfsdas324",
            "text": "hffhkffj",
            "importance": "важная",
            "isDone": true,
            "startTime": 4353788.0,
            "deadLine": 435378.0
        ]
        
        // when
        let toDoItem = ToDoItem.parse(json: startTimeMoreEqualDeadLine)
        
        // then
        XCTAssert((toDoItem == nil), "JSON без startTime >= deadLine")
    }
    
    func testJsonStartTimeMoreEqualChangeTime() {
        // given
        let startTimeMoreEqualChangeTime: [String: Any] = [
            "id": "fghfsdas324",
            "text": "hffhkffj",
            "importance": "важная",
            "isDone": true,
            "startTime": 4353788.0,
            "changeTime": 435378.0
        ]
        
        // when
        let toDoItem = ToDoItem.parse(json: startTimeMoreEqualChangeTime)
        
        // then
        XCTAssert((toDoItem == nil), "JSON без startTime >= changeLine")
    }
    
    func testJsonChangeTimeMoreEqualDeadLine() {
        // given
        let changeTimeMoreEqualDeadLine: [String: Any] = [
            "id": "fghfsdas324",
            "text": "hffhkffj",
            "importance": "важная",
            "isDone": true,
            "startTime": 4353788.0,
            "changeTime": 435378.0,
            "deadLine": 435377.0
        ]
        
        // when
        let toDoItem = ToDoItem.parse(json: changeTimeMoreEqualDeadLine)
        
        // then
        XCTAssert((toDoItem == nil), "JSON без changeTime >= deadLine")
    }
    
    func testJsonImportant() {
        // given
        let jsonImportant: [String: Any] = [
            "id": "fghfsdas324",
            "text": "dfcghjd",
            "importance": "важная",
            "isDone": true,
            "startTime": 4353788.0
        ]
        
        // when
        let toDoItem = ToDoItem.parse(json: jsonImportant)
        
        // then
        XCTAssert((toDoItem?.importance == Importance.important), "Json важный item")
    }
    
    func testJsonUnimportant() {
        // given
        let jsonUnimportant: [String: Any] = [
            "id": "fghfsdas324",
            "text": "dfcghjd",
            "importance": "неважная",
            "isDone": true,
            "startTime": 4353788.0
        ]
        
        // when
        let toDoItem = ToDoItem.parse(json: jsonUnimportant)
        
        // then
        XCTAssert((toDoItem?.importance == Importance.unimportant), "Json неважный item")
    }
    
    func testJsonCommon() {
        // given
        let jsonEmpty: [String: Any] = [
            "id": "fghfsdas324",
            "text": "dfcghjd",
            "isDone": true,
            "startTime": 4353788.0
        ]
        
        let jsonRubbish: [String: Any] = [
            "id": "fghfsdas324",
            "text": "dfcghjd",
            "importance": "gtnghdf",
            "isDone": true,
            "startTime": 4353788.0
        ]
        
        // when
        let toDoItemEmpty = ToDoItem.parse(json: jsonEmpty)
        let toDoItemRubbish = ToDoItem.parse(json: jsonRubbish)
        
        // then
        XCTAssert((toDoItemEmpty?.importance == Importance.common), "CSV обычный item")
        XCTAssert((toDoItemRubbish?.importance == Importance.common), "CSV обычный item")
    }
    
    func testCsvValid() {
        // given
        let csvValid: String = "dgfdjhhzd,text,важная,,false,64764856.0,"
        
        // when
        let toDoItem = ToDoItem.parse(csv: csvValid)
        
        // then
        XCTAssert((toDoItem != nil), "CSV валидный")
    }
    
    func testCsvHasNotSevenFeatures() {
        // given
        let csvHasNotSevenFeatures: String = "1,4,2,6,8,8"
        
        // when
        let toDoItem = ToDoItem.parse(csv: csvHasNotSevenFeatures)
        
        // then
        XCTAssert((toDoItem == nil), "CSV имеет неверное количество фичей")
    }
    
    func testCsvWithoutId() {
        // given
        let csvWithoutId: String = ",text,важная,,false,64764856.0,"
        
        // when
        let toDoItem = ToDoItem.parse(csv: csvWithoutId)
        
        // then
        XCTAssert((toDoItem == nil), "CSV без id")
    }
    
    func testCsvWithoutText() {
        // given
        let csvWithoutText: String = "drgfgr,,важная,,false,64764856.0,"
        
        // when
        let toDoItem = ToDoItem.parse(csv: csvWithoutText)
        
        // then
        XCTAssert((toDoItem == nil), "CSV без text")
    }
    
    func testCsvWithoutStartTime() {
        // given
        let csvHasWithoutStartTime: String = "gdffhh,text,важная,,false,,"
        
        // when
        let toDoItem = ToDoItem.parse(csv: csvHasWithoutStartTime)
        
        // then
        XCTAssert((toDoItem == nil), "CSV без startTime")
    }
    
    func testCsvImportant() {
        // given
        let csvImportant: String = "dgfdjhhzd,text,важная,,false,64764856.0,"
        
        // when
        let toDoItem = ToDoItem.parse(csv: csvImportant)
        
        // then
        XCTAssert((toDoItem?.importance == Importance.important), "CSV важный item")
    }
    
    func testCsvUnimportant() {
        // given
        let csvUnimportant: String = "dgfdjhhzd,text,неважная,,false,64764856.0,"
        
        // when
        let toDoItem = ToDoItem.parse(csv: csvUnimportant)
        
        // then
        XCTAssert((toDoItem?.importance == Importance.unimportant), "CSV неважный item")
    }
    
    func testCsvCommon() {
        // given
        let csvEmpty: String = "dgfdjhhzd,text,,,false,64764856.0,"
        let csvRubbish: String = "dgfdjhhzd,text,gfbsn,,false,64764856.0,"
        
        // when
        let toDoItemEmpty = ToDoItem.parse(csv: csvEmpty)
        let toDoItemRubbish = ToDoItem.parse(csv: csvRubbish)
        
        // then
        XCTAssert((toDoItemEmpty?.importance == Importance.common), "CSV обычный item")
        XCTAssert((toDoItemRubbish?.importance == Importance.common), "CSV обычный item")
    }
    
    func testFileCacheAppendItem() {
        // given
        let item = ToDoItem(id: "fghfsdas324", text: "dfcghjd", importance: "важная", deadLineTimeIntervalSince1970: nil, isDone: true, startTimeIntervalSince1970: 364565446.0, changeTimeIntervalSince1970: nil)
        let itemsCount = fileCache.items.count
        
        // when
        fileCache.appendItem(item)
        
        // then
        XCTAssert((itemsCount + 1 == fileCache.items.count), "FileCache проверка функции appendItem")
    }
    
    func testFileCacheAppendItemOnDublicates() {
        // given
        let item = ToDoItem(id: "fghfsdas324", text: "dfcghjfdbfbsd", importance: "неважная", deadLineTimeIntervalSince1970: nil, isDone: true, startTimeIntervalSince1970: 364565446.0, changeTimeIntervalSince1970: nil)
        fileCache.appendItem(item)
        let itemsCount = fileCache.items.count
        
        // when
        fileCache.appendItem(item)
        // then
        XCTAssert((itemsCount == fileCache.items.count), "FileCache проверка функции appendItem на работу с дубликатами")
    }

    func testFileCacheDeleteItem() {
        // given
        let item = ToDoItem(id: "fghfsdas324", text: "dfcghjfdbfbsd", importance: "неважная", deadLineTimeIntervalSince1970: nil, isDone: true, startTimeIntervalSince1970: 364565446.0, changeTimeIntervalSince1970: nil)
        fileCache.appendItem(item)
        let itemsCount = fileCache.items.count
        
        // when
        fileCache.deleteItem(for: item.id)
        // then
        XCTAssert((itemsCount == fileCache.items.count + 1), "FileCache проверка функции deleteItem")
    }
    
    func testFileCacheDeleteItemIfIdDoNotExist() {
        // given
        let item = ToDoItem(id: "fghfsdas324", text: "dfcghjfdbfbsd", importance: "неважная", deadLineTimeIntervalSince1970: nil, isDone: true, startTimeIntervalSince1970: 364565446.0, changeTimeIntervalSince1970: nil)
        fileCache.appendItem(item)
        let itemsCount = fileCache.items.count
        
        // when
        fileCache.deleteItem(for: "gfghj")
        // then
        XCTAssert((itemsCount == fileCache.items.count), "FileCache проверка функции deleteItem на работу, если передан id, которого нет в items")
    }
}
