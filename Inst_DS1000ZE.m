classdef Inst_DS1000ZE < InstDev

    properties (GetAccess = public, SetAccess = immutable)
        channelN = 2
        memDepth = ["AUTO" 12000 120000 1200000 12000000 24000000;...
            "AUTO" 6000 60000 600000 6000000 12000000]
        acquireDepthLevel
        maxBatch
    end

    methods (Access = public)

        function obj = Inst_DS1000ZE(id)
            obj = obj@InstDev(id);
        end

        function sucs = refresh(obj)
            obj.mainTimebase = str2double(writeread(obj.instDev, ':TIM:MAIN:SCAL?'));

            par = [];
            for chan = [1 2]
                par = obj.getWfmParameter(chan);
                obj.yIncrement(chan) = par.yIncrement;
                obj.yOrigin(chan) = par.yOrigin;
                obj.yRef(chan) = par.yRef;
                obj.yOffset(chan) = str2double(writeread(obj.instDev,...
                    append(':CHAN',num2str(chan),':OFFS?')));
                obj.yRange(chan) = str2double(writeread(obj.instDev,...
                    append(':CHAN',num2str(chan),':RANG?')));
                obj.focus(chan) = str2double(writeread(obj.instDev,...
                    append(':CHAN',num2str(chan),':DISP?')));
            end
            obj.xIncrement = par.xIncrement;
            obj.xOrigin = par.xOrigin;
            obj.xRef = par.xRef;
            obj.averageCount = par.averageCount;
            
            trig = obj.getTrigger();
            obj.triggerEdge = trig.edge;
            obj.triggerLevel = trig.level;
            obj.triggerSource = trig.chan;
            obj.triggerMode = trig.mode;
        end

        function setRunStop(obj, runstop)
            if (runstop = 1)
                write(obj.instDev, ':RUN');
            else
                write(obj.instDev, ':STOP');
            end
        end

        function [readback,sucs] = setAcquireDepth(obj, depth)
            cmd = append(':ACQ:MDEP ', depth);
            write(obj.instDev, cmd);

            readback = writeread(obj.instDev, ':ACQ:MDEP?');
            readback = erase(readback, newline);
            if (strcmp(readback, depth))
                sucs = true;
            else
                sucs = false;
            end
            obj.acquireDepth = readback;
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
            obj.mainTimebase = readback;
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
            obj.focus(chan) = readback;
        end

        function [readback,sucs] = setChannelRange(obj, chan, range)
            if (obj.setChannelStatus(chan, 1) == false)
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
            obj.yRange(chan) = readback;
        end

        function [readback,sucs] = setTrigger(obj, mode, chan, edge, level)
            if (mode == 1)
                write(obj.instDev, ':TRIG:SWE AUTO');
            elseif (mode == 2)
                write(obj.instDev, ':TRIG:SWE NORM');
            else
                write(obj.instDev, ':TRIG:SWE SING');
            end
            
            write(obj.instDev, append(':TRIG:EDG:SOUR CHAN', num2str(chan)));

            write(obj.instDev, append(':TRIG:EDG:LEV ', num2str(level)));

            if (edge == 1)
                write(obj.instDev, ':TRIG:EDG:SLOP POS');
            elseif(edge == 2)
                write(obj.instDev, ':TRIG:EDG:SLOP NEG');
            else
                write(obj.instDev, ':TRIG:EDG:SLOP RFAL');
            end

            readback = obj.getTrigger();

            if (readback.mode == mode && readback.edge == edge &&...
                    readback.chan == chan && readback.level == level)
                sucs = true;
            else
                sucs = false;
            end

            obj.triggerEdge = readback.edge;
            obj.triggerLevel = readback.level;
            obj.triggerSource = readback.chan;
            obj.triggerMode = readback.mode;
            
        end

        function [wfm,t] = getWfm(obj, chan)
            obj.setWaveformMode('RAW');
            [wfm,t] = getWfmMem(obj, chan);
        end
       
        function [wfm,t] = getWfmPreview(obj, chan)
            obj.setWaveformMode('NORM');
            [wfm,t] = getWfmMem(obj, chan);
        end
        
    end

    methods (Access = private)

        function wfmpara = getWfmParameter(obj, chan)
            % Set source to channel N.
            write(obj.instDev, append(':WAV:SOUR CHAN', num2str(chan)));
    
            % Read parameter of channel N.
            parstr = writeread(obj.instDev, ':WAVeform:PREamble?');
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
            wfmpara.yOffset = str2double(writeread(obj.instDev,...
                    append(':CHAN',num2str(chan),':OFFS?')));
        end

        function [readback,sucs] = setWaveformMode(obj, mode)
            cmd = append(':WAV:MODE ', mode);
            write(obj.instDev, cmd);

            readback = writeread(obj.instDev, ':WAVeform:MODE?');
            if (strcmp(readback, mode))             % Must use NORM instead of NORMal
                sucs = true;
            else
                sucs = false;
            end
        end

        function readback = getTrigger(obj)
            mode = writeread(obj.instDev, ':TRIG:SWE?');
            if(strncmp(mode, 'AUTO', 4))
                readback.mode = 1;
            elseif(strncmp(mode, 'NORM', 4))
                readback.mode = 2;
            else
                readback.mode = 3;
            end
            
            readback.chan = writeread(obj.instDev, ':TRIG:EDG:SOUR?');
            readback.chan = str2mat(readback.chan);
            readback.chan = str2double(readback.chan(5));

            edge = writeread(obj.instDev, ':TRIG:EDG:SLOP?');
            if(strncmp(edge, 'POS', 3))
                readback.edge = 1;
            elseif(strncmp(edge, 'NEG', 3))
                readback.edge = 2;
            else
                readback.edge = 3;
            end

            readback.level = writeread(obj.instDev, 'TRIG:EDG:LEV?');
            readback.level = str2double(readback.level);
        end

        function [wfm,t] = getWfmMem(obj, chan)
            par = obj.getWfmParameter(chan);
            wfm = zeros(1, par.points);
            readcount = 0;
    
            % Read wfm in several batches.
            while (readcount < par.points)
                write(obj.instDev, append(':WAV:STAR ', num2str(readcount + 1)));
    
                if (par.points - readcount <= 250000)       % The rest of the data can be read in one batch.
                    write(obj.instDev, append(':WAV:STOP ', num2str(par.points)));
                else                                        % The rest of the data is larger than a max batch.
                    write(obj.instDev, append(':WAV:STOP ', num2str(readcount + 250000)));
                end
    
                rawdata = writeread(obj.instDev, ':WAV:DATA?');
    
                % Read the TMC header in each batch.
                rawdata = str2mat(rawdata);
                headlen = 2 + str2double(rawdata(2));
                datalen = str2double(rawdata(3:headlen));
    
                % Exclude the header by reading rawdata from head length+1
                wfm(readcount+1: readcount+datalen) = double(rawdata(headlen+2: length(rawdata)));                
                readcount = readcount + datalen;
            end
            
            % Decode raw wfm with parameters.
            wfm = (wfm-par.yRef)*par.yIncrement - par.yOffset;
            wfm = wfm(1:length(wfm)-1);          % Seems that the last point is much to low
            t = 1:(par.points-1);
            t = t*par.xIncrement + par.xOrigin;
        end

    end

end