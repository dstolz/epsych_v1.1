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
            if isprop(obj.hControl,'Items')
                obj.hControl.Items = obj.Parameter.DataStr;
                obj.hControl.ItemsData = obj.Parameter.Data;
            elseif isprop(obj.hControl,'Limits')
                obj.hControl.Limits = obj.Parameter.Limits;
            end
            
            if ischar(obj.hControl.Value)
                v = obj.Parameter.ValueStr;
            else
                v = obj.Parameter.Value;
            end
            obj.hControl.Value = v;
            
            obj.hControl.ValueChangedFcn = @obj.value_changed;
        end
        
        function value_changed(obj,src,event)
            P = obj.Parameter;

            switch P.Select
                case {'value','userfcn'}
                    P.Data = src.Value;
                
                case 'discrete'
                    P.Index = find(ismember(P.Data,src.Value));
                    
                case 'randRange'
                    v = str2num(src.Value);
                    if length(v) == 1, v = [0 v]; end
                    v(3:end) = [];
                    v = sort(v);
                    P.Data = v;
                    src.Value = mat2str(v);
                    
            end
        end
    end
    
end