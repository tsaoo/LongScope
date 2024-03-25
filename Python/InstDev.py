from abc import ABCMeta, abstractmethod
import numpy as np

class InstDev(metaclass=ABCMeta):
    
    # PyVISA handle
    dev = None

    # Status Variables
    IDN = None
    isConnected = None
    acquireDepth = None
    mainTimebase = None
    focus = None
    xIncrement = None
    xOrigin = None
    xRef = None
    yRange = None
    yIncrement = None
    yOrigin = None
    yRef = None
    yOffset = None
    averageCount = None
    triggerMode = None
    triggerSource = None
    triggerLevel = None
    triggerEdge = None

    # Instrument Parameter Constants
    channelN = None
    memDepth = None
    acquireDepthLevel = None
    maxBatch = None

    def __init__(self, dev) -> None:
        self.dev = dev
        #self.IDN = self.instDev.query('*IDN?')

        self.yIncrement = np.zeros(self.channelN)
        self.yOrigin = np.zeros(self.channelN)
        self.yRef = np.zeros(self.channelN)
        self.yOffset = np.zeros(self.channelN)
        self.yRange = np.zeros(self.channelN)
        self.focus = np.zeros(self.channelN)

    #@abstractmethod
    #def refresh(self): pass

    #@abstractmethod
    #def setAcquireDepth(self, depth): pass

    #@abstractmethod
    #def setMainTimebase(self, scale): pass

    #@abstractmethod
    #def setChannelStatus(self, chan, onoff): pass

    #@abstractmethod
    #def setChannelRange(self, chan, range): pass

    #@abstractmethod
    #def setRunStop(self, runstop): pass

    #@abstractmethod
    #def setTrigger(self, mode, chan, edge, level): pass

    #@abstractmethod
    #def getWfm(self, chan): pass

    #@abstractmethod
    #def getWfmPreview(self, chan): pass