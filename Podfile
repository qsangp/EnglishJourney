# platform :ios, '9.0'

target 'EnglishJourney_2' do

  pod 'GoogleSignIn'
  pod 'Charts'
  pod 'LayoutHelper'
  post_install do |installer|
   installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
     config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end
   end
  end
  
end


