classdef SubjectSetup < handle

    properties
        Subject     (:,1) epsych.expt.Subject
    end

    % Properties that correspond to obj components
    properties (Access = protected)
        SubjectTable          matlab.ui.control.Table
        AddButton             matlab.ui.control.Button
        ModifyButton          matlab.ui.control.Button
        RemoveButton          matlab.ui.control.Button
        ViewTrialsButton      matlab.ui.control.Button
        EditProtocolButton    matlab.ui.control.Button
    end
    
    properties (Access = private)
        selIdx  (1,2)
    end

    properties (SetAccess = immutable)
        parent
    end

    methods
        create(obj,parent);
        
        % Constructor
        function obj = SubjectSetup(parent)
            global RUNTIME
            
            narginchk(0,1)

            if nargin == 0, parent = []; end
            
            create(obj,parent);
            
            obj.parent = parent;
            
            if nargout == 0, clear obj; end

            addlistener(RUNTIME,'PreStateChange',@obj.listener_PreStateChange);
            addlistener(RUNTIME,'PostStateChange',@obj.listener_PostStateChange);
        end

        function delete(obj)
            delete(obj.parent)
        end


        function set.Subject(obj,S)
            % update table
            global RUNTIME

            obj.Subject = S;
            
            if isempty(obj.Subject)
                obj.SubjectTable.Data = [];
                log_write('Verbose','Updated Subjects Table');
                return
            end

            ac = {obj.Subject.Active};
            nm = {obj.Subject.Name};
            id = {obj.Subject.ID};
            %fn = cellfun(@epsych.Tool.truncate_str,{obj.Subject.ProtocolFile},'uni',0);
            %bm = cellfun(@epsych.Tool.truncate_str,{obj.Subject.BitmaskFile},'uni',0);
            [~,fn] = cellfun(@fileparts,{obj.Subject.ProtocolFile},'uni',0);
            [~,bm] = cellfun(@fileparts,{obj.Subject.BitmaskFile},'uni',0);
            
            obj.SubjectTable.Data = [ac(:), nm(:), id(:), fn(:), bm(:)];

            RUNTIME.Subject = copy(obj.Subject);

            log_write('Verbose','Updated Subjects Table');

        end

        function modify_subject(obj,hObj,event)
            if isempty(obj.Subject), return; end
            
            if size(obj.SubjectTable.Data,1) == 1
                obj.selIdx = [1 1];
            end

            if isempty(obj.selIdx) || obj.selIdx(1) == 0
                uialert(obj.parent,'Please first select a subject to modify','Subject Setup','Icon','info');
                return
            end

            h = epsych.ui.Subject(obj.Subject(obj.selIdx(1)));
            waitfor(h.parent);

            if isequal(h.UserResponse,'Cancel'), return; end

            obj.Subject(obj.selIdx(1)) = h.Subject;
        end
        
        function view_trials(obj,hObj,event)
            
        end

        function edit_protocol(obj,hObj,event)
            % launches edit protocol utility with current selection
        end
        
    end % methods (Access = public)
    

    methods (Access = private)

        function subject_table_edit(obj,hObj,event)
            % currently, only the 'In Use' column is editable from within the table
            obj.Subject(event.Indices(end,1)).Active = event.NewData;
        end
        
        function subject_table_select(obj,hObj,event)
            if isempty(event.Indices), obj.selIdx = []; return; end
            obj.selIdx = event.Indices(end,:);
        end
        
        function add_subject(obj,hObj,event)
            global RUNTIME

            h = epsych.ui.Subject;
            waitfor(h.parent);

            if isequal(h.UserResponse,'Cancel'), return; end

            % check subject is unique
            if ismember(h.Subject.Name,{obj.Subject.Name})
                uialert(ancestor(hObj,'figure'),'Subjects must be unique.','Add Subject','Icon','warning');
                return
            end

            log_write('Verbose','Adding subject %s "%s"',h.Subject.ID,h.Subject.Name);

            obj.Subject(end+1) = h.Subject;
            
            RUNTIME.Subject = obj.Subject;
            
            delete(h);
        end

        function remove_subject(obj,hObj,event)
            global RUNTIME

            if isempty(obj.Subject) || isempty(obj.selIdx), return; end
                        
            if obj.selIdx(1) == 0, obj.selIdx = 1; end

            log_write('Verbose','Removing subject %s "%s"', ...
                obj.Subject(obj.selIdx(1)).ID,obj.Subject(obj.selIdx(1)).Name);

            obj.SubjectTable.Data(obj.selIdx(1),:) = [];
            
            obj.Subject(obj.selIdx(1)) = [];

            RUNTIME.Subject = obj.Subject;
        end
        
        function listener_PreStateChange(obj,hObj,event)
            global RUNTIME
            
            % update GUI component availability
            if event.State == epsych.enState.Run
                log_write('Debug','Disabling Subject Setup interface');
                
                obj.AddButton.Enable = 'off';
                obj.ModifyButton.Enable = 'off';
                obj.RemoveButton.Enable = 'off';
            end
        end

        
        function listener_PostStateChange(obj,hObj,event)
            global RUNTIME
            
            % update GUI component availability
            if any(event.State == [epsych.enState.Prep epsych.enState.Halt epsych.enState.Error])
                log_write('Debug','Enabling Subject Setup interface');

                obj.AddButton.Enable = 'on';
                obj.ModifyButton.Enable = 'on';
                obj.RemoveButton.Enable = 'on';
            end
        end
    end % methods (Access = private)
end