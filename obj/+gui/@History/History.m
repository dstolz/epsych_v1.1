classdef History < gui.Helper

                % TODO: Make context menu for user customization
                % TODO: Colorize rows based on response
    properties
        physObj
        BoxID       (1,1)  uint8 {mustBeNonempty,mustBeNonNan} = 1;
        
        watchedParams
        
        ResultRowColor = struct('Hit',          [0.7 1.0 .95], ...
                                'Miss',         [1.0 .95 0.7], ...
                                'CorrectReject',[0.7 .95 1.0], ...
                                'FalseAlarm',   [1.0 0.7 0.7], ...
                                'Abort',        [0.7 0.7 0.7], ...
                                'NoResponse',   [0.8 0.8 0.8]);
    end

    properties (SetAccess = private)
        TableH
        ContainerH

        ColumnName
        Data
        Info
        
        el_NewPhysData
    end
    
    methods

        function obj = History(physObj,container,watchedParams)
            narginchk(1,4);
            
            obj.physObj = physObj;
            
            if nargin < 2 || isempty(container), container = figure;        end
            if nargin < 3 || isempty(watchedParams), watchedParams = []; end

            obj.ContainerH = container;
            obj.BoxID = physObj.BoxID;
            obj.watchedParams = watchedParams;

            obj.build;
        end

        function build(obj)
            obj.TableH = uitable(obj.ContainerH,'Unit','Normalized', ...
                'Position',[0 0 1 1],'RowStriping','off','FontSize',12);
        end
        
        
        function update(obj,src,event)
            
            % Call a function to rearrange DATA to make it easier to use (see below).
            obj.rearrange_data;

            if isempty(obj.Data), return ;end
            
            % Flip the DATA matrix so that the most recent trials are displayed at the
            % top of the table.
            obj.TableH.Data = flipud(obj.Data);

            % set the row names as the trial ids
            obj.TableH.RowName = flipud(obj.Info.TrialID);

            % set the column names
            obj.TableH.ColumnName = obj.ColumnName;
            
            obj.update_row_colors;
        end
        
        function set.physObj(obj,physObj)
%             assert(epsych.Helper.valid_psych_obj(physObj),'gui.History:set.physObj', ...
%                 'physObj must be from the toolbox "phys"');
            obj.physObj = physObj;
            obj.update;
        end

        
        function set.BoxID(obj,id)
            obj.BoxID = id;
            delete(obj.el_NewPhysData); % destroy old listener and create a new one for the new BoxID
            obj.el_NewPhysData = addlistener(obj.physObj,'NewPhysData',@obj.update);
        end
    end

    methods (Access = private)
        function update_row_colors(obj)
            C = ones(size(obj.Data,1),3);
            R = cellfun(@epsych.Bitmask,obj.Data(:,3));
            fn = fieldnames(obj.ResultRowColor);
            E = cellfun(@epsych.Bitmask,fn);
            for i = 1:length(E)
                ind = R == E(i);
                if ~any(ind), continue; end
                C(ind,:) = repmat(obj.ResultRowColor.(fn{i}),sum(ind),1);
            end
            obj.TableH.BackgroundColor = flipud(C);
            obj.TableH.RowStriping = 'on';
        end
        
        function rearrange_data(obj)           
            DataIn = obj.physObj.DATA;
            
            if isempty(DataIn) || isempty(DataIn(1).TrialID)
                obj.Data = [];
                return
            end
            
            % Trial numbers
            obj.Info.TrialID = [DataIn.TrialID]';
            
            % Crude timestamp of when the trial occured.  This is not indended for use
            % in data analysis.  For physiology analysis use timestamps generated by the TDT hardware
            % since it is much more accurate and precise.
            td = cellfun(@(a) etime(a,DataIn(1).ComputerTimestamp),{DataIn.ComputerTimestamp});            
            tdStr = cellfun(@(a,b) sprintf('%d:%02d',a,b),num2cell(floor(td/60)),num2cell(floor(mod(td,60))),'uni',0);
            obj.Info.RelativeTimestamp = tdStr(:);            
            

            Response = obj.physObj.ResponsesChar;
            
            
            % remove these fields
            DataIn = rmfield(DataIn,{'ResponseCode','TrialID','ComputerTimestamp'});

            if ~isempty(obj.watchedParams)
                fn = fieldnames(DataIn);
                ind = ~ismember(fn,obj.watchedParams);
                DataIn = rmfield(DataIn,fn(ind));
            end
            
            % The remaining fields of the DATA structure contain parameters for each
            % trial.
            dataFields = fieldnames(DataIn);
            for i = 1:length(dataFields)
                DataOut(:,i) = {DataIn.(dataFields{i})};
            end
            
            % prefix Timestamp, Response, and Result fields
            RC = obj.physObj.ResponseCode;
            bits = arrayfun(@(a) epsych.Bitmask(find(bitget(a,[3:7 16],'uint16'))+2),RC);
            Result = arrayfun(@char,bits,'uni',0)';
            DataOut = [Result DataOut];
            DataOut = [Response DataOut];
            DataOut = [obj.Info.RelativeTimestamp DataOut];
            
            obj.ColumnName = [{'Time'}; {'Response'}; {'Result'}; dataFields];
            
            obj.Data = DataOut;
            
        end
    end
end