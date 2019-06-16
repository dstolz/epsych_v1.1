classdef GUIHelper < handle
    
    properties
        TDTactiveX  % COM.RPco_X || COM.TDevAcc_X
    end
    
    properties (SetAccess = private)
        
    end
    
    methods
        % Constructor
        function obj = GUIHelper(TDTactiveX)
            if nargin < 1, TDTactiveX = []; end
            if ~isempty(TDTactiveX)
                obj.TDTactiveX = TDTactiveX;
            end
        end
        
        function set.TDTactiveX(obj,TDTactiveX)
                assert(epsych.GUIHelper.isRPcox(TDTactiveX) || epsych.GUIHelper.isOpenEx(TDTactiveX), ...
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
            v = epsych.GUIHelper.isRPcox(TDTactiveX) || epsych.GUIHelper.isOpenEx(TDTactiveX);
        end

        function v = getParamVals(TDTactiveX,params)
            assert(epsych.GUIHelper.TDTactiveXisvalid(TDTactiveX), ...
                'epsych.GUIHelper:getParamVals','Invalid TDT ActiveX control!');
            params = cellstr(params);
            N = numel(params);
            v = zeros(size(params),'single');
            for i = 1:N
                if epsych.GUIHelper.isOpenEx(TDTactiveX)
                    v(i) = single(TDTactiveX.GetTargetVal(params{i}));
                    
                elseif epsych.GUIHelper.isRPcox(TDTactiveX)
                    v(i) = single(TDTactiveX.GetTagVal(params{i}));
                end
            end
        end

        
        function update_highlight(tableH,row,highlightColor)
            if nargin < 3 || isempty(highlightColor), highlightColor = [0.2 0.6 1]; end
            n = size(tableH.Data,1);
            c = repmat([1 1 1; 0.9 0.9 0.9],ceil(n/2),1);
            c(n+1:end,:) = [];
            if ~isempty(row)
                c(row,:) = repmat(highlightColor,numel(row),1);
            end
            tableH.BackgroundColor = c;
        end    
    end
end
    
    