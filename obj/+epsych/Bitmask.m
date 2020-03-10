classdef (ConstructOnLoad) Bitmask < dynamicprops & matlab.mixin.Copyable
    % [lsb msb]
    
    properties
        Value; % Do not use type checking
        Bits    (1,:) uint32;
        Boolean (1,:) logical;
        Labels  (1,:) cell;
    end
    
    
    properties (Access = protected)
        userProps
    end

    properties (Constant)
        Undefined     uint32 = 0;
        Reward        uint32 = 1;
        Punish        uint32 = 2;
        Hit           uint32 = 3;
        Miss          uint32 = 4;
        Abort         uint32 = 5;
        CorrectReject uint32 = 6;
        FalseAlarm    uint32 = 7;
        TrialType_0   uint32 = 8;
        TrialType_1   uint32 = 9;
        TrialType_2   uint32 = 10;
        TrialType_3   uint32 = 11;
        StimulusTrial uint32 = 12;
        CatchTrial    uint32 = 13;
        Response_A    uint32 = 14;
        Response_B    uint32 = 15;
        NoResponse    uint32 = 16;
    end
    
    
    methods
        function obj = Bitmask(initVal,isBits)
            if nargin == 0, return; end
            if nargin < 2, isBits = false; end
            
            if isBits, initVal = logical(initVal); end
            
            obj.Value = initVal;
        end
        
        function set.Value(obj,val)
            if islogical(val)
                obj.Value = obj.boolean2bitmask(find(val)); %#ok<FNDSB>
            elseif length(val) == 1
                obj.Value = val;
            else
                obj.Value = obj.bits2bitmask(val);
            end
        end
        
        function set.Bits(obj,b)
            obj.update_value('bits',b);
        end
        
        function b = get.Bits(obj)
            b = uint32(find(obj.Boolean));
        end
        
        function set.Boolean(obj,m)
            obj.update_value('boolean',m);
        end
        
        function m = get.Boolean(obj)
            m = obj.bitmask2bool(obj.Value);
        end
        
        
        function d = get.Labels(obj)
            lbl = obj.default_bits;
            if ~isempty(obj.userProps)
                userLabels = fieldnames(obj.userProps);
                lbl = [lbl(:); userLabels(:)];
            end
            v = cellfun(@(a) obj.(a),lbl);
            d = lbl(ismember(v,obj.Bits-1));
        end
        
        function set.Labels(obj,lbl)
            bits = cellfun(@(a) obj.(a),lbl);
            obj.update_value('bits',bits);
        end
        
        
        function update_value(obj,type,val)
            switch type
                case 'boolean'
                    obj.Value = obj.boolean2bitmask(val);
                    
                case 'bits'
                    obj.Value = obj.bits2bitmask(val);
                    
                case 'bitmask'
                    obj.Value = val;
                
            end
        end
        
        
        function add_user_bit(obj,bit,label)
            narginchk(3,3)
            
            assert(bit > 16 & bit <= 32,'epsych.Bitmask:add_user_bit:InvalidBit', ...
                'User defined bits must be >= 17 & <= 32');
            
            label = matlab.lang.makeValidName(label);
            
            obj.userProps.(label) = addprop(obj,label);
            obj.(label) = uint32(bit);
        end
        
        function remove_user_bit(obj,targ)
            if ischar(targ), targ = {targ}; end
            
            if isempty(obj.userProps), return; end
            
            p = fieldnames(obj.userProps);
            
            if isnumeric(targ)
                bits = cellfun(@(a) obj.(a),p);
                lbl = p(ismember(bits,targ));
            else
                lbl = targ;
            end
            
            cellfun(@(a) delete(obj.userProps.(a)),lbl);
        end
    end
    
    methods (Static)
        
        function m = bitmask2bool(bm)
            m = logical(bitget(bm,1:32,'uint32'));
        end
        
        function bm = boolean2bitmask(bool)
            bm = sum(2.^find(bool));
        end
        
        function b = bitmask2bits(bm)
            b = find(epsych.Bitmask.bitmask2bool(bm));
        end
        
        function bm = bits2bitmask(bits)
            bm = sum(2.^bits);
        end
        
        
        function varargout = default_bits
            bm = epsych.Bitmask;
            p = metaclass(bm);
            ind = [p.PropertyList.Constant];
            c = p.PropertyList(ind);
            lbl = {c.Name};
            varargout{1} = lbl;
            varargout{2} = cellfun(@(a) bm.(a),lbl);
        end
    end

end