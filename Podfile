# platform :ios, '9.0'

target 'EnglishJourney_2' do

  pod 'GoogleSignIn'
  pod 'NVActivityIndicatorView'
  pod 'Charts'
  post_install do |installer|
   installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
     config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end
   end
  end
  
end


