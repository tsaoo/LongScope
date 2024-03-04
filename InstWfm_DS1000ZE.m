% This file contains functions fo get waveform from internal memory of
% DS1000ZE

function instwfm = InstWfm_DS1000ZE()
    instwfm.GetWfmParameter = @getWfmParameter;
    instwfm.GetWfm = @getWfm;
end

function wfmpara = getWfmParameter(instdev, channels)
    wfmpara = [];
    for chan = channels

        % Set source to channel N.
        write(instdev, append(':WAV:SOUR CHAN', str2number(chan)));
        feedback = writeread(instdev, ':WAV:SOUR?');
        if (~strcmp(feedback, append('CHAN',num2str(chan))))
            error(append('Failed to read CHAN', num2str(chan)));
            return;
        end

        % Read parameter of channel N.
        parstr = writeread(instdev, ':WAVeform:PREamble?');
        parcell = strsplit(parstr, ',');
        par.format = parcell(1);
        par.type = parcell(2);
        par.points = parcell(3);
        par.averagecount = parcell(4);
        par.xincrement = parcell(5);
        par.xorigin = parcell(6);
        par.xref = parcell(7);
        par.yincrement = parcell(8);
        par.yorigin = parcell(9);
        par.yref = parcell(10);
        wfmpara = [result par];
    end
end

function wfm = getWfm(instdev, channels)
    wfm = [];       % If more than one channel is queried, the wfm of them is storged in different row.
    for chan = channels
        par = getWfmParameter(instdev, chan);
        wfmchan = zeros(1, par.points);
        readcount = 0;

        % Read wfm in several batches.
        while (readcount < par.points)
            write(instdev, append(':WAV:STAR', num2str(readcount + 1)));

            if (par.points - readcount <= 250000)       % The rest of the data can be read in one batch.
                rawdata = writeread(instdev, append(':WAV:STOP', num2str(par.points)));
            else                                        % The rest of the data is larger than a max batch.
                rawdata = writeread(instdev, append(':WAV:STOP', num2str(readcount + 250000)));
            end

            % Read the TMC header in each batch.
            rawdata = str2mat(rawdata);
            headlen = 2 + str2double(rawdata(2));
            datalen = str2double(rawdata(2:headlen));

            % Exclude the header by reading rawdata from head length+1
            wfmchan(readcount+1: readcount+datalen) = double(rawdata(headlen+1, length(rawdata)));                
            readcount = readcount + datalen;
        end

        wfm = [wfm; wfmchan];
    end
end