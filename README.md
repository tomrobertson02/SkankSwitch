# SkankSwitch
SkankSwitch is a set of bash scripts that allows you to install the required files for SkankPhone and switch between SkankPhone and Springboard.

### Usage

1. You need to copy the SkankSwitch folder to the root of your device using SCP or some other method of transferring files to your device.
2. SSH into your device, then run the following commands:
            chmod 775 /SkankSwitch/Install.sh
            chmod 775 /SkankSwitch/SkankSwitch.sh
            chmod 775 /SkankSwitch/SpringSwitch.sh
3. Now, run ./Install.sh
4. Now the required files for SkankPhone are on your device, you can run the command "./SkankSwitch/SkankSwitch.sh" (without quotes). Your device will now reboot. This will make your device load SkankPhone on startup rather than SpringBoard.
5. If you would like to switch back to SpringBoard, simply SSH into your device and run "./SkankSwitch/SpringSwitch.sh" (without quotes). This will make your device load SpringBoard on startup rather than SkankPhone.

### Notes

If your device is already set to run SkankPhone at startup, DO NOT run "SkankSwitch.sh". If your device is already set to run SpringBoard at startup, DO NOT run "SpringSwitch.sh".





