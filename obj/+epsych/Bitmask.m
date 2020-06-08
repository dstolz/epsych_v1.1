classdef Bitmask < matlab.mixin.Copyable
    % [lsb msb]
       
    properties
        UserData
        
        Mask    (1,1) uint16
    end
    
    
    properties (Access = protected)
        Bits    (1,1) struct
    end
    
    properties (SetAccess = private)        
        Boolean (1,:) logical
        Labels
        Digits
        Values
    end
    
    properties (Access = private)
        digitOrder
        
        lbls
        digs
        vals
    end
    
    methods
        function obj = Bitmask(label,digit,value)
            if nargin == 0, return; end
            
            label = cellstr(label);
            
            if nargin < 2 || isempty(digit), digit = []; end
            if nargin < 3 || isempty(value), value = false(size(label)); end

            
            for i = 1:numel(label)
                if isempty(digit)
                    obj.add_bit(label{i},[],value(i));
                else
                    obj.add_bit(label{i},digit(i),value(i));
                end
            end
            
        end
      
        
        function add_bit(obj,label,digit,value)
            narginchk(2,4)
           
            assert(ischar(label), ...
                'epsych.Bitmask:add_bit:InvalidType', ...
                'label must be char');
            
            if nargin < 3 || isempty(digit)
                digit = find(~ismember(0:15,obj.Digits),1)-1;
            end
            
            assert(isnumeric(digit), ...
                'epsych.Bitmask:add_bit:InvalidType', ...
                'digit must be numeric');
            
            assert(digit >= 0 & digit <= 15, ...
                'epsych.Bitmask:add_bit:InvalidDigit', ...
                'User defined bits must be >= 0 & <= 15');
            
            label = matlab.lang.makeValidName(label);
            
            assert(~ismember({label},obj.Labels), ...
                'epsych.Bitmask:add_bit:DuplicateLabel', ...
                sprintf('The label "%s" already exists or is invalid.',label));
            
            assert(~any(digit == obj.Digits), ...
                'epsych.Bitmask:add_bit:DuplicateDigit', ...
                sprintf('The digit %d is already used by "%s".',digit,label));
            
            if nargin < 4 || isempty(value), value = false; end
            
            if isnumeric(value), value = logical(value); end
            
            obj.Bits.(label).Digit = uint16(digit);
            obj.Bits.(label).Value = value;
            
            obj.update;
        end
        
        function update_bit(obj,targ,value)
            if ischar(targ), targ = cellstr(targ); end
            
            if iscellstr(targ)
                ind = ~ismember(targ,obj.Labels);
                targ(ind) = [];
            end
            
            if isempty(targ), return; end
            
            if isnumeric(targ)
                lbl = obj.Labels(ismember(obj.Digits,targ));
            else
                lbl = targ;
            end
            
            if nargin < 3 || isempty(value) % toggle value
                value = cellfun(@(a) ~obj.Bits.(a).Value,lbl);
            end
            
            value = logical(value);

            nv = length(value);
            if nv == 1 && nv < length(lbl), value = repmat(value,size(lbl)); end
            
            for i = 1:length(lbl)
                obj.Bits.(lbl{i}).Value = value(i);
            end
            
            obj.update;
        end
        
        function reset_bits(obj)
            lbl = obj.Labels;
            for i = 1:length(lbl)
                obj.Bits.(lbl{i}).Value = false;
            end
            update(obj);
        end

        function remove_bit(obj,targ)
            if ischar(targ), targ = cellstr(targ); end
                        
            if iscellstr(targ)
                ind = ~ismember(targ,obj.Labels);
                targ(ind) = [];
            end
            
            if isempty(targ), return; end
            
            if isnumeric(targ)
                bits = cellfun(@(a) obj.Bits.(a),obj.Labels);
                lbl = p(ismember(bits,targ));
            else
                lbl = targ;
            end
            
            for i = 1:numel(lbl)
                obj.Bits = rmfield(obj.Bits,lbl{i});
            end
            obj.update;
        end
        
        
        
        
        function lbl = get.Labels(obj)
            lbl = obj.lbls(obj.digitOrder);
            if isempty(lbl), lbl = {}; end
        end
        
        function d = get.Digits(obj)
            d = obj.digs(obj.digitOrder)';
        end
        
        function v = get.Values(obj)
            v = obj.vals(obj.digitOrder);
        end
        
        function set.Mask(obj,m)
            d = obj.bitmask2digits(m);
            obj.reset_bits;
            obj.update_bit(d,true);
        end
        
        function m = get.Mask(obj)
            m = obj.boolean2bitmask(obj.Boolean);
        end
        
        function i = get.digitOrder(obj)
            [~,i] = sort(obj.digs);
        end
        
        function b = get.Boolean(obj)
            d = obj.Digits+1;
            v = obj.Values;
            
            b = false(1,16);
            b(d) = v;
        end
        
        
        
        
        
    end % methods
    
    methods (Access = private)
        function update(obj)
            obj.lbls = fieldnames(obj.Bits)';
            obj.digs = structfun(@(a) a.Digit,obj.Bits);
            obj.vals = structfun(@(a) a.Value,obj.Bits)';
        end
    end % methods (Access = private)
    
    methods (Static)
        
        function m = bitmask2boolean(bm)
            m = logical(bitget(bm,1:16,'uint16'));
        end
        
        function bm = boolean2bitmask(bool)
            bm = uint16(sum(2.^(find(bool)-1)));
        end
        
        function d = bitmask2digits(bm)
            d = find(epsych.Bitmask.bitmask2boolean(bm))-1;
        end
        
        function bm = digits2bitmask(digits)
            bm = sum(2.^(digits-1));
        end
        
    end

end