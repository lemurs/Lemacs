Pod::Spec.new do |s|
  s.name         = "NSAttributedStringMarkdownParser"
  s.version      = "0.0.1"
  s.summary      = "Utility class to convert an NSString containing markdown into an NSAttributedString."
  s.homepage     = "https://github.com/lemurs/NSAttributedStringMarkdownParser"
  s.license      = { :type => 'Apache', :file => 'LICENSE' }
  s.author       = { "lemurs" => "info@le.mu.rs" }
  s.authors      = { "lemurs" => "info@le.mu.rs", "myell0w" => "", "jverkoey" => "verkoey@gmail.com" }
  s.source       = { :git => "https://github.com/lemurs/NSAttributedStringMarkdownParser.git", :tag => "0.0.1" }
  s.ios.deployment_target = '7.0'
  s.source_files = 'src/*'
  s.requires_arc = true
end
