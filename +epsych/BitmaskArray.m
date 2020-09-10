classdef BitmaskArray < dynamicprops

    properties
        Bitmasks    (1,:)   epsych.Bitmask
    end

    properties (Dependent)
        Labels
        Digits
        Masks
        Values
                
        NumTrials
    end
    
    properties (SetAccess = private)
        TrialID     (1,1) = 0;
    end

    methods
        
        function obj = BitmaskArray(Bitmask)
            assert(isa(Bitmask,'epsych.Bitmask'),'epsych.BitmaskArray:InvalidDatatype', ...
                'Input must be of type epsych.Bitmask')
                
            obj.Bitmasks = copy(Bitmask);
            
            lbl = Bitmask.Labels;
            for i = 1:length(lbl)
                obj.addprop(lbl{i});
            end
        end

        
        function add_trial(obj,Bitmask)
            % add_trial(obj,Mask);          % Mask is an integer
            % add_trial(obj,BitmaskObj);    % BitmaskObj is epsych.Bitmask
            
            obj.TrialID = obj.TrialID + 1;
            
            if isa(Bitmask,'epsych.Bitmask')
                obj.Bitmasks(obj.TrialID) = Bitmask;
            else
                if obj.TrialID > 1
                    obj.Bitmasks(obj.TrialID) = copy(obj.Bitmasks(obj.TrialID-1));
                end
                obj.Bitmasks(obj.TrialID).Mask = Bitmask;
            end
            
            lbl = obj.Bitmasks(obj.TrialID).Labels;
            bol = obj.Bitmasks(obj.TrialID).Boolean;
            for i = 1:length(lbl)
                obj.(lbl{i})(obj.TrialID) = bol(i);
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
    end % methods (Access = public)
    




end