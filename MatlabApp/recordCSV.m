function recordCSV(path, dat, chan, chanRange)
    if (~exist(path,'dir'))
        mkdir(path);
    end

    fileName = string(datetime(), 'HHmmss-SSSS');
    fileName = append(path, 'LongScope-', fileName);

    % Storage channel info into a string matrix
    chanInfo = ["Time", string(datetime(),"yyyy-MM-dd HH:mm:ss.SSSS");"Channel", "Channel Voltage Range (V)"];
    for i = length(chan)
        chanInfo = [chanInfo; string(chan(i)), chanRange(i)];
    end

    % Write waveform points. Rotate row vector
    writematrix(dat', append(fileName,'.csv'));
    writematrix(chanInfo, append(fileName,'.info.csv'));
end