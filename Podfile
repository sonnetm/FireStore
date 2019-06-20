# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'FireStoreTestApp' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FireStoreTestApp
  pod 'Alamofire', '~> 4.7'
  pod 'AlamofireNetworkActivityLogger', '~> 2.3'
  pod 'ObjectMapper', '~> 3.4'
  pod 'AlamofireObjectMapper', '~> 5.2.0'
  pod 'GoogleMaps','~> 2.7'
  pod 'GooglePlaces','~> 2.7'
  pod 'Pulsator', '~> 0.5.1'
	pod 'Firebase/Core'
	pod 'Firebase/Firestore'
  pod 'ReachabilitySwift'
  pod 'AWSAppSync'
  pod 'AWSCognito'
  pod 'AWSCognitoIdentityProvider'
  pod 'AWSLambda'
 
end
post_install do |installer|
  installer.pods_project.build_configurations.each do |config |
    config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
  end
  installer.pods_project.targets.each do |target|
    if ['ReachabilitySwift'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.0'
      end
    end
  end
end
