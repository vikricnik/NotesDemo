# Uncomment the next line to define a global platform for your project

use_frameworks!
workspace 'BSCDemo'

abstract_target 'utilsPods' do

  target 'BSCDemo' do
    project 'BSCDemo'
    platform :ios, '11.0'

    pod 'Moya'
    pod 'SwiftMessages'

    target 'BSCDemoTests' do
      platform :ios, '11.0'
      inherit! :search_paths
      # Pods for testing
    end
  end

end
