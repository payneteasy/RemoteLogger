rm xcodebuild.log

set -eux

time \
    xcodebuild clean build test \
    -project RemoteLogger.xcodeproj \
    -scheme RemoteLogger \
    -destination 'platform=iOS Simulator,name=iPhone 6s' \
    | tee xcodebuild.log \
    | xcpretty --report junit
