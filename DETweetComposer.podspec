Pod::Spec.new do |s|
  s.name             = "DETweetComposer"
  s.version          = "0.1.0"
  s.summary          = "The iOS 4 compatible Tweet Sheet."

  s.description      = <<-DESC
                        The iOS 4 compatible Tweet Sheet.
                       DESC

  s.homepage         = "https://github.com/doubleencore/DETweetComposeViewController"
  s.license          = 'Apache 2.0'
  s.author           = { "林溢泽" => "linyize@gmail.com" }
  s.source           = { :git => "http://github.com/islate/DETweetComposer.git", :tag => "#{s.version}" }

  s.ios.deployment_target = '8.0'
  s.requires_arc = false
  s.source_files = "DETweetComposer/**/*.{h,m}"
  s.resource = 'DETweetComposer/**/*.{xib,png}'
end
