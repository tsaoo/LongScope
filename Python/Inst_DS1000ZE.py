from InstDev import InstDev
import pyvisa as pv
import numpy as np

class Inst_DS1000ZE(InstDev):
    # Instrument Parameter Constants
    channelN = 2
    memDepth = (1,2,3)
    acquireDepthLevel = None
    maxBatch = None

    # Private Methods
    def getWfmParameter(self, chan):
        # Set source to channel N
        self.dev.write(':WAV:SOUR CHAN' + str(chan))

        # Read parameters of channel N, listed in a formatted string
        parstr = self.dev.query(':WAVeform:PREamble?')
        parcell = float(parstr.split(','))

        wfmpara = {'format':parcell(1),
                   'mode':parcell(2),
                   'points':parcell(3),
                   'averageCount':parcell(4),
                   'xIncrement':parcell(5),
                   'xOrigin':parcell(6),
                   'xRef':parcell(7),
                   'yIncrement':parcell(8),
                   'yOrigin':parcell(9),
                   'yRef':parcell(10),}
        wfmpara['yOffset'] = float(self.dev.query(':CHAN'+int(chan)+':OFFS?'))
        return wfmpara
    
    def setWaveformMode(self, mode):
        self.dev.write(':WAV:MODE' + mode)
        readback = self.dev.query(':WAV:MODE?')
        if (readback == mode):
            return True
        return False
    
    def getTrigger(self):
        mode = self.dev.query(':TRIG:SWE?')
        if (mode[0:4] == 'AUTO'):
            mode = 1
        elif (mode[0:4] == 'NORM'):
            mode = 2
        else:
            mode = 3

        edge = self.dev.query(':TRIG:EDG:SLOP?')
        if (edge[0:3] == 'POS'):
            edge = 1
        elif (edge[0:3] == 'NEG'):
            edge = 2
        else:
            edge = 3
        
        chan = self.dev.query(':TRIG:EDG:SOUR?')
        chan = int(chan[4])

        level = float(self.dev.query('TRIG:EDG:LEV?'))

        return {'mode':mode,'edge':edge,'chan':chan,'level':level}

    def getWfmMem(self, chan):
        par = self.getWfmParameter(chan)
        wfm = np.zeros(par.points)
        readCount = 0

        # Read wfm in several batches
        while (readCount < par.points):
            self.dev.write(':WAV:STAR' + str(readCount + 1))

            if (par.points - readCount <= 250000):
                self.dev.write(':WAV:STOP ' + str(par.points))
            else:
                self.dev.write(':WAV:STOP ' + str(readCount + 250000))

            rawData = self.dev.query(':WAV:DATA?')
            
            # Read the TMC header in each batch.
            headLen = 2 + int(rawData[1])
            dataLen = int(rawData[2:headLen])

            # Exclude the header by reading rawData from headLen+1
            wfm[readCount: readCount+dataLen] = float(rawData[headLen+1: len(rawData)])
            readCount += dataLen
        
        # Decode raw wfm with parameters
        wfm = (wfm - par.yRef) * par.yIncrement - par.yOffset
        wfm = wfm[0:len(wfm)-1] # Seems that the last point is much too low
        time = np.arange(par.points - 1) * par.xIncrement + par.xOrigin

        return wfm,time