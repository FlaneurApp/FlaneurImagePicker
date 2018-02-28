import UIKit
import FlaneurImagePicker

class BenchmarkProcessorViewController: UIViewController {
    let imageView1 = UIImageView()
    let imageView2 = UIImageView()
    let imageView3 = UIImageView()
    let imageView4 = UIImageView()

    let scaleSlider = UISlider()
    let ratioSlider = UISlider()

    let saveButton = UIButton(type: .system)

    let imageRatio: CGFloat = 4.0 / 3.0

    let processor = PreUploadProcessor()

    var imageRatioInverse: CGFloat {
        return 1.0 / imageRatio
    }

    var allImageViews: [UIImageView] {
        return [ imageView1, imageView2, imageView3, imageView4 ]
    }

    private func configureScaleSlider(s: UISlider) {
        s.value = 1.0
        s.minimumValue = 0.0
        s.maximumValue = 2.0
        s.addTarget(self, action: #selector(printSliderValue(_:)), for: .valueChanged)
    }

    private func configureRatioSlider(s: UISlider) {
        s.value = 1.0
        s.minimumValue = 0.0
        s.maximumValue = 2.0
        s.addTarget(self, action: #selector(printSliderValue(_:)), for: .valueChanged)
    }

    private func configureSaveButton(b: UIButton) {
        b.setTitle("Save", for: .normal)
        b.addTarget(self, action: #selector(processAndSaveAction(_:)), for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        imageView1.image = UIImage(named: "alex-perez-550776-unsplash")
        imageView2.image = UIImage(named: "ashley-knedler-43546-unsplash")
        imageView3.image = UIImage(named: "clem-onojeghuo-200300-unsplash")
        imageView4.image = UIImage(named: "dawid-sobolewski-285650-unsplash")

        allImageViews.forEach { imageView in
            imageView.backgroundColor = .lightGray
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
        }

        configureScaleSlider(s: scaleSlider)
        configureRatioSlider(s: ratioSlider)
        configureSaveButton(b: saveButton)
        view.addSubview(scaleSlider)
        view.addSubview(ratioSlider)
        view.addSubview(saveButton)
        scaleSlider.translatesAutoresizingMaskIntoConstraints = false
        ratioSlider.translatesAutoresizingMaskIntoConstraints = false
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
            // Sliders
            scaleSlider.topAnchor.constraint(equalTo: imageView3.bottomAnchor, constant: 32.0),
            scaleSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8.0),
            scaleSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 8.0),
            ratioSlider.topAnchor.constraint(equalTo: scaleSlider.bottomAnchor, constant: 16.0),
            ratioSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8.0),
            ratioSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 8.0),
            // Save button
            saveButton.topAnchor.constraint(equalTo: ratioSlider.bottomAnchor, constant: 32.0),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
    }

    func printImageInfo(_ image: UIImage) {
        let sizeInPixels = image.size

        let bitmapSizeInBytes = image.size.width * image.size.height * 3.0
        let jpeg00Size = UIImageJPEGRepresentation(image, 0.0)?.count
        let jpeg01Size = UIImageJPEGRepresentation(image, 0.1)?.count
        let jpeg02Size = UIImageJPEGRepresentation(image, 0.2)?.count
        let jpeg03Size = UIImageJPEGRepresentation(image, 0.3)?.count
        let jpeg04Size = UIImageJPEGRepresentation(image, 0.4)?.count
        let jpeg05Size = UIImageJPEGRepresentation(image, 0.5)?.count
        let jpeg06Size = UIImageJPEGRepresentation(image, 0.6)?.count
        let jpeg07Size = UIImageJPEGRepresentation(image, 0.7)?.count
        let jpeg08Size = UIImageJPEGRepresentation(image, 0.8)?.count
        let jpeg09Size = UIImageJPEGRepresentation(image, 0.9)?.count
        let jpeg10Size = UIImageJPEGRepresentation(image, 1.0)?.count
        let pngSize = UIImagePNGRepresentation(image)?.count

        print("## Image \(image):")
        print("")
        print("* Dimension: \(sizeInPixels)")
        print("* Bitmap size: \(bitmapSizeInBytes)")
        print("* JPEG size: \(jpeg00Size) / \(jpeg01Size) / \(jpeg02Size) / \(jpeg03Size) / \(jpeg04Size) / \(jpeg05Size) \(jpeg06Size) / \(jpeg07Size) \(jpeg08Size) \(jpeg09Size) \(jpeg10Size)")
        print("* PNG size: \(pngSize)")
        print("")
    }

    @IBAction func printSliderValue(_ sender: Any? = nil) {
        guard let slider = sender as? UISlider else { return }
        print("slider.value: \(slider.value)")
    }

    @IBAction func processAndSaveAction(_ sender: Any? = nil) {
        print("Scale: \(scaleSlider.value)")
        print("Ratio: \(ratioSlider.value)")

        allImageViews.forEach { imageView in
            let originalImage = imageView.image!
            imageView.image = nil
            //printImageInfo(originalImage)

            DispatchQueue.global().async { [weak self] in
                print("Starting \(originalImage): \(Date())")
                guard let resizedImage = PreUploadProcessor().resizeImage(originalImage, targetWidth: 1125.0) else { return print("Coudln't resize image") }
                print("Done \(originalImage): \(Date())")
                //printImageInfo(resizedImage)
            }
        }
    }
}
