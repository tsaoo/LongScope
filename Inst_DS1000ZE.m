classdef Inst_DS1000ZE < InstDev
    properties (GetAccess = public, SetAccess = immutable)
        channelN = 2
        channelRange
        acquireDepthLevel
        maxBatch
    end

    methods (Access = public)

        function obj = Inst_DS1000ZE(id)
            obj = obj@InstDev(id);
        end

        function sucs = refresh(obj)
            obj.mainTimeBase = str2double(writeread(obj.instDev, ':TIM:MAIN:SCAL?'));

            par;
            for chan = [1 2]
                par = getWfmParameter(obj.instDev, chan);
                obj.yIncrement(chan) = par.yincrement;
                obj.yOrigin(chan) = par.yOrigin;
                obj.yRef(chan) = par.yRef;
                obj.yOffset(chan) = str2double(writeread(obj.instDev,...
                    append(':CHANnel',num2str(chan),':OFFSet?')));
            end
            obj.xIncrement = par.xIncrement;
            obj.xOrigin = par.xOrigin;
            obj.xRef = par.xRef;
            obj.averageCount = par.averageCount;
        end

        function [readback,sucs] = setAcquireDepth(obj, depth)
            disp('hi')
            cmd = append(':ACQ:MDEP ', num2str(depth));
            write(obj.instDev, cmd);

            readback = writeread(obj.instDev, ':ACQ:MDEP?');
            readback = str2double(readback);
            if (readback == depth)
                sucs = true;
            else
                sucs = false;
            end
        end

        %scale must be a number(scientific notation/irrational is availble) instead of string.
        function [readback,sucs] = setMainTimebase(obj, scale)
            write(obj.instDev, ':TIM:MODE MAIN');
            cmd = append(':TIM:MAIN:SCAL ', num2str(scale));
            write(obj.instDev, cmd);

            readback = writeread(obj.instDev, ':TIM:MAIN:SCAL?');
            readback = str2double(readback);
            if (readback == scale)
                sucs = true;
            else
                sucs = false;
            end
        end

        %TO BE CONFIRMED: It seems that waveform of a not-enabled channel could be
        %read through :WAV:DATA?
        function [readback,sucs] = setChannelStatus(obj, chan, onoff)
            cmd = append(':CHAN', num2str(chan), ':DISP ', num2str(double(onoff)));
            write(obj.instDev, cmd);

            readback = writeread(obj.instDev, append(':CHAN', num2str(chan), ':DISP?'));
            readback = str2double(readback);
            if (readback == double(onoff))
                sucs = true;
            else
                sucs = false;
            end
        end

        function [readback,sucs] = setChannelRange(obj, chan, range)
            if (setChannelStatus(obj.instDev, chan, 1) == false)
                error(append('Failed to enable channel', num2str(chan)));
                return;
            end
            cmd = append(':CHAN', num2str(chan), ':RANG ', num2str(range));
            write(obj.instDev, cmd);

            readback = writeread(obj.instDev, append(':CHAN', num2str(chan), ':RANG?'));
            readback = str2double(readback);
            if (readback == range)
                sucs = true;
            else
                sucs = false;
            end
        end

        function [wfm,t] = getWfm(obj, chan)
            par = getWfmParameter(obj.instdev, chan);
            wfm = zeros(1, par.points);
            readcount = 0;
    
            % Read wfm in several batches.
            while (readcount < par.points)
                write(obj.instdev, append(':WAV:STAR ', num2str(readcount + 1)));
    
                if (par.points - readcount <= 250000)       % The rest of the data can be read in one batch.
                    write(obj.instdev, append(':WAV:STOP ', num2str(par.points)));
                else                                        % The rest of the data is larger than a max batch.
                    write(obj.instdev, append(':WAV:STOP ', num2str(readcount + 250000)));
                end
    
                rawdata = writeread(obj.instdev, ':WAV:DATA?');
    
                % Read the TMC header in each batch.
                rawdata = str2mat(rawdata);
                headlen = 2 + str2double(rawdata(2));
                datalen = str2double(rawdata(3:headlen));
    
                % Exclude the header by reading rawdata from head length+1
                wfm(readcount+1: readcount+datalen) = double(rawdata(headlen+2: length(rawdata)));                
                readcount = readcount + datalen;
            end
            
            % Decode raw wfm with parameters.
            wfm = (wfm-par.yref)*par.yincrement;
            wfm = wfm(1:length(wfm-1));          % Seems that the last point is much to low
            t = 1:(par.points-1);
            t = t*par.xincrement + par.xorigin;
        end

        function [wfm,t] = getWfmPreview(obj, chan)
            setWaveformMode(obj, 'NORM');
            [wfm,t] = getWfm(obj, chan);
        end
        
    end

    methods (Access = private)

        function wfmpara = getWfmParameter(instdev, chan)
            % Set source to channel N.
            write(instdev, append(':WAV:SOUR CHAN', num2str(chan)));
    
            % Read parameter of channel N.
            parstr = writeread(instdev, ':WAVeform:PREamble?');
            parcell = strsplit(parstr, ',');
            parcell = str2double(parcell);

            wfmpara.format = parcell(1);
            wfmpara.mode = parcell(2);
            wfmpara.points = parcell(3);
            wfmpara.averageCount = parcell(4);
            wfmpara.xIncrement = parcell(5);
            wfmpara.xOrigin = parcell(6);
            wfmpara.xRef = parcell(7);
            wfmpara.yIncrement = parcell(8);
            wfmpara.yOrigin = parcell(9);
            wfmpara.yRef = parcell(10);
        end

        function [readback,sucs] = setWaveformMode(obj, mode)
            cmd = append(':WAV:MODE ', mode);
            write(obj.instDev, cmd);

            readback = writeread(obj.instDev, ':WAVeform:MODE?');
            if (strcmp(feedback, mode))             % Must use NORM instead of NORMal
                sucs = true;
            else
                sucs = false;
            end
        end

    end

end