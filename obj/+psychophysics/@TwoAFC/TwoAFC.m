classdef TwoAFC < psychophysics.psychophysics


    properties (Constant)
        Type = '2AFC';
        ResponseBits = epsych.BitMask([3 4 5 8]) % [Hit Miss Abort NoResponse]
    end
    

    methods        
        function obj = TwoAFC(Runtime,BoxID)
            narginchk(1,2);

            if nargin < 2 || isempty(BoxID), BoxID = 1; end

            obj = obj@psychophysics.psychophysics(Runtime,BoxID);
        end

        
        
    end

end