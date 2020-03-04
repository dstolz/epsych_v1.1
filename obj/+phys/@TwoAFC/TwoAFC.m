classdef TwoAFC < phys.Phys


    methods
        function obj = TwoAFC(parameterName,BoxID)
            if nargin < 1, parameterName = []; end
            if nargin < 2  || isempty(BoxID), BoxID = 1; end
            
            obj = obj@phys.Phys(parameterName,BoxID);

            obj.TrialTypes = [epsych.Bitmask.TrialType_0, ...
                            epsych.Bitmask.TrialType_1, ...
                            epsych.Bitmask.TrialType_2, ...
                            epsych.Bitmask.TrialType_3];
                        
            obj.BitmaskInUse  = [epsych.Bitmask.Hit, ...
                            epsych.Bitmask.Miss, ...
                            epsych.Bitmask.Response_A, ...
                            epsych.Bitmask.Response_B, ...
                            epsych.Bitmask.NoResponse, ...
                            epsych.Bitmask.Abort];
            
             % [HitRate MissRate Response_A Response_B NoResponse Abort]
            obj.PerformanceColors = [.8 1 .8; 1 .8 .8; .7 .9 1; 1 .7 1; .4 .4 .4; .4 1 .4];
        end


        function P = compute_performance(obj)
            % P = compute_performance(obj)

            S = obj.ResponseCodeBits;

            c = obj.TrialTypesChar;
            for i = 1:length(c)
                ind = S.(c{i});

                N = sum(ind);

                HR = sum(S.Hit(ind)) ./ sum(s.Hit(ind)|s.Miss(ind));
                MR = 1./HR;

                P.(c{i}).DPrime = obj.dprime_2afc(HR,MR,N);
                P.(c{i}).APrime = obj.aprime(HR,MR);
                P.(c{i}).beta   = obj.bias_lnbeta(HR,MR,N);
                P.(c{i}).c      = obj.bias_c(HR,MR,N);

                P.(c{i}).AbortRate = sum(S.Abort(ind)) ./ N;
                P.(c{i}).LapseRate = sum(S.NoResponse(ind)) ./ N;

                P.(c{i}).HitRate  = HR;
                P.(c{i}).MissRate = MR;
            end

        end



    end

end