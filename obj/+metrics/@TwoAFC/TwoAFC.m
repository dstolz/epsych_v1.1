classdef TwoAFC < metrics.Metrics
    
properties
        ValidPlotTypes = {'d-prime','Hit Rate','Miss Rate','Bias c', ...
                        'Bias ln(beta)', 'Lapse Rate', 'Abort Rate'};
    end

    methods
        function obj = TwoAFC(BoxID)
            if nargin == 0 || isempty(BoxID), BoxID = 1; end
            
            obj = obj@metrics.Metrics(BoxID);


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

                P(i).TrialType = c{i};

                P(i).N = N;
                
                P(i).DPrime = obj.dprime_2afc(HR,MR,N);
                P(i).APrime = obj.aprime(HR,MR);
                P(i).beta   = obj.bias_lnbeta(HR,MR,N);
                P(i).c      = obj.bias_c(HR,MR,N);

                P(i).AbortRate = sum(S.Abort(ind)) ./ N;
                P(i).LapseRate = sum(S.NoResponse(ind)) ./ N;

                P(i).HitRate  = HR;
                P(i).MissRate = MR;
                P(i).FalseAlaramRate = MR; % FAR = MR for 2afc
            end

        end



    end

end