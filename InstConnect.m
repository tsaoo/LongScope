function instdev = InstConnect()
    list = pyrunfile('VISAList.py','list');
    list = cell(list);

    if(isempty(list))
        error('No valid VISA device detected.');
    end
    
    disp('<strong>Available VISA devices:</strong>');
    for index = 1:length(list)
        disp(append(num2str(index), ') ', string(list(index))));
    end

    disp('<strong>Select desired RIGOL instrument from the list above:</strong>');
    select = input('->');
    
    instid = string(list(select));
    instdev = visadev(instid);
    %configureTerminator(instdev, 'CR/LF'); 

    try
        disp('<strong>Instrument identity:</strong>');
        disp(writeread(instdev,'*IDN?'));
    catch
        delete(instdev);
        error('The selected VISA device is not a valid RIGOL instrument.');
    end
end