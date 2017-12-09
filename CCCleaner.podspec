Pod::Spec.new do |s|

    s.name         = "CCCleaner"
    s.version      = "2.0.0"
    s.summary      = "A simple cleaner to get bundle cache size and erase them from disk or/and memory ."

    s.description  = <<-DESC
            "CCCleaner is a simple cleaner to get bundle cache size and erase them from disk or/and memory ."
                   DESC

    s.homepage     = "https://github.com/VArbiter/CCCleaner"

    s.license      = "MIT"

    s.author       = { "冯明庆" => "elwinfrederick@163.com" }

    s.platform     = :ios
    s.platform     = :ios, "8.0"

    s.source       = { :git => "https://github.com/VArbiter/CCCleaner.git", :tag => "#{s.version}" }

    s.source_files  = "CCCleaner", "CLEAN_CACHE_DEMO/CLEAN_CACHE_DEMO/CCCleanCache/*"

    s.frameworks = "WebKit", "Foundation"

    s.requires_arc = true
    s.dependency 'SDWebImage' , '~> 4.1.0'
    s.deprecated = true
    s.deprecated_in_favor_of = 'CCExtensionKit'

end
