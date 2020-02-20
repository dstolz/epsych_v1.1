classdef Triggers < gui.Helper

    properties
        BoxID   (1,1)   uint8 = 1;
    end

    properties (SetAccess = private)
        ContainerH
        TableH
    end

    methods
        % Constructor
        function obj = Triggers(container,BoxID)
            narginchk(1,3);

            global AX RUNTIME
            
            if nargin < 1 || isempty(container), container = figure; end
            if nargin < 2 || isempty(BoxID), BoxID = 1; end

            obj.BoxID = BoxID;
            obj.ContainerH = container;
            obj.TDTActiveX = AX;

            obj.build(RUNTIME);
        end

        function build(obj,RUNTIME)
            
            % RUNTIME.TRIALS.MODULES names the modules for updates without OpenEx
            midx  = struct2array(RUNTIME.TRIALS(obj.BoxID).MODULES);
            fn    = fieldnames(RUNTIME.TRIALS(obj.BoxID).MODULES);

            state = [];
            T = {};
            tmIdx = [];
            for i = 1:length(RUNTIME.TDT.triggers)
                for j = 1:length(RUNTIME.TDT.triggers{i})
                    tmIdx(end+1) = RUNTIME.TDT.trigmods(i);

                    if RUNTIME.UseOpenEx
                        mname = fn{tmIdx(end) == midx};
                        T{end+1} = [mname '.' RUNTIME.TDT.triggers{i}{j}];
                        state(end+1) = obj.TDTActiveX.GetTargetVal(T{end});
                    else
                        T{end+1} = RUNTIME.TDT.triggers{i}{j};
                        state(end+1) = obj.TDTActiveX(tmIdx(end)).GetTagVal(T{end});
                    end
                end
            end

            if isempty(T)
                set(obj.TableH, ...
                    'Data',{'N/A'}, ...
                    'Enable','off', ...
                    'UserData',[]);
                return
            end

            T = [T(:) num2cell(logical(state(:)))];
            
            ou = obj.ContainerH.Units;
            obj.ContainerH.Units = 'pixels';
            cpos = obj.ContainerH.Position;
            obj.ContainerH.Units = ou;
            
            obj.TableH = uitable(obj.ContainerH, ...
                'ColumnFormat',{'char','logical'}, ...
                'ColumnEditable',[false,true], ...
                'Units','normalized', ...
                'Position',[0 0 1 1], ...
                'ColumnName',{'Trigger','v'}, ...
                'RowName',[], ...
                'RowStriping','on', ...
                'ColumnWidth',{cpos(3)-30,20}, ...
                'CellEditCallback',@obj.triggered, ...
                'UserData',tmIdx, ...
                'Data',T, ...
                'Enable','on');
            
                
            obj.update_highlight(obj.TableH,find(state),[1 0.6 0.6]);
        end
    end

    methods (Access = private)
            
        function triggered(obj,hObj,event)
            if isempty(event.Indices), return; end
                
            row = event.Indices(1);
            triggerName = hObj.Data{row,1};
            state = single(event.EditData);
            
            % update trigger tag states
            tmIdx = hObj.UserData;
            
            if isa(obj.TDTActiveX,'COM.RPco_x')
                obj.TDTActiveX(tmIdx(row)).SetTagVal(triggerName,state);
            else
                obj.TDTActiveX.SetTargetVal(triggerName,state);
            end
            hObj.Data{row,2} = logical(state);
            
            obj.update_highlight(hObj,find([hObj.Data{:,2}]),[1 0.6 0.6]);
        end

        
    end    
end