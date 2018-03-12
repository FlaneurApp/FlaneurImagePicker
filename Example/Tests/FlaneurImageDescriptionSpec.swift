//
//  FlaneurImageDescriptionSpec.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 12/07/2017.
//  
//

import Quick
import Nimble
import FlaneurImagePicker
import Photos

class FlaneurImageDescriptionSpec: QuickSpec {
    let testJPGImageURL = URL(string: "https://www.w3schools.com/html/pic_mountain.jpg")!
    let testPNGImageURL = URL(string: "https://www.w3schools.com/html/pic_graph.png")!
    
    override func spec() {
        describe("A FlaneurImageDescriptor") {
            let flaneurImageDescriptionJPG = FlaneurImageDescriptor.url(testJPGImageURL)
            let flaneurImageDescriptionJPG_2 = FlaneurImageDescriptor.url(testJPGImageURL)
            
            let flaneurImageDescriptionPNG = FlaneurImageDescriptor.url(testPNGImageURL)

            let data1 = try! Data(contentsOf: testJPGImageURL)
            let image1 = UIImage(data: data1)!

            let data2 = try! Data(contentsOf: testJPGImageURL)
            let image2 = UIImage(data: data2)!
            
            let flaneurImageDescription_1 = FlaneurImageDescriptor.image(image1)
            let flaneurImageDescription_2 = FlaneurImageDescriptor.image(image2)
            
            context("After instances has been created") {
                it("Should be equal") {
                    expect(flaneurImageDescriptionJPG == flaneurImageDescriptionJPG_2).to(beTrue())
                }
                
                it("Should not be equal") {
                    expect(flaneurImageDescriptionJPG == flaneurImageDescriptionPNG).to(beFalse())
                }
                
                it("Should not be equal") {
                    // OK, they are the same image BUT...
                    // 1. UIImage is supposed to be equatable so we should rely on it
                    // 2.
                    expect(flaneurImageDescription_1 == flaneurImageDescription_2).to(beFalse())
                }
                
                it("Should not be equal") {
                    expect(flaneurImageDescription_1 == FlaneurImageDescriptor.image(UIImage())).to(beFalse())
                }
                
                it("Should not be equal") {
                    expect(flaneurImageDescription_1 == flaneurImageDescriptionPNG).to(beFalse())
                }
            }
        }
    }
}
