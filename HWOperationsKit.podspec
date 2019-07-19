#
# Be sure to run `pod lib lint HWOperationsKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HWOperationsKit'
  s.version          = '0.2.0'
  s.summary          = 'HWOperationsKit custom operation to make you easier to use Operation.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
HWOperationsKit custom operation to make you easier to use Operation.
Use Operation to chain or group more easier.
                       DESC

  s.homepage         = 'https://github.com/HeathWang/HWOperationsKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'HeathWang' => 'yishu.jay@gmail.com' }
  s.source           = { :git => 'https://github.com/HeathWang/HWOperationsKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'HWOperationsKit/Classes/**/*'
  s.public_header_files = 'HWOperationsKit/Classes/**/*.h'
  s.frameworks = 'UIKit'
  
  # s.dependency 'AFNetworking', '~> 2.3'
end
