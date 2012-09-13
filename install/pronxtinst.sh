#!/bin/sh

INST_DIR=proNXT
URL_BUILD_ARM_TOOLCHAIN=http://lejos-osek.sourceforge.net/installation_linux_files/Ubuntu%2011.10/build_arm_toolchain.sh

if [ -n "$1" ]; then
	INST_DIR="$1"
fi 

install -d "$INST_DIR"
cd $INST_DIR

nothing() {
curl -LSso build_arm_toolchain.sh "$URL_BUILD_ARM_TOOLCHAIN" || exit 1

sh build_arm_toolchain.sh || exit 1

rm -rf build src build_arm_toolchain.sh || exit 1

curl -LSso ecrobotNXT.zip 'http://www.mathworks.com/matlabcentral/fileexchange/13399-embedded-coder-robot-nxt-demo?download=true' || exit 1

unzip ecrobotNXT.zip || exit 1

ECROBOTNXT_INST_DIR='ecrobotNXT'
DEST_ECROBOTNXT_INST_DIR='ecrobotnxt'

install -d "$DEST_ECROBOTNXT_INST_DIR"
cp -vr "$ECROBOTNXT_INST_DIR/environment/@NXT" "$DEST_ECROBOTNXT_INST_DIR"

ECROBOTNXT_INST_PRIVATE_FILES="\
	iGenerateMakefile.m \
	iGenerateSchedulerFiles.m \
	iGetAccelerationBlockPortID.m \
	iGetBluetoothDeviceAddress.m \
	iGetBluetoothDeviceMode.m \
	iGetColorSensorBlockPortID.m \
	iGetExportedFcnCallsScheduler.m \
	iGetFunctionName.m \
	iGetFunctionSource.m \
	iGetIRSeekerBlockPortID.m \
	iGetJSPSemaphore.m \
	iGetNumOfPeriodicalTasks.m \
	iGetOSEKResource.m \
	iGetOSEKResourcesForOIL.m \
	iGetPlatform.m \
	iGetRTWECGenCfiles.m \
	iGetTaskStackSize.m \
	iGetWavFileNames.m \
	iHasBluetoothBlock.m \
	iHasNXTGamePadADCDataLoggerBlock.m \
	iHasSoundWavWriteBlock.m \
	iHasUSBBlock.m \
	iIsR2007bOrPrev.m \
	iWriteECRobotCFG.m \
	iWriteECRobotDeviceInitialize.m \
	iWriteECRobotDeviceTerminate.m \
	iWriteECRobotExternalInterfaceH.m \
	iWriteECRobotMainForJSP.m \
	iWriteECRobotMainForOSEK.m \
	iWriteECRobotMainH.m \
	iWriteECRobotOIL.m \
	iWriteFunctionHeader.m \
	iWriteNXTDefinitionForOSEK.m \
	iWriteNXTFooter.m \
	iWriteNXTFunctionDescription.m \
	iWriteNXTHeader.m \
	iWriteNXTInclude.m \
	iWriteWavDataDeclarations.m \
	iWriteXCP_PAR.m\
"

ECROBOTNXT_INST_FILES="\
	AnalogGamePad.jpg \
	BATTERY_VOLTAGE.gif \
	BLUETOOTH.jpg \
	clearNXTSignalObjects.m \
	ColorSensor.jpeg \
	createNXTSignalObject.m \
	ecrobot_nxt_lib.mdl \
	HiTechnicSensor.jpg \
	InitAccessorBlock.m \
	InitDeviceSFunBlock.m \
	InitInterfaceBlock.m \
	LIGHT_SENSOR.gif \
	mtlb.wav \
	nxtbuild.m \
	nxtconfig.m \
	NXT_ICON.gif \
	ROTATION_SENSOR.gif \
	SERVO_MOTOR.gif \
	set_fcncallname.m \
	sfun_acceleration_sensor.c \
	sfun_acceleration_sensor.tlc \
	sfun_bt_rx.c \
	sfun_bt_rx.tlc \
	sfun_bt_tx.c \
	sfun_bt_tx.tlc \
	sfun_color_sensor.c \
	sfun_color_sensor.tlc \
	sfun_expfcncallsscheduler.c \
	sfun_gamepad_datalogger.c \
	sfun_gamepad_datalogger.tlc \
	sfun_ir_seeker.c \
	sfun_ir_seeker.tlc \
	sfun_soundtone.c \
	sfun_soundtone.tlc \
	sfun_soundvoltone.c \
	sfun_soundvoltone.tlc \
	sfun_usb_disconnect.c \
	sfun_usb_disconnect.tlc \
	sfun_usb_rx.c \
	sfun_usb_rx.tlc \
	sfun_usb_tx.c \
	sfun_usb_tx.tlc \
	sfunxymap2.m \
	slblocks.m \
	SONIC_SENSOR.gif \
	SOUND_SENSOR.gif \
	TOUCH_SENSOR.gif \
	track_template.bmp \
	track_template.wrl \
	usb1394_02_l.jpg \
	usb1394_02_r.jpg \
	writenxtdisplay.m \
	writevrtrack.m\
"

install -d "$DEST_ECROBOTNXT_INST_DIR/private"
for i in $ECROBOTNXT_INST_PRIVATE_FILES; do
	install -vt "$DEST_ECROBOTNXT_INST_DIR/private" "$ECROBOTNXT_INST_DIR/environment/private/$i"
done

for i in $ECROBOTNXT_INST_FILES; do
	install -vt "$DEST_ECROBOTNXT_INST_DIR" "$ECROBOTNXT_INST_DIR/environment/$i"
done

install -v "$ECROBOTNXT_INST_DIR/environment/BEEP.JPG" "$DEST_ECROBOTNXT_INST_DIR/BEEP.jpg"
install -v "$ECROBOTNXT_INST_DIR/environment/ENTER_BUTTON.JPG" "$DEST_ECROBOTNXT_INST_DIR/ENTER_BUTTON.jpg"
install -v "$ECROBOTNXT_INST_DIR/environment/joystick_ctrl.JPG" "$DEST_ECROBOTNXT_INST_DIR/joystick_ctrl.jpg"
install -v "$ECROBOTNXT_INST_DIR/environment/RUN_BUTTON.JPG" "$DEST_ECROBOTNXT_INST_DIR/RUN_BUTTON.jpg"
install -v "$ECROBOTNXT_INST_DIR/environment/steeringwheel_ctrl.JPG" "$DEST_ECROBOTNXT_INST_DIR/steeringwheel_ctrl.jpg"
install -v "$ECROBOTNXT_INST_DIR/environment/SYSTEM_CLOCK.GIF" "$DEST_ECROBOTNXT_INST_DIR/SYSTEM_CLOCK.gif"

rm -rf "$ECROBOTNXT_INST_DIR" "license.txt" "ecrobotNXT.zip"

cd -

patch "$INST_DIR/$DEST_ECROBOTNXT_INST_DIR/nxtbuild.m" < patches/nxtbuild.m.patch
patch "$INST_DIR/$DEST_ECROBOTNXT_INST_DIR/private/iGenerateMakefile.m" < patches/iGenerateMakefile.m.patch

cd $INST_DIR

curl -LSso nxtOSEK_v217.zip "http://downloads.sourceforge.net/project/lejos-osek/nxtOSEK/nxtOSEK_v217.zip"
unzip nxtOSEK_v217.zip
rm -f "nxtOSEK_v217.zip"

cd -

patch "$INST_DIR/nxtOSEK/ecrobot/tool_gcc.mak" < "patches/tool_gcc.mak.patch"
patch "$INST_DIR/nxtOSEK/ecrobot/ecrobot.mak" < "patches/ecrobot.mak.patch"
patch "$INST_DIR/nxtOSEK/ecrobot/ecrobot++.mak" < "patches/ecrobot++.mak.patch"

}

cd - 

EXTRAS_INST_DIR='extras'
cp -vr "$EXTRAS_INST_DIR" "$INST_DIR"

