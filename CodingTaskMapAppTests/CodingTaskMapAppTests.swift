import XCTest
@testable import CodingTaskMapApp

class SixtCodingTaskMapAppTests: XCTestCase {

    func testCarListLoadingFromJSON() throws {
        let decoder = JSONDecoder()
        guard let url = Bundle.main.url(forResource: "cars", withExtension: "json") else { XCTFail("cars.json missing"); exit(1) }
        let jsonData = try Data(contentsOf: url)
        let cars = try decoder.decode([Car].self, from: jsonData)
		
        XCTAssert(cars.first?.description == """
        Car {
        "id": "WMWSW31030T222518"
        "modelIdentifier": "mini"
        "modelName": "MINI"
        "name": "Vanessa"
        "make": "BMW"
        "group": "MINI"
        "color": "midnight_black"
        "series": "MINI"
        "fuelType": "D"
        "fuelLevel": "0.7"
        "transmission": "M"
        "licensePlate": "M-VO0259"
        "latitude": "48.134557"
        "longitude": "11.576921"
        "innerCleanliness": "REGULAR"
        "carImageUrl": "https://cdn.sixt.io/codingtask/images/mini.png"
        }
        """)

        XCTAssert(cars.last?.description == """
        Car {
        "id": "WMWSW31060T114071?"
        "modelIdentifier": "mini"
        "modelName": "MINI"
        "name": "Vicki+"
        "make": "BMW"
        "group": "MINI"
        "color": "schwarz"
        "series": "MINI"
        "fuelType": "D"
        "fuelLevel": "0.98"
        "transmission": "M"
        "licensePlate": "M-IL1296?"
        "latitude": "48.193826"
        "longitude": "11.563875"
        "innerCleanliness": "VERY_CLEAN"
        "carImageUrl": "https://cdn.sixt.io/codingtask/images/mini.png"
        }
        """)
		
        XCTAssert(cars.count == 28)
    }
}
