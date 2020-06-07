classdef Data < dynamicprops

    properties
        TrialTimestamp  (:,1) double

        UserNotes       (:,1) string
    end

    properties (Dependent)
        FieldLabels
    end

    properties (SetAccess = protected)
        TrialID         (1,1) uint16 = 0;
        ResponseCode    (1,1) epsych.BitmaskArray
    end

    properties (SetAccess = immutable)
        EPsychInfo
    end

    methods 
        function obj = Data
            I = epsych.Info;
            obj.EPsychInfo = I.meta;
        end
        
        function add_trial(obj,D)
            obj.TrialID = obj.TrialID + 1;
            obj.TrialTimestamp(obj.TrialID) = now;

            obj.ResponseCode.Bitmasks(obj.TrialID) = D.ResponseCode;

            fn = fieldnames(D);
            fn(strcmp({'ResponseCode'},fn)) = [];
            lbl = obj.FieldLabels;
            for i = 1:length(fn)
                if ~any(strcmp(fn{i},lbl))
                    obj.addprop(fn{i});
                end
                obj.(fn{i})(obj.TrialID) = D.(fn{i});
            end
        end

        function lbl = get.FieldLabels(obj)
            p = properties(obj);
            m = metaclass(obj);
            lbl = setdiff(p,{m.PropertyList.Name});
        end

        function c = all(obj,varargin)
            c = obj.ResponseCode.all(varargin{:});
        end

        function c = any(obj,varargin)
            c = obj.ResponseCode.any(varargin{:});
        end
    end

end