LOGFILE = $(shell date +'%Y-%m-%d_%H:%M:%S')
# Freespace hardcoded to look at /dev/sda5.
FREESPACE = $(shell df -k . | awk 'NR==2{print$$4}')
REQUIRED_FREE_SPACE = 100000
ENOUGH_SPACE = $(shell if [ $(FREESPACE) -ge $(REQUIRED_FREE_SPACE) ]; then echo "EnoughSpace"; else echo "NotEnoughSpace"; fi)

gimp:
	gimp blackscreen.png &

screencast:
	@# Check for enough diskspace (> 100MB)
ifeq ($(ENOUGH_SPACE), EnoughSpace)
	@echo $(LOGFILE)
	@mkdir $(LOGFILE)
	@cp Makefile $(LOGFILE)/Makefile
	##recordmydesktop --v_quality 20 --s_quality 10 --delay 3 --fps 10 --device plughw:0,0 -o $(LOGFILE)/screencast.ogv
	@echo "Stop recording by pressing \"Crtl+Alt+q\""
	@recordmydesktop --v_quality 63 --s_quality 10 --delay 1 --fps 10 -o $(LOGFILE)/screencast.ogv --stop-shortcut Control+Mod1+q
	@echo $(LOGFILE)
else
	@echo "Not enough space"
endif

firstpart:
	# Parameters
	# -ss starttime
	# -t endtime
	ffmpeg -i screencast.ogv -vcodec copy -acodec copy -ss 00:00:03 -t 00:32:20 01partOne.ogv

secondpart:
	# Parameters
	# -ss starttime
	# -t endtime
	ffmpeg -i screencast.ogv -vcodec copy -acodec copy -ss 00:12:20 -t 00:22:20 02partTwo.ogv

convertffmpeg: 
	ffmpeg -i screencast.ogv -vcodec mpeg4 -sameq -acodec libmp3lame screencastffmpeg.avi

convertmencoder:
	mencoder screencast.ogv -vc theora -ovc x264 -oac mp3lame -o screencastmencoder.avi

