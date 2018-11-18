#!/bin/bash

mv /SkankSwitch/Install/AppleInternal /AppleInternal
mv /SkankSwitch/Install/ARMDisassembler.framework /System/Library/PrivateFrameworks/ARMDisassembler.framework
mv /SkankSwitch/Install/CHUD.framework /System/Library/PrivateFrameworks/CHUD.framework
mv /SkankSwitch/Install/Coach.framework /System/Library/PrivateFrameworks/Coach.framework
mv /SkankSwitch/Install/DiskImages.framework /System/Library/PrivateFrameworks/DiskImages.framework
mv /SkankSwitch/Install/diStorm.framework /System/Library/PrivateFrameworks/diStorm.framework
mv /SkankSwitch/Install/iPodCalendars.framework /System/Library/PrivateFrameworks/iPodCalendars.framework
mv /SkankSwitch/Install/iPodContacts.framework /System/Library/PrivateFrameworks/iPodContacts.framework
mv /SkankSwitch/Install/MediaKit.framework /System/Library/PrivateFrameworks/MediaKit.framework
mv /SkankSwitch/Install/NDISASM.framework /System/Library/PrivateFrameworks/NDISASM.framework
mv /SkankSwitch/Install/PerfTool.framework /System/Library/PrivateFrameworks/PerfTool.framework
mv /SkankSwitch/Install/PHTesting.framework /System/Library/PrivateFrameworks/PHTesting.framework
mv /SkankSwitch/Install/PPCDisasm.framework /System/Library/PrivateFrameworks/PPCDisasm.framework
mv /SkankSwitch/Install/Symbolication.framework /System/Library/PrivateFrameworks/Symbolication.framework
chmod +rwx /AppleInternal/Applications/SkankPhone.app/SkankPhone
rm -rf /SkankSwitch/Install