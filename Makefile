LOGFILE = $(shell date +'%Y-%m-%d_%H:%M')

gimp:
	gimp blackscreen.png &

screencast:
	echo $(LOGFILE)
	mkdir $(LOGFILE)
	cp Makefile $(LOGFILE)/Makefile
	#recordmydesktop --v_quality 20 --s_quality 10 --delay 3 --fps 10 --device plughw:0,0 -o $(LOGFILE)/screencast.ogv
	recordmydesktop --v_quality 20 --s_quality 10 --delay 3 --fps 10 -o $(LOGFILE)/screencast.ogv
	echo $(LOGFILE)

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

