#!/usr/bin/env ruby
require 'xcodeproj'
xcproj = Xcodeproj::Project.open("Example/Swifty.xcodeproj")
xcproj.recreate_user_schemes
xcproj.save
