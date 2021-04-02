import numpy as np
import numpy.fft as fft
import math


class AFFT:
    '''This class compares the FFT of nacelle vibrations with an adaptive threshold based on rotorspeed.
    For each increment in rotorspeed, a unique adaptive threshold is selected and compared against the FFT output.
    The thresholds are saved in the file "AFFT_threshold.txt" and may be generated using the MATLAB program 
    "GenerateTextFiles.mlapp" within the FDC_FileGenerationTools folder in Luke Costello's MS Thesis directory. 

    For practical usage, one must first initiate an AFFT object using this class and relevant parameters, then
    load a text file using the command AFFT.load(filename). Finally, AFFT testing may be done using the command
    AFFT.examine(), which returns a list of frequencies (at multiples of the rotorspeed) that faults are detected.
    Care must be taken such that:
        1. The parameters in the __init__ function are identical to those used to create the thresholds
        2. The accelerations variable supplied to examine is identical to that 
    You can refer to a specific location in a threshold using AFFT.thr[i][j]
    where i is the threshold number, and j is the location in the threshold.'''
    def __init__(self,Fs=50,RPM_lo=32.5,RPM_hi=212.5,RPM_step=5,XP_monitor = [1,3],XP_bin=0.5):
        self.thr = []
        self.thr_short = []

        self.Fs=Fs
        self.RPMs = np.arange(RPM_lo,RPM_hi,RPM_step)

        self.threshs = []
        self.lastFreq = []
        self.lastSpect = []
        self.lastFreq_short = []
        self.lastSpect_short = []

        self.XP_monitor = XP_monitor
        self.XP_bin = XP_bin

        self.fault_flag = False
        self.has_tested = False

        self.last_five = [0,0,0,0,0]

    def load(self,fileName):
        '''Loads the fileName file into object memory.'''
        self.threshs = []
        self.RPMs = []
        with open(fileName) as file:
            for line in file:
                line = line[0:-1]
                if line[0]=='#':
                    line_list = line.split(',')
                    
                    nums = [float(x) for x in line_list[1:]]

                    self.RPMs.append(float(line_list[0][1:]))
                    self.threshs.append(nums)



    def selectThreshold(self,av_RPM):
        '''Selects the adaptive threshold closest to the average rotorspeed input as av_RPM'''
        compared = np.abs([x-av_RPM for x in self.RPMs])
        ind = compared.argmin()
        self.thr = self.threshs[ind]

    def compareToThreshold(self,spect):
        '''Compares the FFT output to the adaptive threshold selected.'''
        if self.thr_short == []:
            raise ValueError('Threshold not yet defined!')
    
        log = [ (spect[i] - self.thr_short[i])>=0 for i in range(0,len(spect))]
        fault = [i for i, n in enumerate(log) if n==True]


        return fault


    def FFT(self,sig):
        
        N = len(sig)
        sig_mean = sum(sig)/len(sig)
        sig_corr = [x - sig_mean for x in sig]
        spect = np.abs((fft.fft(sig_corr,N)))/N
        freq = fft.fftfreq(len(sig_corr),d=1/self.Fs)

        return [freq,spect]

    def extractXP(self,RPM_av,freq,spect):
        '''Extracts the frequency components in terms of multiples of the rotorspeed as specified by the XP_monitor variable.'''
        RPM_freq = RPM_av/60
        self.thr_short = []
        freq_short = []
        spect_short = []

        for XP in self.XP_monitor:
            freq_lo = RPM_freq*XP - self.XP_bin
            freq_hi = RPM_freq*XP + self.XP_bin

            compare_lo = np.abs([x-freq_lo for x in freq])
            ind_lo = np.argmin(compare_lo)
            compare_hi = np.abs([x-freq_hi for x in freq])
            ind_hi = np.argmin(compare_hi)

            [self.thr_short.append(x) for x in self.thr[ind_lo:ind_hi]]
            [freq_short.append(x) for x in freq[ind_lo:ind_hi]]
            [spect_short.append(x) for x in spect[ind_lo:ind_hi]]
        
        return [freq_short,spect_short]

    def examine(self,accels,RPMs):
        '''Use this command for using the AFFT algorithm in practical use. Selects the adaptive threshold for use,
        computes the FFT of the input data, extracts the desired frequency components, then compares the FFT output
        to the selected threshold. Returns any faults as multiples of the rotorspeed.'''
        #Compute average rotorspeed
        RPM_av = sum(RPMs)/len(RPMs)
        #Select threshold
        self.selectThreshold(RPM_av)
        #Compute FFT
        [freq,spect] = self.FFT(accels)
        self.lastFreq = freq
        self.lastSpect = spect
        #Extract desired frequencies, and compare to threshold
        [freq_short,spect_short] = self.extractXP(RPM_av,freq,spect)
        self.lastFreq_short = freq_short
        self.lastSpect_short = spect_short
        fault = self.compareToThreshold(spect_short)
        #Convert the faulty frequencies to multiples of rotorspeed
        fault_freqs = [freq_short[i]*60/RPM_av for i in fault]

        return [fault_freqs]