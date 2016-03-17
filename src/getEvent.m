function eventFrames = getEvent(dbp)

%List folder where images are located
d =  dir([dbp.imgFolder '/*.' dbp.imgFormat]);

for i  = 1 : numel(d)
    [~, nm, ~] = fileparts(d(i).name);
    eventFrames(i) = Frame(dbp.imgFolder, nm, dbp.imgFormat,0,i,dbp.resize);
    
%     eventFrames(i) = Frame(dbp.imgFolder, str2double(nm), dbp.imgFormat,0,i,dbp.resize);
end

end