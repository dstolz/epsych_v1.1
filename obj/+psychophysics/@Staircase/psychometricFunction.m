function P = psychometricFunction(x, alpha, beta, options)
% P = psychophysics.Staircase.psychometricFunction(x, alpha, beta)
% P = psychophysics.Staircase.psychometricFunction(x, alpha, beta, Shape="Weibull")
% P = psychophysics.Staircase.psychometricFunction(..., GuessRate=g, LapseRate=l)
% Evaluate a psychometric function.
%
%       P(x) = gamma + (1 - gamma - lambda) * F(x; alpha, beta)
%
% where F is the base CDF named by Shape, gamma is the lower asymptote (the
% guess rate) and lambda the offset of the upper one (the lapse rate):
%
%   "Logistic"  F = 1 ./ (1 + exp(-beta*(x - alpha)))
%   "Normal"    F = Phi((x - alpha)*beta)          -- beta = 1/sigma
%   "Weibull"   F = 1 - exp(-(x/alpha)^beta)       -- alpha > 0, x > 0
%
% These are the same three shapes, with the same parameterization, that
% psychophysics.BestPEST uses, so a threshold from either is directly
% comparable -- including the Statistics Toolbox normcdf underneath the
% normal shape, which is BestPEST's too.
%
% Pure and stateless: it holds no data and reads no object, which is what
% makes the fit in fitProportions testable against hand-computed values.
%
% A NEGATIVE beta gives a DECREASING function for the Logistic and Normal
% shapes, with alpha still the midpoint -- that is how fitProportions
% represents Direction="decreasing". Weibull is defined on x > 0 only;
% nonpositive x yields NaN rather than the complex number a fractional power
% of a negative number would otherwise produce silently.
%
% The value is NOT clamped away from 0 and 1: this returns the function, and
% only the likelihood inside fitProportions needs a bounded version of it.
%
% Every input broadcasts, so a vector of levels evaluates against a vector of
% candidate alphas in one call.
%
% Parameters:
%   x         - Stimulus levels.
%   alpha     - Location parameter (scale parameter for Weibull).
%   beta      - Slope parameter; negative reverses Logistic and Normal.
%   Shape     - "Logistic" (default), "Normal", or "Weibull".
%   GuessRate - Lower asymptote gamma (default 0; 0.5 for a 2AFC task).
%   LapseRate - Upper asymptote offset lambda (default 0).
%
% Returns:
%   P - Response probabilities, broadcast to the common size.
%
% See also psychophysics.Staircase.psychometricLevel,
% psychophysics.Staircase.fitProportions,
% documentation/psychophysics/psychophysics_StaircaseFit.md

arguments
    x double
    alpha double
    beta double
    options.Shape (1,1) string {mustBeMember(options.Shape,["Logistic","Normal","Weibull"])} = "Logistic"
    options.GuessRate (1,1) double {mustBeInRange(options.GuessRate,0,1)} = 0
    options.LapseRate (1,1) double {mustBeInRange(options.LapseRate,0,1)} = 0
end

gamma  = options.GuessRate;
lambda = options.LapseRate;
span   = 1 - gamma - lambda;

switch options.Shape
    case "Logistic"
        F = 1 ./ (1 + exp(-beta .* (x - alpha)));

    case "Normal"
        % The ONE-ARGUMENT normcdf, deliberately: normcdf(x, alpha, 1./beta)
        % is the same function only for beta > 0, and a negative beta -- how
        % Direction="decreasing" is represented -- would reach it as a
        % negative sigma.
        F = normcdf((x - alpha) .* beta);

    case "Weibull"
        % A fractional power of a negative number is complex in MATLAB and
        % would propagate silently through the fit, so the undefined half of
        % the domain is made NaN before the power is taken.
        r = x ./ alpha;
        r(r < 0) = NaN;
        F = 1 - exp(-(r .^ beta));
end

P = gamma + span .* F;
