//
//  FlaneurImageDescriptionSpec.swift
//  FlaneurImagePickerController
//
//  Created by Frenchapp on 12/07/2017.
//  
//

import Quick
import Nimble
import FlaneurImagePicker
import Photos

class FlaneurImageDescriptionSpec: QuickSpec {
    
    let testJPGImageURL = "https://www.w3schools.com/html/pic_mountain.jpg"
    let testPNGImageURL = "https://www.w3schools.com/html/pic_graph.png"
    
    override func spec() {
        describe("A FlaneurImageDescription") {
            
            it("Should not be created on nil url") {
                let flaneurImageDescription = FlaneurImageDescription(imageURL: nil)
                expect(flaneurImageDescription).to(beNil())
            }

            it("Should be created if url points to a jpg file and set to .urlBased") {
                let flaneurImageDescription = FlaneurImageDescription(imageURLString: self.testJPGImageURL)
                expect(flaneurImageDescription).toNot(beNil())
                expect(flaneurImageDescription?.imageSource).to(equal(FlaneurImageDescriptionSourceType.urlBased))
            }
            
            it("Should not be created on nil image") {
                let flaneurImageDescription = FlaneurImageDescription(image: nil)
                expect(flaneurImageDescription).to(beNil())
            }
            
            it("Should be created on existing image and set to .imageBased") {
                let flaneurImageDescription = FlaneurImageDescription(image: UIImage())
                expect(flaneurImageDescription).toNot(beNil())
                expect(flaneurImageDescription?.imageSource).to(equal(FlaneurImageDescriptionSourceType.imageBased))
            }
            
            it("Should be created on existing Asset and set to .phassetBased") {
                let asset = PHAsset()
                let flaneurImageDescription = FlaneurImageDescription(asset: asset)
                expect(flaneurImageDescription).toNot(beNil())
                expect(flaneurImageDescription?.imageSource).to(equal(FlaneurImageDescriptionSourceType.phassetBased))
            }
            
            let flaneurImageDescriptionJPG = FlaneurImageDescription(imageURLString: testJPGImageURL)
            let flaneurImageDescriptionJPG_2 = FlaneurImageDescription(imageURLString: testJPGImageURL)
            
            let flaneurImageDescriptionPNG = FlaneurImageDescription(imageURLString: testPNGImageURL)

            let url = URL(string: testJPGImageURL)
            let data = try! Data(contentsOf: url!)
            let image1 = UIImage(data: data)

            let url2 = URL(string: testJPGImageURL)
            let data2 = try! Data(contentsOf: url2!)
            let image2 = UIImage(data: data2)
            
            let flaneurImageDescription_1 = FlaneurImageDescription(image: image1)
            let flaneurImageDescription_2 = FlaneurImageDescription(image: image2)
            
            context("After instances has been created") {
                it("Should be equal") {
                    expect(flaneurImageDescriptionJPG) == flaneurImageDescriptionJPG_2
                }
                
                it("Should not be equal") {
                    expect(flaneurImageDescriptionJPG) != flaneurImageDescriptionPNG
                }
                
                it("Should be equal") {
                    expect(flaneurImageDescription_1) == flaneurImageDescription_2
                }
                
                it("Should not be equal") {
                    expect(flaneurImageDescription_1) != FlaneurImageDescription(image: UIImage())
                }
                
                it("Should not be equal") {
                    expect(flaneurImageDescription_1) != flaneurImageDescriptionPNG
                }
            }

        }
    }
    
}
