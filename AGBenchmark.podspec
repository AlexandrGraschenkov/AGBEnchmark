Pod::Spec.new do |s|
  s.name          = "AGBenchmark"
  s.version       = "1.0.0"
  s.summary       = "Small library for easy benchmark your ObjC, Swift and C++ code"
  s.description   = "I use it for benchmark part of algorithm writed on C++. Unforteniatly did't find any library for this purpose. Hope thap library will help somebody."
  s.homepage      = "https://github.com/AlexandrGraschenkov/AGBenchmark"
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.author        = { "Alexandr Graschenkov" => "alexandr.graschenkov91@gmail.com" }
  s.platform      = :ios, '5.0'
  s.source        = { :git => "https://github.com/AlexandrGraschenkov/AGBenchmark.git", :tag => "v#{s.version}" }
  s.source_files  = 'AGBenchmark/**/*.{h,m,mm}'
  s.requires_arc  = true
  s.framework     = "Foundation"
end