load_parameters;

for days=[24]
    
    %days = sprintf('%0.2d',days);
    input_folder_ =                  ['/media/HDD_2TB/R-Clustering/Demo/Plot_Results/' num2str(days) '_Crop'];
    %input_folder_ =                  ['/media/My_Book/Datos_Lifelogging/Narrative/Pacientes/Paciente2/Life-logging/segmentation/' num2str(days) '_Crop'];
    %input_folder_ =                  ['/media/HDD_2TB/mcarne/SR-Clustering/Demo/Plot_Results/MarcCarne_Crop'];
    output_folder_ =                 ['/media/My_Book/Datos_Lifelogging/Narrative/Txell_MWC/result_keyframe/' num2str(days)];
    
    dir_list =            dir(input_folder_);
    dir_list = dir_list(arrayfun(@(x) x.name(1) ~= '.' && isdir([input_folder_ '/' x.name]), dir_list));
    number_segments = length(dir_list);


%number_segments = 1;


    for seg=1:number_segments

            output_folder=[output_folder_ '/Segment_' num2str(seg)]
            input_folder=[input_folder_ '/Segment_' num2str(seg)]
%	    input_folder = '/media/My_Book/Datos_Lifelogging/Narrative/Txell_MWC/24_Crop'


        %UPDATED PARAMETERS DUE TO 'FOR' STATEMENT
        dbp.imgFolder =                 input_folder;
        pltp.resultsFolder =            [output_folder '/results/'];
        pfp.deepPath = 					[output_folder '/computed/informative'];
        dsp.FeatsPath =                 [output_folder '/computed/similarity']; 
        mthdp.saliency.deepPath = 		[output_folder '/computed/saliency'];
        mthdp.faces.loadSavePath =      [output_folder '/computed/faces'];
        mthdp.objectsLSDA.deepPath =     [output_folder '/computed/LDSA']; 

        %% INITIALITZATION

        % INITIALIZE METHODS AND DISTANCES 

        pf = PrefilteringController(pfp);
        ds = Distance('ImageNet', dsp);
        fs = FusionController(fsp,methods);
        dv = DiversityController(dvp, {'ImageNet'});
        plt = PlotController(pltp, methods);

        mthd = cell(numel(methods), 1);

        % METHODS
        for m = 1: numel(methods)

            switch methods{m}
                case 'saliency'
                    mthd{m} = SaliencySorter(mthdp.saliency);
                case 'faces'
                    mthd{m} = FacesSorter(mthdp.faces, plt);
                case 'objectsLSDA'
                    mthd{m} = ObjectCandidatesSorterLSDA(mthdp.objectsLSDA);
                otherwise
                    error('Method incorrect');
            end;

        end

        % GET FRAMES
        [fevent] = getEvent(dbp);
        Nimages = round(pltp.PercentageImagesShown * numel(fevent)/100);

        % PREFILTERING
        pf.compute(fevent);
        [sevent, event] = pf.filter(fevent);

	disp([num2str(length(event)) ' images remaining after filtering.']);

	plt.show(event); % write informative images

        if ~isempty(event)
            % LOOP METHODS
            for m = 1: numel(methods)

                % COMPUTE FEATURES
                mthd{m}.compute(event);

                % COMPUTE SORTED LIST
                sortedList = mthd{m}.sort(event);

                % ADD EVENT TO FUSION
                fs.add(sortedList);

            end;

            % FUSION METHODS
            sortedList = fs.fusion();

            % ADD DIVERSITY
            ds.compute(event);
            sortedList = dv.diverse(sortedList);
            
	    % MERGE
            fullSortedList = [sortedList, sevent];

            % FULL DAY


        %Aqui anava el else

        % PLOT EVENT


        plt.show(sortedList);
        plt.show_full(fullSortedList);
        %plt.write(fullSortedList, 0, 'fusion', Nimages);
        if numel(sortedList)>=5
            if Nimages<numel(sortedList)
                plt.write(sortedList, 0, 'fusion', Nimages);
            else 
                plt.write(sortedList, 0, 'fusion', numel(sortedList));
            end
        else
            plt.write(sortedList, 0, 'fusion', numel(sortedList));
        end

        plt.close();

        else
            %fullSortedList = sevent;
            disp('### No hi ha res rellevant en aquest segment ###');
        end
    end
    
end

disp('Done')
%exit
