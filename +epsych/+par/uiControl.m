classdef uiControl < handle & matlab.mixin.SetGet
    
    
    properties (SetAccess = immutable)
        Parameter
        hControl
    end
    
    
    methods
        % Constructor
        function obj = uiControl(pObj,hObj)
            obj.Parameter = pObj;
            obj.hControl = hObj;
            
            addlistener(pObj,{'Index','Expression','Data'},'PostSet',@obj.update)
            
            
            obj.update(pObj,'init');
        end
        
        
    end
    
    methods (Access = private)
        function update(obj,src,event)
            obj.hControl.Value = obj.Parameter.ValueStr;
        end
    end
    
end