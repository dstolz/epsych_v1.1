classdef Detection < epsych.metrics.Metrics
        
properties
    ValidPlotTypes = {'d-prime','Hit Rate','Miss Rate','False Alarm Rate','Bias c', ...
                    'Bias ln(beta)', 'Lapse Rate', 'Abort Rate'};
end


    
    
    methods
        function obj = Detection(BoxID)
            if nargin == 0 || isempty(BoxID), BoxID = 1; end
            
            obj = obj@epsych.metrics.Metrics(BoxID);
            
            obj.TrialTypes = [epsych.enBits.StimulusTrial, epsych.enBits.CatchTrial];

        end
        

        function P = compute_performance(obj)
            % P = compute_performance(obj)

            S = obj.ResponseCodeBits;

            c = obj.TrialTypesChar;
            for i = 1:length(c)
                ind = S.(c{i});

                N = sum(ind);

                HR = sum(S.Hit(ind)) ./ sum(S.Hit(ind)|S.Miss(ind));
                MR = 1 - HR;
                FAR = sum(S.FalseAlarm(ind)) ./ sum(S.FalseAlarm(ind)|S.CorrectReject(ind));

                P(i).TrialType = c{i};

                P(i).N = N;
                
                P(i).DPrime = obj.dprime(HR,MR,N);
                P(i).APrime = obj.aprime(HR,MR);
                P(i).beta   = obj.bias_lnbeta(HR,MR,N);
                P(i).c      = obj.bias_c(HR,MR,N);

                P(i).AbortRate = sum(S.Abort(ind)) ./ N;
                P(i).LapseRate = sum(S.NoResponse(ind)) ./ N;

                P(i).HitRate  = HR;
                P(i).FalseAlarmRate = FAR; 
                P(i).MissRate = MR; 
                
            end

        end
        
        
    end
    
end