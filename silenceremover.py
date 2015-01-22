# -*- coding: utf-8 -*-
"""
Created on Sun Aug 31 21:15:42 2014

@author: henrik
"""
import matplotlib.pyplot as plt
import numpy as np
from scipy.io import wavfile
import os
import subprocess


# http://stackoverflow.com/a/4494700/185475
def silent_segs(samples,threshold,min_dur):
    start = -1
    silent_segments = []
    for idx,x in enumerate(samples):
        if start < 0 and abs(x) < threshold:
            start = idx
        elif start >= 0 and abs(x) >= threshold:
            dur = idx-start
            if dur >= min_dur:
                silent_segments.append((start,dur))
            start = -1
    return silent_segments

def main():
    # Extract sound from video
    command = "ffmpeg -i screencasttemp.ogv sound.wav"
    print(command)
    subprocess.call(command, shell=True)
    
    # Load sound file
    fs, sig = wavfile.read('sound.wav')

    print("sampling rate = %d" % fs)
    print("samples: %d" % sig.shape)
    durationInSeconds = sig.shape[0] / fs
    print("duration: %f seconds" % (sig.shape[0] / fs))
    print("duration: %f min" % (sig.shape[0] / fs / 60.))

    sliceLength = fs * 0.1
    index = 0    
    soundLevels = []
    while True:
        index += sliceLength
        if(index > sig.shape[0]):
            break
        tempvals = sig[index:(index + sliceLength)]
        meanval = np.std(tempvals)
        soundLevels.append(meanval)


    # Number of seconds to protect with
    spacer = 0.3    

    # Keep the regions with voice
    noisyPeriods = []
    endOfLastSilentPeriod = spacer
    for (idx, seg) in enumerate(silent_segs(soundLevels, 200, 55)):
	(start, duration) = seg
	start /= 10.
	duration /= 10.
        noisyPeriods.append((endOfLastSilentPeriod - spacer, start + spacer))
        endOfLastSilentPeriod = start + duration
    noisyPeriods.append((endOfLastSilentPeriod, durationInSeconds + 5))

    print(noisyPeriods)

    command = "ffmpeg -i screencasttemp.ogv temp.mp4"
    print(command)
    subprocess.call(command, shell=True)

    outputs = ""
    for (idx, seg) in enumerate(noisyPeriods):
	(start, end) = seg
        duration = end - start
        if(start > 20):
            command = "ffmpeg -ss %f -i temp.mp4 -ss %f -t %f output%02d.mp4" % (start - 10, 10, duration, idx)
        else:
            command = "ffmpeg -i temp.mp4 -ss %f -t %f output%02d.mp4" % (start, duration, idx)
        print(command)
        subprocess.call(command, shell=True)

        outputs = outputs + " output%02d.mp4" % idx
    command = "mencoder -ovc copy -oac pcm %s -o combined.mp4" % outputs
    print(command)
    subprocess.call(command, shell=True)

  
    soundLevels = np.array(soundLevels)
    
    #plt.plot(soundLevels)
    #plt.show()
    # print(soundLevels)
    return
    #print("sampling rate = {} Hz, length = {} samples, channels = {}".format(fs, *sig.shape))

    
    # Determine avg volume for each 0.1 second period

main()  


# Extract part of video
# ./ffmpeg.static.64bit.2014-07-16/ffmpeg -i media/screencasttemp.ogv -ss 00:00:03 -t 00:00:25 -vcodec copy -acodec copy outputtester.ogv

