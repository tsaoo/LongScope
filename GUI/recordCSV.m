function recordCSV(path, dat, chan, chanRange)
    fileName = string(datetime(), 'LongScope-hhmmss-SSSS');
    fileName = append(path, fileName);

    % Storage channel info into a string matrix
    chanInfo = ['Channel' 'Channel Voltage Range (V)'];
    for i = length(chan)
        chanInfo = [chanInfo; string(chan(i)) chanRange(i)];
    end

    % Write waveform points. Rotate row vector
    writematrix(dat', append(fileName,'.csv'));
    writematrix(chanInfo, append(filename,'.info.csv'));
end