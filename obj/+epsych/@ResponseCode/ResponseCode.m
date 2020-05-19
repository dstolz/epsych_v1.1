classdef ResponseCode
    
    properties
        Code (1,1) uint16 
    end
    
    properties (Dependent)
        Translate
        Bits
    end
    
    methods
        function obj = ResponseCode(code)
            if nargin == 1, obj.Code = code; end
        end
        
        function d = get.Bits(obj)
            d = bitget(obj.Code,1:16,'uint16');
        end
        
        function b = get.Translate(obj)
            b = epsych.enBits(find(obj.Bits))'; %#ok<FNDSB>
        end
        
        function obj = encode(obj,bits)
            obj.Code = uint16(0);
            obj.Code = sum(bitset(obj.Code,bits,'uint16'));
        end
    end
end