LOGFILE := $(shell date +'%Y-%m-%d_%H.%M.%S')
# Freespace hardcoded to look at /dev/sda5.
FREESPACE := $(shell df -k . | awk 'NR==2{print$$4}')
REQUIRED_FREE_SPACE := 100000
ENOUGH_SPACE := $(shell if [ $(FREESPACE) -ge $(REQUIRED_FREE_SPACE) ]; then echo "EnoughSpace"; else echo "NotEnoughSpace"; fi)
FULLSCREEN := false


gimp:
	gimp blackscreen.png &

enough_space:
	@# Check for enough diskspace (> 100MB)
ifeq ($(ENOUGH_SPACE), EnoughSpace)
else
	@echo "Not enough space"
	exit 1
endif

screencast: enough_space
	@echo $(LOGFILE)
	@mkdir $(LOGFILE)
	@cp Makefile $(LOGFILE)/Makefile
	@echo "Stop recording by pressing \"Crtl+Alt+q\""
ifeq ($(FULLSCREEN), true)
	@recordmydesktop --v_quality 63 --s_quality 10 --delay 1 --fps 10 -o $(LOGFILE)/screencast.ogv --stop-shortcut Control+Mod1+q
else
	@recordmydesktop -x 1680 -y 0 --width 1680 --height  1050 --v_quality 63 --s_quality 10 --delay 1 --fps 10 -o $(LOGFILE)/screencast.ogv --stop-shortcut Control+Mod1+q
	#@recordmydesktop -x 0 -y 0 --width 1680 --height  1050 --v_quality 63 --s_quality 10 --delay 1 --fps 10 -o $(LOGFILE)/screencast.ogv --stop-shortcut Control+Mod1+q
endif
	@echo $(LOGFILE)
	avconv -i $(LOGFILE)/screencast.ogv -vcodec copy  -vol 512 $(LOGFILE)/screencasttemp.ogv

croppedscreencast: enough_space
	@echo $(LOGFILE)
	@mkdir $(LOGFILE)
	@cp Makefile $(LOGFILE)/Makefile
	@echo "Stop recording by pressing \"Crtl+Alt+q\""
ifeq ($(FULLSCREEN), true)
	@recordmydesktop --v_quality 63 --s_quality 10 --delay 1 --fps 10 -o $(LOGFILE)/screencast.ogv --stop-shortcut Control+Mod1+q
else
	@recordmydesktop -x 1710 -y 90 --width 1350 --height  850 --v_quality 63 --s_quality 10 --delay 1 --fps 10 -o $(LOGFILE)/screencast.ogv --stop-shortcut Control+Mod1+q
	#@recordmydesktop -x 0 -y 0 --width 1680 --height  1050 --v_quality 63 --s_quality 10 --delay 1 --fps 10 -o $(LOGFILE)/screencast.ogv --stop-shortcut Control+Mod1+q
endif
	@echo $(LOGFILE)
	avconv -i $(LOGFILE)/screencast.ogv -vcodec copy  -vol 512 $(LOGFILE)/screencasttemp.ogv

