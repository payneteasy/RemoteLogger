
Pod::Spec.new do |s|
  s.name             = 'RemoteLogger'
  s.version          = '0.1.4'
  s.summary          = 'Remote Logger for ios'
  s.description      = 'Send logs to HTTP server'
  s.homepage         = 'https://github.com/payneteasy/RemoteLogger'
  s.license          = 'APACHE'
  s.author           = { 'Evgeniy Sinev' => 'es@payneteasy.com' }
  s.source           = { :git => 'https://github.com/payneteasy/RemoteLogger.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.requires_arc = true

  s.source_files = 'RemoteLogger/*'
  s.public_header_files = 'RemoteLogger/*.h'
end
