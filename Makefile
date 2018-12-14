LOGFILE := "$(shell date +'%Y-%m-%d_%H.%M.%S') $(shell zenity --entry --text="Video emne" )"
# Freespace hardcoded to look at /dev/sda5.
FREESPACE := $(shell df -k . | awk 'NR==2{print$$4}')
REQUIRED_FREE_SPACE := 100000
ENOUGH_SPACE := $(shell if [ $(FREESPACE) -ge $(REQUIRED_FREE_SPACE) ]; then echo "EnoughSpace"; else echo "NotEnoughSpace"; fi)
RECORDMYDESKTOP_PARAMERES := --v_quality 63 --s_quality 10 --delay 1 --fps 10 -o $(LOGFILE)/screencast.ogv --stop-shortcut Control+Mod1+q 
POST_PROCESS_VIDEO := ffmpeg -i $(LOGFILE)/screencast.ogv -vcodec h264 -strict experimental -max_muxing_queue_size 400 -af volume=volume=12dB $(LOGFILE)/screencasttemp.mp4
ADD_BLACK_LOGO := ffmpeg -i $(LOGFILE)/screencast.ogv -i sdu-logo-black-with-border-small.png -filter_complex "overlay=x=(main_w-overlay_w):y=(main_h-overlay_h)" -max_muxing_queue_size 4000 $(LOGFILE)/video_with_black_logo.mp4
ADD_WHITE_LOGO := ffmpeg -i $(LOGFILE)/screencast.ogv -i sdu-logo-white-with-border-small.png -filter_complex "overlay=x=(main_w-overlay_w):y=(main_h-overlay_h)" -max_muxing_queue_size 4000 $(LOGFILE)/video_with_white_logo.mp4
USE_BUILTIN_SCREEN := true
LVDS_RECORDING_AREA := $(shell xrandr | grep LVDS | sed 's/LVDS-0 connected \([0-9]*\)x\([0-9]*\)+\([0-9]*\)+\([0-9]*\).*/-x \3 -y \4 --width \1 --height \2/')
DP21_RECORDING_AREA := $(shell xrandr | grep DP-2-1 | sed 's/DP-2-1 connected primary \([0-9]*\)x\([0-9]*\)+\([0-9]*\)+\([0-9]*\).*/-x \3 -y \4 --width \1 --height \2/')

gimp:
	gimp blackscreen.xcf &

enough_space:
	@# Check for enough free discspace (> 100MB)
ifeq ($(ENOUGH_SPACE), EnoughSpace)
else
	@echo "Not enough space"
	exit 1
endif

prepare_screencasting:
	@echo $(LOGFILE)
	@mkdir $(LOGFILE)
	@cp Makefile $(LOGFILE)/Makefile
	@echo "Stop recording by pressing \"Crtl+Alt+q\""

externalfullscreen: enough_space prepare_screencasting
	@# Recording area is the entire external screen.
	@recordmydesktop $(DP21_RECORDING_AREA) $(RECORDMYDESKTOP_PARAMERES)
	@echo $(LOGFILE)
	$(POST_PROCESS_VIDEO)
	$(ADD_BLACK_LOGO)
	$(ADD_WHITE_LOGO)

internalfullscreen: enough_space prepare_screencasting
	@# Recording area is the entire builtin LDC display.
	recordmydesktop $(LVDS_RECORDING_AREA) $(RECORDMYDESKTOP_PARAMERES)
	@echo $(LOGFILE)
	$(POST_PROCESS_VIDEO)
	$(ADD_BLACK_LOGO)
	$(ADD_WHITE_LOGO)

externalcroppedscreencast: enough_space prepare_screencasting
	@# Recording area matches the canvas area in gimp using an external screen.
	# @recordmydesktop -x 1710 -y 90 --width 1350 --height  850 $(RECORDMYDESKTOP_PARAMERES)
	@recordmydesktop -x 1980 -y 130 --width 2200 --height  1238 $(RECORDMYDESKTOP_PARAMERES)
	@echo $(LOGFILE)
	$(POST_PROCESS_VIDEO)
	$(ADD_BLACK_LOGO)
	$(ADD_WHITE_LOGO)

internalcroppedscreencast: enough_space prepare_screencasting
	@# Recording area matches the canvas area in gimp using the builtin LDC display.
	@recordmydesktop -x 26 -y 80 --width 1232 --height  768 $(RECORDMYDESKTOP_PARAMERES)
	@echo $(LOGFILE)
	$(POST_PROCESS_VIDEO)
	$(ADD_BLACK_LOGO)
	$(ADD_WHITE_LOGO)

