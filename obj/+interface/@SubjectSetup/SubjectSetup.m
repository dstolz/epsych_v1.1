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
        
        function subject_table_edit(obj,varargin)
            
        end
        
        function subject_table_select(obj,varargin)
            
        end
        
        function add_subject(obj,varargin)
            
        end
        
        function remove_subject(obj,varargin)
            
        end
        
        function view_trials(obj,varargin)
            
        end
        
        function edit_protocol(obj,varargin)
        end
    end
end