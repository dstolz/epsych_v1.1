classdef ParameterTable < handle
    
    properties
        table        
    end
    
    properties (Access = protected)
        parent
    end
    
    properties (Access = private)
        hl_NewTrial
        originalData
        recentData
        
        origColors
    end
    
    properties (Dependent)
        Data
    end
    
    events
        ParametersModified
    end
    
    methods
        
        function obj = ParameterTable(parent)
            global RUNTIME
            
            obj.parent = parent;
            
            obj.create(RUNTIME)
            
            obj.hl_NewTrial = addlistener(RUNTIME.HELPER,'NewTrial',@obj.update);
        end
        
        function delete(obj)
            delete(obj.hl_NewTrial);
        end
        
        
        function d = get.Data(obj)
            d = obj.table.Data;
        end
        
        function set.parent(obj,parent)
            obj.parent = parent;
        end
        
        function create(obj,RUNTIME)
            ou = get(obj.parent,'Units');
            
            set(obj.parent,'Units','Normalized');
            
            
            % TRIALS matrix
            T = RUNTIME.TRIALS.trials;
            
            % find indices that contain a structure which defines a buffer (usualy wav file)
            ind = cellfun(@isstruct,T);
            
            % update values for buffers
            T(ind) = cellfun(@(a) a.file,T(ind),'uni',0);
            
            % rotate values so that rows represent parameters
            T = T';
            
            % use field names from DATA strcuture for the table column names
            fn = RUNTIME.TRIALS.writeparams;
            
            
            % restrict access to parameters with these prefixes
            ind = cellfun(@(a) ismember(a(1),{'~','*','!'}),fn);
            T(ind,:) = [];
            fn(ind) = [];
            
            % find parameters that have multiple values
            for i = 2:size(T,1)
                if ischar(T{i,1})
                    nu(i) = numel(unique(T(i,:)));
                else
                    nu(i) = numel(unique([T{i,:}]));
                end
            end
            [nu,idx] = sort(nu,'descend');
            uind = nu > 1;
            fn = fn(idx);
            T  = T(idx,:);
            
            % put the important stuff up top
            ttind = ismember(fn,'TrialType');
            ridx = [find(ttind) find(~ttind)];
            fn = fn(ridx);
            T  = T(ridx,:);
            
            % Add a row of checkboxes to allow the user to include/exclude trials
            T = [num2cell(true(1,size(T,2))); T];
            
            % add name for first column which controls which trials are active
            fn = [{'ACTIVE'} fn];
            
            % add some color
            c = repmat([1 1 1; .95 .95 .95],length(fn),1);
            c(logical([0 uind]),:) = repmat([1 .95 .7],sum(uind),1);
            c = [.3 .8 1; c(2:length(fn),:)];
            c(ttind,:) = [.5 .94 .65];
            
            % update table data and info, including original parameters in case user
            % wants to reset the table
            
            obj.table = uitable(obj.parent, ...
                'Units','normalized', ...
                'Position',[0 0 1 1], ...
                'Data',T, ...
                'FontSize',12, ...
                'ColumnEditable',true, ...
                'RowName',fn, ...
                'BackgroundColor',c, ...
                'CellEditCallback',@obj.tbl_TrialParameters_CellEdit);
                        
            obj.origColors = c;
            
            obj.highlight_trial_column;
            
            set(obj.parent,'Units',ou);
            
            obj.originalData = obj.table.Data;
            obj.recentData   = obj.table.Data;
            
        end
        
        function highlight_trial_column(obj)
            global RUNTIME
            tid = RUNTIME.TRIALS.NextTrialID;

            n = arrayfun(@num2str,1:size(obj.Data,2),'uni',0);
            n{tid} = sprintf('< %d >',tid);
            obj.table.ColumnName = n;
        end
        
        
        function update(obj,source,event)
            
            rn = obj.table.RowName;
            rn(ismember(rn,'ACTIVE')) = [];
            wp = event.Data.writeparams;
            for i = 1:length(wp)
                ind = ismember(rn,wp{i});
                if ~any(ind), continue; end
                tpData(ind,:) = event.Data.trials(:,i)'; %#ok<AGROW>
            end
            
            
            % update the table with any changes made by the trial function or something
            % else
            at = num2cell(event.Data.activeTrials);
            tpData = [at(:)'; tpData];
            
            % find indices that contain a structure which defines a buffer (usualy wav file)
            ind = cellfun(@isstruct,tpData);
            
            % update values for buffers
            tpData(ind) = cellfun(@(a) a.file,tpData(ind),'uni',0);
            
            obj.table.Data = tpData;
            
            obj.highlight_trial_column;
        end
        
        
        function tbl_TrialParameters_CellEdit(obj,hObj,event)
            % Respond to updated parameter
            if isempty(event.Indices), return; end
            
            row = event.Indices(1);
            col = event.Indices(2);
            
            % make certain the new data is valid
            if isnumeric(event.NewData)
                NewData = event.NewData;
            else
                NewData = str2double(event.NewData);
            end
            if row > 1 && isnan(NewData)
                hObj.Data{row,col} = event.PreviousData;
                errordlg('Invalid input.  Values must be numeric, finite, real, and scalar','ep_GenericGui','modal');
                return
            end
            
            notify(obj,'ParametersModified');
            
        end
        
        function commit_parameters(obj)
            global RUNTIME
            
            % Update the TRIALS structure with the active trials used by the trial
            % selection function
            RUNTIME.TRIALS.activeTrials = [obj.table.Data{1,:}]';
            
            obj.recentData = obj.Data;
            
            data = obj.Data(2:end,:)';
            
            wp = RUNTIME.TRIALS.writeparams;
            
            rn = obj.table.RowName; % table rows may be in a different order than the TRIALS tructure
            
            
            rn(ismember(rn,'ACTIVE')) = [];
            for i = 1:length(wp)
                ind = ismember(rn,wp{i});
                if ~any(ind), continue; end
                RUNTIME.TRIALS.trials(:,i) = data(:,ind);
            end
        end
        
        function reset_parameters(obj,howFar)
            if nargin < 2 || isempty(howFar), howFar = 'original'; end
            
            howFar = lower(howFar);
            
            mustBeMember(howFar,{'original','recent'});
            
            obj.table.Data = obj.(sprintf('%sData',howFar));
        end
        
    end
end