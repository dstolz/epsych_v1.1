classdef ParameterControl < handle & matlab.mixin.SetGet

    properties
        Value
        
        LabelString     (1,:) char
        LabelPosition   (1,:) {mustBeMember(LabelPosition,{'left','right','above','below'})} = 'left';
    end

    properties (SetAccess = private)
        hLabel
    end

    properties (SetAccess = immutable)
        Style (1,:) char {mustBeMember(Style,{'checkbox','edit','listbox','popupmenu','slider'})} = 'edit';
    end

    methods
        function obj = ParameterControl(Style)
            if nargin == 1
                obj.Style = Style;
            end
        end

        function create(obj)
            
        end




    end

end