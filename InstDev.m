classdef InstDev

    properties (GetAccess = public, SetAccess = protected)
        IDN
        isConnected = false
        acquireDepth
        mainTimeBase
        xIncrement
        xOrigin
        xRef
        yIncrement
        yOrigin
        yRef
        yOffset
        averageCount
    end

    properties (GetAccess = protected, SetAccess = protected)
        instDev
    end

    properties (GetAccess = public, SetAccess = immutable, Abstract)
        channelN
        channelRange
        acquireDepthLevel
        maxBatch
    end

    methods
        function obj = InstDev(id)
            try
                obj.instDev = visadev(id);
                obj.IDN = writeread(obj.instDev, '*IDN?');
                
                obj.yIncrement = zeros(1, obj.channelN);
                obj.yOrigin = zeros(1, obj.channelN);
                obj.yRef = zeros(1, obj.channelN);
                obj.yOffset = zeros(1, obj.channelN);
            catch
                error('Failed to connect VISA device.');
            end
        end

        function disconnect(obj)
            delete(obj.instDev);
        end
    end

    methods (Abstract)
        refresh(obj)
        setAcquireDepth(obj, depth)
        setMainTimebase(obj, scale)
        setChannelStatus(obj, chan, onoff)
        setChannelRange(obj, chan, range)
        getWfm(obj, chan)
        getWfmPreview(obj, chan)
    end

end