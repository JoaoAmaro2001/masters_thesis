 %0.8 means 100/2*0.8 = 40Hz is the -6dB point, and 0.4 means 100/2*0.4 = 20Hz as a transition band width. 
 % Thus, EEG = pop_resample(EEG, 100, 0.8, 0.4); 
 % means 'Downsample the data to 100Hz using antialiasing filter with 40Hz cutoff point (-6dB) and transition bandwidth of 20 Hz so that the pass-band edge is 40-20/2 = 30 Hz, and the stop band is 40+20/2 = 50Hz.'
 
 EEG = pop_resample(EEG, 250, 0.8, 0.4); % attenuation from 75Hz (cutoff) to 125Hz