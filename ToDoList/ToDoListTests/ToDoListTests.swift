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
        
        testJsonMessWithDates()
        
        testJsonImportance()
        
        // testing property json
        testPropertyJsonNilKeys()
        
        // testing function parse for csv
        testCsvValid()
        
        testCsvInvalid()
        
        testCsvImportance()
        
        // testing property csv
        testPropertyCsvEmptyStrings()
        
        // testing FileCache class
        // testing function appendItem
        testFileCacheAppendItem()
        
        testFileCacheAppendItemOnDublicates()
        
        testFileCacheDeleteItem()
        
        testFileCacheDeleteItemIfIdDoNotExist()
    }

    func testPerformanceExample() throws {
    }
    
    //MARK: - testing parse(json: Any)
    
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
        
        let withoutId: [String: Any] = [
            "text": "dfcghjd",
            "importance": "важная",
            "isDone": true,
            "startTime": 4353788.0
        ]
        
        let invalidTextType: [String: Any] = [
            "id": "fghfsdas324",
            "text": 123,
            "importance": "важная",
            "isDone": true,
            "startTime": 4353788.0
        ]
        
        let withoutStartTime: [String: Any] = [
            "id": "fghfsdas324",
            "text": "hffhkffj",
            "importance": "важная",
            "isDone": true,
        ]
        
        // when
        let itemInvalid = ToDoItem.parse(json: jsonInvalid)
        let itemWithoutId = ToDoItem.parse(json: withoutId)
        let itemInvalidTextType = ToDoItem.parse(json: invalidTextType)
        let itemWithoutStartTime = ToDoItem.parse(json: withoutStartTime)
        
        // then
        XCTAssert((itemInvalid == nil), "Тест на невалидный json")
        XCTAssert((itemWithoutId == nil), "JSON без id")
        XCTAssert((itemInvalidTextType == nil), "JSON c невалидным типом text")
        XCTAssert((itemWithoutStartTime == nil), "JSON без startTime")
    }
    
    func testJsonMessWithDates() {
        // given
        let startTimeMoreEqualDeadLine: [String: Any] = [
            "id": "fghfsdas324",
            "text": "hffhkffj",
            "importance": "важная",
            "isDone": true,
            "startTime": 4353788.0,
            "deadLine": 435378.0
        ]
        
        let startTimeMoreEqualChangeTime: [String: Any] = [
            "id": "fghfsdas324",
            "text": "hffhkffj",
            "importance": "важная",
            "isDone": true,
            "startTime": 4353788.0,
            "changeTime": 435378.0
        ]
        
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
        let itemStartTimeMoreEqualDeadLine = ToDoItem.parse(json: startTimeMoreEqualDeadLine)
        let itemStartTimeMoreEqualChangeTime = ToDoItem.parse(json: startTimeMoreEqualChangeTime)
        let itemChangeTimeMoreEqualDeadLine = ToDoItem.parse(json: changeTimeMoreEqualDeadLine)
        
        // then
        XCTAssert((itemStartTimeMoreEqualDeadLine == nil), "JSON без startTime >= deadLine")
        XCTAssert((itemStartTimeMoreEqualChangeTime == nil), "JSON без startTime >= changeLine")
        XCTAssert((itemChangeTimeMoreEqualDeadLine == nil), "JSON без changeTime >= deadLine")
    }
    
    func testJsonImportance() {
        // given
        let jsonImportant: [String: Any] = [
            "id": "fghfsdas324",
            "text": "dfcghjd",
            "importance": "важная",
            "isDone": true,
            "startTime": 4353788.0
        ]
        
        let jsonUnimportant: [String: Any] = [
            "id": "fghfsdas324",
            "text": "dfcghjd",
            "importance": "неважная",
            "isDone": true,
            "startTime": 4353788.0
        ]
        
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
        let itemImportant = ToDoItem.parse(json: jsonImportant)
        let itemUnimportant = ToDoItem.parse(json: jsonUnimportant)
        let itemEmpty = ToDoItem.parse(json: jsonEmpty)
        let itemRubbish = ToDoItem.parse(json: jsonRubbish)
        
        // then
        XCTAssert((itemImportant?.importance == Importance.important), "JSON важный item")
        XCTAssert((itemUnimportant?.importance == Importance.unimportant), "JSON неважный item")
        XCTAssert((itemEmpty?.importance == Importance.common), "JSON обычный item")
        XCTAssert((itemRubbish?.importance == Importance.common), "JSON обычный item")
    }

    //MARK: - testing property json: Any
    
    func testPropertyJsonNilKeys() {
        // given
        let propertyJson: [String: Any] = [
            "id": "fghfsdas324",
            "text": "dfcghjd",
            "importance": "обычная",
            "isDone": true,
            "startTime": 4353788.0
        ]
        
        // when
        let toDoItem = ToDoItem.parse(json: propertyJson)
        let jsonDict = toDoItem?.json as? [String: Any]
        
        // then
        XCTAssert((jsonDict?["importance"] == nil), "JSON не имеет importance для обычная важность")
        XCTAssert((jsonDict?["deadLine"] == nil), "JSON не имеет deadLine")
        XCTAssert((jsonDict?["changeTime"] == nil), "JSON не имеет changeTime")
    }
    
    //MARK: - testing parse(csv: String)
    
    func testCsvValid() {
        // given
        let csvValid: String = "dgfdjhhzd,text,важная,,false,64764856.0,"
        
        // when
        let toDoItem = ToDoItem.parse(csv: csvValid)
        
        // then
        XCTAssert((toDoItem != nil), "CSV валидный")
    }
    
    func testCsvInvalid() {
        // given
        let csvHasNotSevenFeatures: String = "1,4,2,6,8,8"
        
        let csvWithoutId: String = ",text,важная,,false,64764856.0,"
        
        let csvWithoutText: String = "drgfgr,,важная,,false,64764856.0,"
        
        let csvHasWithoutStartTime: String = "gdffhh,text,важная,,false,,"
        
        // when
        let itemHasNotSevenFeatures = ToDoItem.parse(csv: csvHasNotSevenFeatures)
        let itemWithoutId = ToDoItem.parse(csv: csvWithoutId)
        let itemWithoutText = ToDoItem.parse(csv: csvWithoutText)
        let itemHasWithoutStartTime = ToDoItem.parse(csv: csvHasWithoutStartTime)
        
        // then
        XCTAssert((itemHasNotSevenFeatures == nil), "CSV имеет неверное количество фичей")
        XCTAssert((itemWithoutId == nil), "CSV без id")
        XCTAssert((itemWithoutText == nil), "CSV без text")
        XCTAssert((itemHasWithoutStartTime == nil), "CSV без startTime")
    }
    
    func testCsvImportance() {
        // given
        let csvImportant: String = "dgfdjhhzd,text,важная,,false,64764856.0,"
        
        let csvUnimportant: String = "dgfdjhhzd,text,неважная,,false,64764856.0,"
        
        let csvEmpty: String = "dgfdjhhzd,text,,,false,64764856.0,"
        
        let csvRubbish: String = "dgfdjhhzd,text,gfbsn,,false,64764856.0,"
        
        // when
        let itemImportant = ToDoItem.parse(csv: csvImportant)
        let itemUnimportant = ToDoItem.parse(csv: csvUnimportant)
        let itemEmpty = ToDoItem.parse(csv: csvEmpty)
        let itemRubbish = ToDoItem.parse(csv: csvRubbish)
        
        // then
        XCTAssert((itemImportant?.importance == Importance.important), "CSV важный item")
        XCTAssert((itemUnimportant?.importance == Importance.unimportant), "CSV неважный item")
        XCTAssert((itemEmpty?.importance == Importance.common), "CSV обычный item")
        XCTAssert((itemRubbish?.importance == Importance.common), "CSV обычный item")
    }
    
    //MARK: - testing property csv: Any
    
    func testPropertyCsvEmptyStrings() {
        // given
        let csvCommon: String = "dgfdjhhzd,text,обычная,,false,64764856.0,"
        
        let csvDeadline: String = "dgfdjhhzd,text,неважная,,false,64764856.0,64764858.0"
        
        let csvChangeTime: String = "dgfdjhhzd,text,важная,64764858.0,false,64764856.0,"
        
        // when
        let itemCommon = ToDoItem.parse(csv: csvCommon)
        let string = itemCommon?.csv.filter({ !"\n".contains($0) })
        let stringCommon = string?.components(separatedBy: ",")
        
        let itemDeadline = ToDoItem.parse(csv: csvDeadline)
        let stringDead = itemDeadline?.csv.filter({ !"\n".contains($0) })
        let stringDeadline = stringDead?.components(separatedBy: ",")
        
        let itemChangeTime = ToDoItem.parse(csv: csvChangeTime)
        let stringChange = itemChangeTime?.csv.filter({ !"\n".contains($0) })
        let stringChangeTime = stringChange?.components(separatedBy: ",")
        
        // then
        XCTAssert((stringCommon?[2] == ""), "CSV обычная важность")
        XCTAssert((stringCommon?.count == 7), "CSV обычная важность")
        XCTAssert((stringDeadline?[3] == ""), "CSV нет deadLine")
        XCTAssert((stringDeadline?.count == 7), "CSV обычная важность")
        XCTAssert((stringChangeTime?[6] == ""), "CSV нет changeTime")
        XCTAssert((stringChangeTime?.count == 7), "CSV обычная важность")
    }
    
    
    //MARK: - testing FileCache function appendItem(_ item: ToDoItem) and deleteItem(for id: String)
    
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
