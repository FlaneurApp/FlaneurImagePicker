import UIKit
import FlaneurImagePicker

struct ImageBenchmark {
    let name: String
    let image: UIImage

    init(name: String, image: UIImage? = nil) {
        self.name = name

        if let image = image {
            self.image = image
        } else {
            // Find it from its name
            guard let image = UIImage(named: name) else {
                fatalError("Couldn't load image named \(name)")
            }
            self.image = image
        }
    }

    var bitmapBytesCount: Double {
        return Double(image.size.width * image.size.height * 3.0)
    }

    func jpegData(compressionQuality: CGFloat) -> Data? {
        return UIImageJPEGRepresentation(image, compressionQuality)
    }

    func pngData() -> Data? {
        return UIImagePNGRepresentation(image)
    }

    static func printCSVHeader() {
        print("Name,Width,Height,Bitmap,JPEG 0.0,JPEG 0.1,JPEG 0.2,JPEG 0.3,JPEG 0.4,JPEG 0.5,JPEG 0.6,JPEG 0.7,JPEG 0.8,JPEG 0.9,JPEG 1.0,PNG")
    }

    func createAndExportAll() {
        var cvsOutput: [CustomStringConvertible] = [name]
        cvsOutput.append(Int(image.size.width))
        cvsOutput.append(Int(image.size.height))
        cvsOutput.append(Int(bitmapBytesCount))
        for compressionQuality in stride(from: 0.0, through: 1.0, by: 0.1) {
            guard let jpegData = jpegData(compressionQuality: CGFloat(compressionQuality)) else {
                fatalError("Couldn't generate JPEG representation of the image")
            }
            cvsOutput.append(jpegData.count)
            save(data: jpegData, filename: "\(name)-\(compressionQuality).jpg")
        }

        guard let pngData = pngData() else {
            fatalError("Couldn't generate PNG representation of the image")
        }
        cvsOutput.append(pngData.count)
        save(data: pngData, filename: "\(name).png")
        print(cvsOutput.map { $0.description }.joined(separator: ","))
    }

    func save(data: Data, filename: String) {
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory,
                                                           in: .userDomainMask,
                                                           appropriateFor: nil,
                                                           create: true)
            let newDocURL = documentsURL.appendingPathComponent(filename)
            try data.write(to: newDocURL)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

class BenchmarkProcessorViewController: UIViewController {
    let imageView1 = UIImageView()
    let imageView2 = UIImageView()
    let imageView3 = UIImageView()
    let imageView4 = UIImageView()

    let allImages = [
        ImageBenchmark(name: "alex-perez-550776-unsplash"),
        ImageBenchmark(name: "ashley-knedler-43546-unsplash"),
        ImageBenchmark(name: "clem-onojeghuo-200300-unsplash"),
        ImageBenchmark(name: "dawid-sobolewski-285650-unsplash")
    ]

    let saveButton = UIButton(type: .system)
    let imageRatio: CGFloat = 4.0 / 3.0
    let processor = PreUploadProcessor()

    var imageRatioInverse: CGFloat {
        return 1.0 / imageRatio
    }

    var allImageViews: [UIImageView] {
        return [ imageView1, imageView2, imageView3, imageView4 ]
    }

    private func configureSaveButton(b: UIButton) {
        b.setTitle("Process", for: .normal)
        b.addTarget(self, action: #selector(processAndSaveAction(_:)), for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        imageView1.image = allImages[0].image
        imageView2.image = allImages[1].image
        imageView3.image = allImages[2].image
        imageView4.image = allImages[3].image

        allImageViews.forEach { imageView in
            imageView.backgroundColor = .lightGray
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
        }

        configureSaveButton(b: saveButton)
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // First row
            imageView1.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0.0),
            imageView2.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0.0),
            imageView1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            imageView2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            imageView1.trailingAnchor.constraint(equalTo: imageView2.leadingAnchor, constant: 0.0),
            imageView1.widthAnchor.constraint(equalTo: imageView2.widthAnchor, multiplier: 1.0),
            imageView1.heightAnchor.constraint(equalTo: imageView1.widthAnchor, multiplier: imageRatioInverse),
            imageView2.heightAnchor.constraint(equalTo: imageView2.widthAnchor, multiplier: imageRatioInverse),
            // Second row
            imageView3.topAnchor.constraint(equalTo: imageView1.bottomAnchor, constant: 0.0),
            imageView4.topAnchor.constraint(equalTo: imageView2.bottomAnchor, constant: 0.0),
            imageView3.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            imageView4.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            imageView3.trailingAnchor.constraint(equalTo: imageView4.leadingAnchor, constant: 0.0),
            imageView3.widthAnchor.constraint(equalTo: imageView4.widthAnchor, multiplier: 1.0),
            imageView3.heightAnchor.constraint(equalTo: imageView3.widthAnchor, multiplier: imageRatioInverse),
            imageView4.heightAnchor.constraint(equalTo: imageView4.widthAnchor, multiplier: imageRatioInverse),
            // Save button
            saveButton.topAnchor.constraint(equalTo: imageView3.bottomAnchor, constant: 32.0),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
    }

    @IBAction func printSliderValue(_ sender: Any? = nil) {
        guard let slider = sender as? UISlider else { return }
        print("slider.value: \(slider.value)")
    }

    @IBAction func processAndSaveAction(_ sender: Any? = nil) {
        ImageBenchmark.printCSVHeader()
        allImages.forEach { image in
            DispatchQueue.global().async {
                image.createAndExportAll()
                guard let resizedImage = self.processor.resizeImage(image.image, targetWidth: 1125.0) else {
                    fatalError("Coudln't resize image")
                }
                let processedImage = ImageBenchmark(name: "\(image.name)_processed", image: resizedImage)
                processedImage.createAndExportAll()
            }
        }
    }


}
