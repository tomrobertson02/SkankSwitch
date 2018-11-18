#!/bin/bash

mv /System/Library/LaunchDaemons/com.apple.SkankPhone.plist /SkankSwitch/Resources/com.apple.SkankPhone.plist
mv /SkankSwitch/Resources/com.apple.SpringBoard.plist /System/Library/LaunchDaemons/com.apple.SpringBoard.plist
reboot
