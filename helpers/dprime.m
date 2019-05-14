function dp = dprime(HR,FAR)
% dp = dprime(HR,FAR)
%
% Compute d-prime between a hit-rate and false-alarm rate which are
% within the bounds of [0.01 0.99]

narginchk(2,2);

HR  = max(min(HR,0.99),0.01);
FAR = max(min(FAR,0.99),0.01);

z = @(a) sqrt(2)*erfinv(2*a-1);

dp = z(HR) - z(FAR);