Pod::Spec.new do |s|  
  s.name             = "JJFMDB"
  s.version          = "2.0.3"
  s.summary          = "A SQLite Tool used on iOS."  
  s.description      = <<-DESC  
                       封装FMDB,数据Model直接写入数据库，开发者不需要写任何SQL语句。
                       DESC

  s.homepage         = "https://github.com/JJXYZ/JJFMDB"
  s.license          = 'MIT'  
  s.author           = { "JJ" => "hzhjjie@gmail.com" }  
  s.source           = { :git => "https://github.com/JJXYZ/JJFMDB.git", :tag => s.version.to_s }
  
  s.platform     = :ios, '5.0'
  s.requires_arc = true  
  
  s.source_files = "JJFMDB/Core/*","JJFMDB/Helper/*"

  s.frameworks = 'Foundation', 'UIKit'
  
  s.dependency 'FMDB', '~> 2.7.5'

end  
