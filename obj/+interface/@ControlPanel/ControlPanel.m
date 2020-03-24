classdef ControlPanel < handle
    
    properties

    end
    
    properties (Access = protected)
        parent          matlab.ui.Figure
        RuntimePanel    matlab.ui.container.Panel
        SubjectPanel    matlab.ui.container.Panel
        
        RuntimeControlObj   % interface.RuntimeControl
        SubjectSetupObj     % interface.SubjectSetup
    end
    
    methods
        function obj = ControlPanel
            
            obj.create;
            
        end
    end
    
    methods (Access = private)
        create(obj);
    end
    
end