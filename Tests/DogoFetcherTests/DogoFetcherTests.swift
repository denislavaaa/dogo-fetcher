import XCTest
@testable import DogoFetcher

final class DogoFetcherTests: XCTestCase {
    
    var sut: DogoFetcher!
    
    func testGalleryIndexStartsFromZero() async {
        var outsideIndex: Int = Int.min
        await sut.setGalleryIndexObserver { index in
            outsideIndex = index
        }
        _ = try? await sut.getNextImage()
        XCTAssertEqual(outsideIndex, 0)
    }
    
    func testGalleryIncrementIndex() async {
        var outsideIndex: Int = Int.min
        await sut.setGalleryIndexObserver { index in
            outsideIndex = index
        }
        _ = try? await sut.getNextImage()
        _ = try? await sut.getNextImage()
        
        XCTAssertEqual(outsideIndex, 1)
    }
    
    func testGalleryDecrementIndex() async {
        var outsideIndex: Int = Int.min
        await sut.setGalleryIndexObserver { index in
            outsideIndex = index
        }
        _ = try? await sut.getNextImage()
        _ = try? await sut.getNextImage()
        
        _ = try? await sut.getPreviousImage()
        
        XCTAssertEqual(outsideIndex, 0)
    }
    
    func testGalleryReset() async {
        var outsideIndex: Int = Int.min
        await sut.setGalleryIndexObserver { index in
            outsideIndex = index
        }
        _ = try? await sut.getNextImage()
        _ = try? await sut.getNextImage()
        
        await sut.resetGallery()
        
        XCTAssertEqual(outsideIndex, -1)
        
        _ = try? await sut.getNextImage()
        XCTAssertEqual(outsideIndex, 0)
    }
    
    override func setUpWithError() throws {
        sut = DogoFetcher()
    }

    override func tearDownWithError() throws {
        sut = nil
    }
}
