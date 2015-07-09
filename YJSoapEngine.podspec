Pod::Spec.new do |s|
s.name         = "YJSoapEngine"
s.version      = "1.0.0"
s.summary      = "A SoapEngine for iOS written in Objective - C"
s.description  = "YJSoapEngine is a class designed to simplify the implementation of a SOAP Web Service for iPhone, iPad. YJSoapEngine can be used to serialize custom objects for Soap Requests."
s.homepage     = "https://github.com/yj7/YJSoapEngine"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author             = { "Yash Jhunjhunwala" => "jhunjhunwalayash7@gmail.com" }
s.social_media_url   = "http://twitter.com/yashj97"
s.platform     = :ios, "6.0"
s.source       = { :git => "https://github.com/yj7/YJSoapEngine.git", :tag => "1.0.0"}
non_arc_files = "YJSoapEngine/GDataXMLNode.{h,m}","YJSoapEngine/XmlParser.{h,m}","YJSoapEngine/OrderedDictionary.{h,m}"
s.exclude_files = non_arc_files
s.public_header_files = "YJSoapEngine/YJSoapEngine.h"

s.subspec 'TypeMapping' do |ss|
ss.source_files = "YJSoapEngine/**/TypeMapping.{h,m}"
end

s.subspec 'no-arc' do |sna|
sna.dependency "YJSoapEngine/TypeMapping"
sna.requires_arc = false
sna.source_files = non_arc_files
end

s.subspec 'Core' do |ss|
ss.source_files = "YJSoapEngine/*.{h,m}"
ss.dependency "YJSoapEngine/no-arc"
ss.exclude_files = non_arc_files
ss.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2","OTHER_LDFLAGS" => "-lxml2" }
end
s.requires_arc = true
s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2","OTHER_LDFLAGS" => "-lxml2" }
end
