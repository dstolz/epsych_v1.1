classdef TwoAFC < phys.Phys


    properties (SetAccess = protected) % define abstract properties inherited from phys.Phys
        BitmaskGroups = [epsych.Bitmask.TrialType_0, epsych.Bitmask.TrialType_1];
        BitmaskInUse  = [epsych.Bitmask.Hit, epsych.Bitmask.Miss, epsych.Bitmask.Response_A, epsych.Bitmask.Response_B, epsych.Bitmask.Abort];
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