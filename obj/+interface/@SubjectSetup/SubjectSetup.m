classdef SubjectSetup < handle

    properties
        SubjectObj 
    end

    % Properties that correspond to obj components
    properties (Access = protected)
        SubjectTable          matlab.ui.control.Table
        AddButton             matlab.ui.control.Button
        RemoveButton          matlab.ui.control.Button
        ViewTrialsButton      matlab.ui.control.Button
        EditProtocolButton    matlab.ui.control.Button
    end
    
    properties (SetAccess = immutable)
        parent
    end

    methods
        create(obj,parent);
        
        % Constructor
        function obj = SubjectSetup(parent)
            narginchk(0,1)
            
            create(obj,parent)
            
            obj.parent = parent;
            
            if nargout == 0, clear obj; end
        end

        function delete(obj)
            delete(obj.parent)
        end
        
    end
    
    methods (Access = protected)
        
        function subject_table_edit(obj,hObj,event)
            
        end
        
        function subject_table_select(obj,hObj,event)
            
        end
        
        function add_subject(obj,hObj,event)
            global RUNTIME

            RUNTIME.Log.write(log.Verbosity.Verbose,'Subject added');
        end
        
        function remove_subject(obj,hObj,event)
            
        end
        
        function view_trials(obj,hObj,event)
            
        end
        
        function edit_protocol(obj,hObj,event)
        end
    end
end