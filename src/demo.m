load_parameters;

%for days=[22]
    
    %days = sprintf('%0.2d',days);
    %input_folder_ =                  ['/media/HDD_2TB/R-Clustering/Demo/Plot_Results/' num2str(days) '_Crop'];
    %input_folder_ =                  ['/media/HDD_2TB/mcarne/SR-Clustering/Demo/Plot_Results/MarcCarne_Crop'];
    %output_folder_ =                 ['/media/My_Book/Datos_Lifelogging/Narrative/Txell_MWC/result_keyframe/' num2str(days)];

    dir_list = dir(input_folder);
    dir_list = dir_list(arrayfun(@(x) x.name(1) ~= '.' && isdir([input_folder '/' x.name]), dir_list));
    number_segments = length(dir_list);


    % Precompute segments' lengths
    if(strcmp(pltp.selection_mode, 'absolute_set'))
        segm_lengths = zeros(1, number_segments);
        for seg=1:number_segments
            output_folder_=[output_folder '/Segment_' num2str(seg)];
            input_folder_=[input_folder '/Segment_' num2str(seg)];
            dbp.imgFolder =                 input_folder_;
            [fevent] = getEvent(dbp);
            segm_lengths(seg) = numel(fevent);
        end
        pltp.PercentageImagesShown = pltp.PercentageImagesShown/sum(segm_lengths)*100;
    end

    % Start summarization
    for seg=1:number_segments
        
        output_folder_=[output_folder '/Segment_' num2str(seg)];
        input_folder_=[input_folder '/Segment_' num2str(seg)];

        disp(['Processing Segment_' num2str(seg)]);
        
        %UPDATED PARAMETERS DUE TO 'FOR' STATEMENT
        dbp.imgFolder =                 input_folder_;
        pltp.resultsFolder =            [output_folder_ '/results/'];
        pfp.deepPath = 			[output_folder_ '/computed/informative'];
        dsp.FeatsPath =                 [output_folder_ '/computed/similarity']; 
        mthdp.saliency.deepPath = 	[output_folder_ '/computed/saliency'];
        mthdp.faces.loadSavePath =      [output_folder_ '/computed/faces'];
        mthdp.objectsLSDA.deepPath =    [output_folder_ '/computed/LDSA']; 

        %% INITIALIZATION

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
        if(strcmp(pltp.selection_mode, 'percentage') || strcmp(pltp.selection_mode, 'absolute_set'))
            Nimages = round(pltp.PercentageImagesShown * numel(fevent)/100);
        elseif(strcmp(pltp.selection_mode, 'absolute'))
            Nimages = min(numel(fevent), pltp.PercentageImagesShown);
        end

        % PREFILTERING
        pf.compute(fevent);
        [sevent, event] = pf.filter(fevent);

	disp([num2str(length(event)) ' images remaining after filtering.']);

        if ~isempty(event)
            
            plt.show(event); % write informative images
            
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
            disp('### There is nothing relevant in this segment ###');
        end
    end
    
%end

disp('Done')
%exit
