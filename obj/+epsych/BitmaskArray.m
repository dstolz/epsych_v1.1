classdef BitmaskArray < dynamicprops

    properties
        Bitmasks    (1,:)   epsych.Bitmask
    end

    properties (Dependent)
        Labels
        Digits
        Masks
        Values
        
        TrialIdx
        
        NumTrials
    end

    methods
        
        function obj = BitmaskArray(bm)
            if nargin == 0, return; end
            obj.Bitmasks = bm;
        end

        
        function set.Bitmasks(obj,bm)            
            assert(isa(bm,'epsych.Bitmask'),'epsych.BitmaskArray:InvalidData', ...
                'Bitmasks must be of class epsych.Bitmask');
            
            lbl = bm(1).Labels;
            m = [bm.Mask];
            for i = 1:length(lbl)
                obj.addprop(lbl{i});
                obj.(lbl{i}) = logical(bitget(m,bm(1).Digits(i)+1));
            end
            obj.Bitmasks = bm(:)';
        end
        
        function idx = get.TrialIdx(obj)
            lbl = obj.Labels;
            for i = 1:numel(lbl)
                idx.(lbl{i}) = find(obj.(lbl{i}));
            end
        end
        
        
        function lbl = get.Labels(obj)
            p = properties(obj);
            m = metaclass(obj);
            lbl = setdiff(p,{m.PropertyList.Name});
        end
        
        function n = get.NumTrials(obj)
            n = numel(obj.Bitmasks);
        end
        
        function c = any(obj,varargin)
            % obj.any('Hit','StimulusTrial')
            
            assert(all(ismember(varargin,obj.Labels)), ...
                'epsych.BitmaskArray:UnknownLabel', ...
                'One or more labels do not exist');
            
            c = false(1,obj.NumTrials);
            for i = 1:numel(varargin)
                c = c | obj.(varargin{i});
            end
        end
        
        
        function c = all(obj,varargin)
            % obj.all('Hit','StimulusTrial')
            
            assert(all(ismember(varargin,obj.Labels)), ...
                'epsych.BitmaskArray:UnknownLabel', ...
                'One or more labels do not exist');
            
            c = true(1,obj.NumTrials);
            for i = 1:numel(varargin)
                c = c & obj.(varargin{i});
                if ~any(c), break; end
            end
        end
    end



end