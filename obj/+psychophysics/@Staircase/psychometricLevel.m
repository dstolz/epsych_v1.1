function x = psychometricLevel(P, alpha, beta, options)
% x = psychophysics.Staircase.psychometricLevel(P, alpha, beta)
% x = psychophysics.Staircase.psychometricLevel(P, alpha, beta, Shape="Weibull")
% x = psychophysics.Staircase.psychometricLevel(..., GuessRate=g, LapseRate=l)
% Invert psychometricFunction: the stimulus level at a response probability.
%
% This is how a threshold is read off a fit -- "the level at which the
% subject responded on 70.7% of trials" is this function at P = 0.707.
%
% P is an ABSOLUTE response probability, so a target outside the asymptotes
% the function actually spans -- below gamma or above 1 - lambda -- has no
% level and returns NaN rather than a plausible-looking extrapolation. That
% is the trap this function exists to make visible: on a 2AFC task with
% GuessRate 0.5, a target of 0.5 is unreachable, not a threshold at the
% midpoint. fitProportions therefore accepts a criterion on the BETWEEN-
% ASYMPTOTE scale by default, converting it before it gets here.
%
% Parameters:
%   P         - Absolute response probabilities to invert.
%   alpha     - Location parameter (scale parameter for Weibull).
%   beta      - Slope parameter; negative reverses Logistic and Normal.
%   Shape     - "Logistic" (default), "Normal", or "Weibull".
%   GuessRate - Lower asymptote gamma (default 0).
%   LapseRate - Upper asymptote offset lambda (default 0).
%
% Returns:
%   x - Stimulus levels, NaN where P is outside (gamma, 1 - lambda).
%
% See also psychophysics.Staircase.psychometricFunction,
% psychophysics.Staircase.fitProportions

arguments
    P double
    alpha double
    beta double
    options.Shape (1,1) string {mustBeMember(options.Shape,["Logistic","Normal","Weibull"])} = "Logistic"
    options.GuessRate (1,1) double {mustBeInRange(options.GuessRate,0,1)} = 0
    options.LapseRate (1,1) double {mustBeInRange(options.LapseRate,0,1)} = 0
end

gamma  = options.GuessRate;
lambda = options.LapseRate;
span   = 1 - gamma - lambda;

if span <= 0
    x = nan(size(P));
    return
end

% Rescale onto the base CDF; only the open interval is invertible.
pn = (P - gamma) ./ span;
pn(pn <= 0 | pn >= 1) = NaN;

switch options.Shape
    case "Logistic"
        x = alpha + log(pn ./ (1 - pn)) ./ beta;

    case "Normal"
        x = alpha + norminv(pn) ./ beta;

    case "Weibull"
        x = alpha .* (-log(1 - pn)) .^ (1 ./ beta);
end
