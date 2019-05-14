classdef ep_GenericGUIHelper < handle
    
    properties
        TDTactiveX  % COM.RPco_X || COM.TDevAcc_X
    end
    
    properties (SetAccess = private)
        
    end
    
    methods
        % Constructor
        function obj = ep_GenericGUIHelper(TDTactiveX)
            if nargin < 1, TDTactiveX = []; end
            if ~isempty(TDTactiveX)
                obj.TDTactiveX = TDTactiveX;
            end
        end
        
        function set.TDTactiveX(obj,TDTactiveX)
                assert(ep_GenericGUIHelper.isRPcox(TDTactiveX) || ep_GenericGUIHelper.isOpenEx(TDTactiveX), ...
                    'epsych:epGenericGUIHelper:set.TDTactiveX','TDTactiveX must be COM.RPco_X or COM.TDevAcc_X')
                obj.TDTactiveX = TDTactiveX;
        end
        
        function v = readparamTags(obj,paramTags)

        end
    end

    
    methods (Static)
        function r = isRPcox(TDTactiveX)
            r = isa(TDTactiveX,'COM.RPco_x');
        end
        function x = isOpenEx(TDTactiveX)
            x = isa(TDTactiveX,'COM.TDevAcc_X');
        end
        function v = TDTactiveXisvalid(TDTactiveX)
            v = ep_GenericGUIHelper.isRPcox(TDTactiveX) || ep_GenericGUIHelper.isOpenEx(TDTactiveX);
        end

        function v = getParamVals(TDTactiveX,params)
            assert(ep_GenericGUIHelper.TDTactiveXisvalid(TDTactiveX), ...
                'ep_GenericGUIHelper:getParamVals','Invalid TDT ActiveX control!');
            params = cellstr(params);
            N = numel(params);
            v = zeros(size(params),'single');
            for i = 1:N
                if ep_GenericGUIHelper.isOpenEx(TDTactiveX)
                    v(i) = single(TDTactiveX.GetTargetVal(params{i}));
                    
                elseif ep_GenericGUIHelper.isRPcox(TDTactiveX)
                    v(i) = single(TDTactiveX.GetTagVal(params{i}));
                end
            end
        end
    end
end
    
    