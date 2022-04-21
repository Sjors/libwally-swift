#
#  Be sure to run `pod spec lint LibWally.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#

Pod::Spec.new do |spec|

  spec.name         = "LibWally"
  spec.version      = "0.0.1"
  spec.summary      = "Swift wrapper for LibWally."
  spec.description  = "Swift wrapper for LibWally, a collection of useful primitives for cryptocurrency wallets."
  spec.homepage     = "https://github.com/Sjors/libwally-swift"

  spec.license      = { :type => "MIT", :file => "LICENSE.md" }
  spec.authors      = { "Sjors Provoost" => "sjors@sprovoost.nl" }

  spec.platform     = :ios, "11"
  spec.swift_version = '5.0'

  spec.source       = { :git => "https://github.com/Sjors/libwally-swift.git", :tag => "v#{spec.version}", :submodules => true  }

  # Vendored Frameworks only supported >= 1.10.0
  spec.cocoapods_version = '>= 1.10.0'
  spec.vendored_frameworks = 'build/LibWallySwift.xcframework'

  spec.pod_target_xcconfig = {
                               'SWIFT_WHOLE_MODULE_OPTIMIZATION' => 'YES',
                               'SWIFT_INCLUDE_PATHS' => 'build/LibWallySwift.xcframework',
                               'LIBRARY_SEARCH_PATHS' => 'build/LibWallySwift.xcframework'
                             }
  spec.preserve_paths = 'LibWally/LibWally.modulemap', 'build/LibWallySwift.xcframework/*'

  spec.prepare_command = './build-libwally.sh -sdc'
  spec.module_map = 'LibWally/LibWally.modulemap'
end
