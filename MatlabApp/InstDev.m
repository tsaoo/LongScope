% A value class constructor returns an object that is associated with the variable to which it is assigned. If you reassign this variable, MATLAB® creates an independent copy of the original object. If you pass this variable to a function to modify it, the function must return the modified object as an output argument. For information on value-class behavior, see Avoid Unnecessary Copies of Data.
% 
% A handle class constructor returns a handle object that is a reference to the object created. You can assign the handle object to multiple variables or pass it to functions without causing MATLAB to make a copy of the original object. A function that modifies a handle object passed as an input argument does not need to return the object.
% 
% All handle classes are derived from the abstract handle class.
%
% https://www.mathworks.com/help/matlab/matlab_oop/comparing-handle-and-value-classes.html
classdef InstDev < handle

    properties (GetAccess = public, SetAccess = protected)
        IDN
        isConnected = false
        acquireDepth
        mainTimebase
        focus
        xIncrement
        xOrigin
        xRef
        yRange
        yIncrement
        yOrigin
        yRef
        yOffset
        averageCount
        triggerMode
        triggerSource
        triggerLevel
        triggerEdge
        
    end

    properties (GetAccess = protected, SetAccess = protected)
        instDev
    end

    properties (GetAccess = public, SetAccess = immutable, Abstract)
        channelN
        memDepth
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
                obj.yRange = zeros(1, obj.channelN);
                obj.focus = zeros(1,obj.channelN);
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
        setRunStop(obj, runstop)        % 1=RUN/0=STOP

        % mode = 1=AUTO/2=NORM/3=SING, chan = 1/2/3..., edge = 1=POS/2=NEG/3=ANY
        setTrigger(obj, mode, chan, edge, level)

        getWfm(obj, chan)
        getWfmPreview(obj, chan)
    end

end