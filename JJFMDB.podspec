Pod::Spec.new do |s|  
  s.name             = "JJFMDB"
  s.version          = "1.0.2"
  s.summary          = "A Tool used on iOS."  
  s.description      = <<-DESC  
                       封装FMDB,使开发者远离SQL语句.
                       DESC

  s.homepage         = "https://github.com/JayJJ/JJFMDB"
  s.license          = 'MIT'  
  s.author           = { "Jay" => "hzhjjie@gmail.com" }  
  s.source           = { :git => "https://github.com/JayJJ/JJFMDB.git", :tag => s.version.to_s }
  
  s.platform     = :ios, '5.0'
  s.requires_arc = true  
  
  s.source_files = "JJFMDB/Core/*","JJFMDB/Helper/*"

  s.frameworks = 'Foundation', 'UIKit'

  s.dependency 'FMDB', '~> 2.2'
  s.dependency 'JJSandBox', '~> 1.0.0'
  
end  