Pod::Spec.new do |s|

    s.name         = "CCCleaner"
    s.version      = "1.1.0"
    s.summary      = "A simple cleaner to get bundle cache size and erase them from disk or/and memory ."

    s.description  = <<-DESC
            "CCCleaner is a simple cleaner to get bundle cache size and erase them from disk or/and memory ."
                   DESC

    s.homepage     = "https://github.com/VArbiter/CCCleaner"

    s.license      = "MIT"

    s.author             = { "冯明庆" => "elwinfrederick@163.com" }

    s.platform     = :ios
    s.platform     = :ios, "7.0"

    s.source       = { :git => "https://github.com/VArbiter/CCCleaner.git", :tag => "#{s.version}" }

    s.source_files  = "CCCleaner", "CLEAN_CACHE_DEMO/CLEAN_CACHE_DEMO/CCCleanCache/*.{h,m}"

    s.frameworks = "WebKit", "Foundation"

    s.requires_arc = true
    s.dependency "SDWebImage" 


end
