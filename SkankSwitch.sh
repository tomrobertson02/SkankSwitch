#!/bin/bash

mv /System/Library/LaunchDaemons/com.apple.SpringBoard.plist /SkankSwitch/Resources/com.apple.SpringBoard.plist
mv /SkankSwitch/Resources/com.apple.SkankPhone.plist /System/Library/LaunchDaemons/com.apple.SkankPhone.plist
reboot