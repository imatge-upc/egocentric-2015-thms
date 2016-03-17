function cellEvents = analizarCSV_narrative(csvfile)


if ismac
%Path per la funció xlwrite
 addpath('write_xls');
 
 javaaddpath('write_xls/jxl.jar');
 javaaddpath('write_xls/MXL.jar');

 import mymxl.*;
 import jxl.*;
end


    %Llegir el document .csv
    text = fileread(csvfile);
    %Extreure cada lÃ­nea del document, ja que sabem que acaba amb un salt
    %de lÃ­nea
    lines = regexp(text, '\n', 'split');
    %Assegurar-se que la Ãºltima lÃ­nea no estÃ  buida.
    if(isempty(lines{end}))
        lines = {lines{1:end-1}};
    end

    nLines = length(lines);
    cellEvents ={1, nLines};

    
    %Per cada lÃ­nea extraurem cadascun dels elements. Ens interessen el
    %primer nom d'imatge i l'Ãºltim.
    for l = 1:nLines
        elements = regexp(lines{l}, ',', 'split');
        elements=elements(2:end);
        names = zeros(1,numel(elements));
        for i = 1: numel(elements)
            [~, name, ~] = fileparts(elements{i});
            names(i) = str2double(name);
        end
        
        cellEvents{l} = names;
        
    end
    
end


