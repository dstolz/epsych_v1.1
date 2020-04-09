classdef SubjectSetup < handle

    properties
        Subject     (:,1) epsych.Subject
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
            narginchk(0,1)
            
            create(obj,parent);
            
            obj.parent = parent;
            
            if nargout == 0, clear obj; end
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
                RUNTIME.Log.write('Verbose','Updated Subjects Table');
                return
            end

            ac = {obj.Subject.Active};
            nm = {obj.Subject.Name};
            id = {obj.Subject.ID};
            fn = cellfun(@epsych.Tool.truncate_str,{obj.Subject.ProtocolFile},'uni',0);
            
            obj.SubjectTable.Data = [ac(:), nm(:), id(:), fn(:)];

            RUNTIME.Log.write('Verbose','Updated Subjects Table');
        end

        function modify_subject(obj,hObj,event)
            if isempty(obj.selIdx), return; end

            h = epsych.ui.SubjectDialog(obj.Subject(obj.selIdx(1)));
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
    
    methods (Access = protected)
        
    end % methods (Access = protected)

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

            h = epsych.ui.SubjectDialog;
            waitfor(h.parent);

            if isequal(h.UserResponse,'Cancel'), return; end

            % check subject is unique
            if ismember(h.Subject.Name,{obj.Subject.Name})
                uialert(ancestor(hObj,'figure'),'Subjects must be unique.','Add Subject','Icon','warning');
                return
            end

            RUNTIME.Log.write('Verbose','Adding subject %s "%s"',h.Subject.ID,h.Subject.Name);

            obj.Subject(end+1) = h.Subject;
            
            delete(h);
        end

        function remove_subject(obj,hObj,event)
            global RUNTIME

            if isempty(obj.selIdx), return; end

            RUNTIME.Log.write('Verbose','Removing subject %s "%s"', ...
                obj.Subject(obj.selIdx(1)).ID,obj.Subject(obj.selIdx(1)).Name);

            obj.SubjectTable.Data(obj.selIdx(1),:) = [];
            
            obj.Subject(obj.selIdx(1)) = [];

        end
    end

end