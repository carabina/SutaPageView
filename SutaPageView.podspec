Pod::Spec.new do |s|

  s.name         = "SutaPageView"
  s.version      = "0.0.1"
  s.summary      = "A paging view."
  s.homepage     = "https://github.com/shien7654321/SutaPageView"
  s.author       = { "Suta" => "shien7654321@163.com" }
  s.source       = { :git => "https://github.com/shien7654321/SutaPageView.git", :tag => s.version.to_s }
  s.platform     = :ios, "8.0"
  s.requires_arc = true
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.frameworks   = "Foundation", "UIKit"
  s.source_files = "SutaPageView/*.{h,m}"
  s.compiler_flags = "-fmodules"
  s.description    = <<-DESC
  SutaPageView is a paging view..
                       DESC

end
