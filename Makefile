LOGFILE := "$(shell date +'%Y-%m-%d_%H.%M.%S') $(shell zenity --entry --text="Video emne" )"
# Freespace hardcoded to look at /dev/sda5.
FREESPACE := $(shell df -k . | awk 'NR==2{print$$4}')
REQUIRED_FREE_SPACE := 100000
ENOUGH_SPACE := $(shell if [ $(FREESPACE) -ge $(REQUIRED_FREE_SPACE) ]; then echo "EnoughSpace"; else echo "NotEnoughSpace"; fi)
RECORDMYDESKTOP_PARAMERES := --v_quality 63 --s_quality 10 --delay 1 --fps 10 -o $(LOGFILE)/screencast.ogv --stop-shortcut Control+Mod1+q 
POST_PROCESS_VIDEO := avconv -i $(LOGFILE)/screencast.ogv -vcodec h264 -strict experimental -af volume=volume=12dB $(LOGFILE)/screencasttemp.mp4
USE_BUILTIN_SCREEN := true

gimp:
	gimp blackscreen.png &

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
	@recordmydesktop -x 1680 -y 0 --width 1680 --height  1050 $(RECORDMYDESKTOP_PARAMERES)
	@echo $(LOGFILE)
	$(POST_PROCESS_VIDEO)

internalfullscreen: enough_space prepare_screencasting
	@# Recording area is the entire builtin LDC display.
	@recordmydesktop $(RECORDMYDESKTOP_PARAMERES)
	@echo $(LOGFILE)
	$(POST_PROCESS_VIDEO)

externalcroppedscreencast: enough_space prepare_screencasting
	@# Recording area matches the canvas area in gimp using an external screen.
	@recordmydesktop -x 1710 -y 90 --width 1350 --height  850 $(RECORDMYDESKTOP_PARAMERES)
	@echo $(LOGFILE)
	$(POST_PROCESS_VIDEO)

internalcroppedscreencast: enough_space prepare_screencasting
	@# Recording area matches the canvas area in gimp using the builtin LDC display.
	@recordmydesktop -x 26 -y 80 --width 1232 --height  768 $(RECORDMYDESKTOP_PARAMERES)
	@echo $(LOGFILE)
	$(POST_PROCESS_VIDEO)

