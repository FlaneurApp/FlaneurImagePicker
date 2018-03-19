import Quick
import Nimble
import FlaneurImagePicker

class PreUploadProcessorSpec: QuickSpec {
    override func spec() {
        describe("PreUploadProcessor") {
            it("can resize an image without crashing") {
                let preprocessor = PreUploadProcessor()
                let myImage = UIImage(named: "alex-perez-550776-unsplash")
                expect(myImage).toNot(beNil())
                let myResizedImage = preprocessor.resizeImage(myImage!, targetWidth: 1125.0)
                expect(myResizedImage).toNot(beNil())
                expect(myResizedImage?.size.width).to(equal(1125.0))
                expect(myResizedImage?.size.height).to(equal(843.0))
                expect(UIImageJPEGRepresentation(myResizedImage!, 0.6)).toNot(beNil())
            }

            it("can (cheaply?) resize an image without crashing") {
                let preprocessor = PreUploadProcessor()
                let myImage = UIImage(named: "alex-perez-550776-unsplash")
                expect(myImage).toNot(beNil())
                let myResizedImage = preprocessor.cheapResizeImage(myImage!, targetWidth: 1125.0)
                expect(myResizedImage).toNot(beNil())
                expect(myResizedImage?.size.width).to(equal(1125.0))
                expect(myResizedImage?.size.height).to(equal(843.0))
                expect(UIImageJPEGRepresentation(myResizedImage!, 0.6)).toNot(beNil())
            }
        }

        describe("UIImage extension") {
            it("can conveniently get access to data") {
                let myImage = UIImage(named: "alex-perez-550776-unsplash")
                expect(myImage?.dataForUpload()).toNot(beNil())
            }
        }
    }
}

class PreUploadProcessorPerformanceTests: XCTestCase {
    func testPerformanceExample() {
        self.measure {
            let preprocessor = PreUploadProcessor()
            let myImage = UIImage(named: "alex-perez-550776-unsplash")
            for _ in 0..<50 {
                _ = preprocessor.resizeImage(myImage!, targetWidth: 1125.0)
            }
        }
    }

    func testCheapPerformanceExample() {
        self.measure {
            let preprocessor = PreUploadProcessor()
            let myImage = UIImage(named: "alex-perez-550776-unsplash")
            for _ in 0..<50 {
                _ = preprocessor.cheapResizeImage(myImage!, targetWidth: 1125.0)
            }
        }
    }
}
