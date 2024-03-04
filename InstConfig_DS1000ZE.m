% This file contains functions to configure DS1000ZE parameters.

function instconfig = InstConfig_DS1000ZE()
    instconfig.SetAquireDepth = @setAquireDepth;
    instconfig.SetMainTimebase = @setMainTimebase;
    instconfig.SetChannelStatus = @setChannelStatus;
    instconfig.SetChennelRange = @setChannelRange;
    instconfig.SetWaveformMode = @setWaveformMode;
end

function result = setAquireDepth(instdev, depth)
    cmd = append(':ACQ:MDEP ', num2str(depth));
    write(instdev, cmd);
    feedback = writeread(instdev, ':ACQ:MDEP?');
    if (strcmp(num2str(depth), feedback))
        result = true;
    else
        result = false;
    end
end

%scale must be a number(scientific notation/irrational is availble) instead of string.
function result = setMainTimebase(instdev, scale)
    write(instdev, ':TIM:MODE MAIN');
    cmd = append(':TIM:MAIN:SCAL ', num2str(scale));
    write(instdev, cmd);
    feedback = writeread(instdev, ':TIM:MAIN:SCAL?');
    if (str2double(feedback) == scale)
        result = true;
    else
        result = false;
    end
end

%TO BE CONFIRMED: It seems that waveform of a not-enabled channel could be
%read through :WAV:DATA?
function result = setChannelStatus(instdev, chan, onoff)
    cmd = append(':CHAN', num2str(chan), ':DISP ', num2str(double(onoff)));
    write(instdev, cmd);
    feedback = writeread(instdev, append(':CHAN', num2str(chan), ':DISP?'));
    if (str2double(feedback) == double(onoff))
        result = true;
    else
        result = false;
    end
end

function result = setChannelRange(instdev, chan, range)
    if (setChannelStatus(instdev, chan, 1) == false)
        error(append('Failed to enable channel', num2str(chan)));
        return;
    end

    cmd = append(':CHAN', num2str(chan), ':RANG ', num2str(range));
    write(instdev, cmd);
    feedback = writeread(instdev, append(':CHAN', num2str(chan), ':RANG?'));
    if (str2double(feedback) == range)
        result = true;
    else
        result = false;
    end
end

function result = setWaveformMode(instdev, mode)
    cmd = append(':WAV:MODE ', mode);
    write(instdev, cmd);
    feedback = writeread(instdev, ':WAVeform:MODE?');
    if (strcmp(feedback, mode))             % Must use NORM instead of NORMal
        result = true;
    else
        result = false;
    end
end
