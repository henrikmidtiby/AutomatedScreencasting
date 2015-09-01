LOGFILE := $(shell date +'%Y-%m-%d_%H.%M.%S')
# Freespace hardcoded to look at /dev/sda5.
FREESPACE := $(shell df -k . | awk 'NR==2{print$$4}')
REQUIRED_FREE_SPACE := 100000
ENOUGH_SPACE := $(shell if [ $(FREESPACE) -ge $(REQUIRED_FREE_SPACE) ]; then echo "EnoughSpace"; else echo "NotEnoughSpace"; fi)
FULLSCREEN := false


gimp:
	gimp blackscreen.png &

screencast:
	@# Check for enough diskspace (> 100MB)
ifeq ($(ENOUGH_SPACE), EnoughSpace)
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
	avconv -i $(LOGFILE)/screencast.ogv -vcodec copy  -vol 1024 $(LOGFILE)/screencasttemp.ogv
	python ../silenceremover.py
else
	@echo "Not enough space"
endif

croppedscreencast:
	@# Check for enough diskspace (> 100MB)
ifeq ($(ENOUGH_SPACE), EnoughSpace)
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
	avconv -i $(LOGFILE)/screencast.ogv -vcodec copy  -vol 1024 $(LOGFILE)/screencasttemp.ogv
	python ../silenceremover.py
else
	@echo "Not enough space"
endif

firstpart:
	# Parameters
	# -ss starttime
	# -t endtime
	avconv -i screencast.ogv -vcodec copy -acodec copy -ss 00:00:03 -t 00:32:20 01partOne.ogv

secondpart:
	# Parameters
	# -ss starttime
	# -t endtime
	avconv -i screencast.ogv -vcodec copy -acodec copy -ss 00:12:20 -t 00:22:20 02partTwo.ogv

convertavconv: 
	avconv -i screencast.ogv -vcodec mpeg4 -sameq -acodec libmp3lame screencastavconv.avi

convertmencoder:
	mencoder screencast.ogv -vc theora -ovc x264 -oac mp3lame -o screencastmencoder.avi


