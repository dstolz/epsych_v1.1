classdef psychophysics < handle
    properties

    end

    properties (Abstract,Constant)
        Type
    end

    methods

        function dp = dprime(obj,HR,FAR)
            swtich obj.Type
                case {'DETECT','YESNO'}
                    dp = obj.dprime_detect(HR,FAR);
                case '2AFC'
                    dp = obj.dprime_2afc(HR,FAR);
            end
        end
    end

    methods (Static)
        function z = zscore(a)
            % bounds input to [0.01 0.99] to avoid inf values
            a = max(min(a,0.99),0.01);
            z = norminv(a,0,1);
        end

        function dp = dprime_detect(HR,FAR)
            if obj.Type
            HR = max(min(HR,0.99),0.01);
            FAR = max(min(HR,0.99),0.01);
            dp = norminv(HR) - norminv(FAR);
        end

        function dp = dprime_2afc(HR,FAR)
            dp = psychophysics.dprime(HR,FAR)./sqrt(2);
        end
    end
end