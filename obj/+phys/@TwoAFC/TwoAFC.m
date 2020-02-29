classdef TwoAFC < phys.Phys

    properties (SetAccess = protected)
        BitmaskInUse phys.Bitmask = [phys.Bitmask.Hit, phys.Bitmask.Miss, phys.Bitmask.Abort, phys.Bitmask.Choice_1, phys.Bitmask.Choice_2];
    end


    methods
        function obj = TwoAFC(BoxID,parameterName)

            if nargin < 1 || isempty(BoxID), BoxID = 1; end
            if nargin < 2, parameterName = []; end
            obj = obj@phys.Phys(BoxID,parameterName);

            obj.TrialTypeColors = [.4 .4 .4; .8 1 .8; 1 .7 .7; .7 .9 1; 1 .7 1]; % [Abort Hit Miss Choice1 Choice2]
    
        end
    end

end