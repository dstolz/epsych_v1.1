classdef ParameterControl < handle & matlab.mixin.SetGet

    properties
        Value
        
        LabelString     (1,:) char
        LabelPosition   (1,:) {mustBeMember(LabelPosition,{'left','right','above','below'})} = 'left';

        position        (1,4) double {mustBeFinite,mustBeNonNan,mustBeNonempty} = [0 0 1 1];

        Parameter       (1,1) epsych.Parameter
        
    end

    properties (SetAccess = private)
        hLabel
        hControl
        
        Style   (1,:) char {mustBeMember(Style,{'checkbox','edit','listbox','popupmenu','slider','auto'})} = 'auto';
    end

    properties (SetAccess = immutable)
        parent
    end

    methods
        function obj = ParameterControl(Parameter,parent,position,style,varargin)
            narginchk(3,5);

            obj.Parameter = Parameter;
            obj.parent    = parent;
            obj.position  = position;

            if nargin >= 4 && ~isempty(style), obj.Style = style; end

            p = properties(obj);
            for i = 1:2:length(varargin)
                ind = strcmpi(p,varargin{i});
                assert(any(ind),'epsych.Parameter:Parameter:InvalidParameter', ...
                    'Invalid property "%s"',varargin{i})
                obj.(p{ind}) = varargin{i+1};
            end

            obj.create;
        end

        function create(obj)

            if isequal(obj.Style,'auto')
                if obj.Parameter.N == 1
                    obj.Style = 'edit';

                elseif obj.Parameter.isLogical
                    obj.Style = 'checkbox';

                elseif obj.Parameter.isMultiselect
                    obj.Style = 'listbox';

                elseif obj.Parameter.isRange
                    obj.Style = 'slider';

                else
                    obj.Style = 'popupmenu';
                end
            end

            h = uicontrol(obj.parent, ...
                'Style',   obj.Style, ...
                'Position',obj.position, ...
                'ButtonDownFcn',@obj.modify_parameter);
                
            switch obj.Style
                case 'edit'
                    h.String = obj.Parameter.Expression;

                case 'checkbox'
                    h.Value = obj.Parameter.Value;

                case {'listbox','popupmenu'}
                    h.String = obj.Parameter.ValuesStr;

                case 'slider'
                    error('slider not yet implemented')

            end

            obj.hControl = h;
            

            hL = uicontrol(obj.parent, ...
                'Style',   'text', ...
                'String',   obj.Parameter.Name);
            hL.Position([1 2]) = h.Position([1 2]);

            switch obj.LabelPosition
                case 'left'
                    hL.Position(1) = h.Position(1)-hL.Position(3);
                    hL.HorizontalAlignment = 'right';

                case 'right'
                    hL.Position(1) = sum(h.Position([1 3]));
                    hL.HorizontalAlignment = 'left';

                case 'above'
                    hL.Position(2) = sum(h.Position([2 4]));
                    hL.HorizontalAlignment = 'left';

                case 'below'
                    hL.Position(2) = h.Position(2)-hL.Position(4);
                    hL.HorizontalAlignment = 'left';
            end

            obj.hLabel = hL;
        end


        function modify_parameter(obj,varargin)
            disp(obj)
        end

    end

end