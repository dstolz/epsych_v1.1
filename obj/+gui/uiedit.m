classdef uiedit < gui.ParameterControl
    
    
    properties (Constant)
        Style = 'edit';
    end

    methods
        function obj = uiedit(Parameter,parent,position,varargin)
            narginchk(3,5);

            obj = obj@gui.ParameterControl(Parameter,parent,position);
            
        end
        

        function create(obj)

%             if isequal(obj.Style,'auto')
%                 if obj.Parameter.N == 1
%                     obj.Style = 'edit';
% 
%                 elseif obj.Parameter.isLogical
%                     obj.Style = 'checkbox';
% 
%                 elseif obj.Parameter.isMultiselect
%                     obj.Style = 'listbox';
% 
%                 elseif obj.Parameter.isRange
%                     obj.Style = 'slider';
% 
%                 else
%                     obj.Style = 'popupmenu';
%                 end
%             end

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


            obj.hLabel = hL;
        end

    end

end