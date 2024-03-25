function recordCSV(path, dat, chan, chanRange, comment)
    if (~exist(path,'dir'))
        mkdir(path);
    end

    fileName = string(datetime(), 'HHmmss-SSSS');
    fileName = append(path, comment, '-', fileName);

    % Storage channel info into a string matrix
    chanInfo = ["Time", string(datetime(),"yyyy-MM-dd HH:mm:ss.SSSS");"Channel", "Channel Voltage Sensitivity (V/div)"];
    for i = 1:length(chan)
        chanInfo = [chanInfo; string(chan(i)), chanRange(i)/8];
    end

    % Write waveform points. Rotate row vector
    writematrix(dat', append(fileName,'.csv'));
    writematrix(chanInfo, append(fileName,'.info.csv'));
end