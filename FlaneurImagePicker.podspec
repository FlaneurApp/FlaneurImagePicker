Pod::Spec.new do |s|
  s.name             = 'FlaneurImagePicker'
  s.version          = '0.1.1beta'
  s.summary          = 'FlaneurImagePicker is an iOS image picker'

  s.description      = <<-DESC
                           FlaneurImagePicker is an iOS image picker that allows users to pick images from different sources (ex: user's library, user's camera, Instagram...).
                           It's highly customizable.
                       DESC

  s.homepage     = "https://github.com/FlaneurApp/FlaneurImagePicker"
  # s.screenshots  = "https://raw.githubusercontent.com/toto/FlaneurImagePicker/master/images/logo.png"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Flâneur" => "flaneurdev@bootstragram.com" }
  s.source       = { :git => "https://github.com/FlaneurApp/FlaneurImagePicker.git", :tag => s.version.to_s }

  s.ios.deployment_target = "9.0"

  s.module_name  = 'FlaneurImagePicker'

  s.source_files  = 'Sources/**/*'
  s.resource_bundle = { 'FlaneurImagePicker' => "Sources/Assets/*" }

  # s.requires_arc = true
  s.framework = 'UIKit', 'Photos'

  s.dependency 'IGListKit', '~> 3.0'
  s.dependency 'ActionKit', '~> 2.0' # Version 2.1 for Switf 4.0 compatibility (https://github.com/ActionKit/ActionKit/blob/master/CHANGELOG.md)
  s.dependency 'Kingfisher', '~> 3.10'

  # s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }
end
