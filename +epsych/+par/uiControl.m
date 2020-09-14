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
            
            addlistener(pObj,{'Index','Expression','Data'},'PostSet',@obj.update);
            
            obj.update(pObj,'init');
        end
        
        
    end
    
    methods (Access = private)
        function update(obj,src,event)
            obj.hControl.Items = obj.Parameter.DataStr;
            obj.hControl.ItemsData = obj.Parameter.Data;
            obj.hControl.Value = obj.Parameter.Value;
            
            obj.hControl.ValueChangedFcn = @obj.value_changed;
        end
        
        function value_changed(obj,src,event)
            P = obj.Parameter;
            if P.isRange
                P.Value = src.Value;
            else
                P.Index = find(ismember(P.Data,src.Value));
            end
        end
    end
    
end