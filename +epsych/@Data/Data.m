classdef Data < dynamicprops

    properties
        UserNotes       (:,1) string

        BitmaskConfig   (1,1) % structure with fields loaded from a *.ebm file
    end

    properties (Dependent)
        FieldLabels
    end

    properties (SetAccess = protected)
        TrialID         (1,1) uint16 = 0;
        Bitmasks        (1,1) % epsych.BitmaskArray
        TrialTimestamp  (1,:) double
    end

    properties (SetAccess = immutable)
        EPsychInfo
    end

    methods 
        function obj = Data(bitmaskFile)
            I = epsych.Info;
            obj.EPsychInfo = I.meta;
            
            if nargin == 0 || isempty(bitmaskFile), return; end
            
            % initialize obj.Bitmasks with a prototype epsych.Bitmask obj
            obj.BitmaskConfig = load(bitmaskFile,'-mat');
            obj.Bitmasks = epsych.BitmaskArray(obj.BitmaskConfig.BitmaskData(1));
        end
        
        function add_trial(obj,Bitmask,d)
            % add_trial(obj,Bitmask,d);     % Mask is an integer
            % add_trial(obj,BitmaskObj,d);  % BitmaskObj is epsych.Bitmask
            %
            % d is a structure with custom fields representing a single
            % trial of data.
            
            obj.TrialID = obj.TrialID + 1;
            obj.TrialTimestamp(1,obj.TrialID) = now;

            obj.Bitmasks.add_trial(Bitmask);
            
            fn = fieldnames(d);
            lbl = obj.FieldLabels;
            for i = 1:length(fn)
                if ~any(strcmp(fn{i},lbl))
                    obj.addprop(fn{i});
                    % obj.(fn{i}) = nan(1,obj.TrialID); % in case field is added later
                end
                
                if isscalar(d.(fn{i}))
                    obj.(fn{i})(obj.TrialID) = d.(fn{i});
                else
                    obj.(fn{i})(obj.TrialID) = {d.(fn{i})};
                end
                    
            end
        end

        function lbl = get.FieldLabels(obj)
            p = properties(obj);
            m = metaclass(obj);
            lbl = setdiff(p,{m.PropertyList.Name});
        end

        function c = all(obj,varargin)
            c = obj.Bitmasks.all(varargin{:});
        end

        function c = any(obj,varargin)
            c = obj.Bitmasks.any(varargin{:});
        end
    end

end