function F = emptyFit_()
% F = psychophysics.Staircase.emptyFit_()
% The psychometric-fit result skeleton, with every field present and empty.
%
% Every return path in fitProportions and fitPsychometric starts here, so a
% caller can read F.Converged, F.Identifiable and F.Message on a refusal
% exactly as on a successful fit -- a fit that could not be made returns a
% struct, never a different shape and never an error.
%
% The caller fills in what it was asked for (Shape, Direction, the asymptotes)
% immediately afterwards, so a refused fit still reports it.
%
% Returns:
%   F - Fit result struct with unset numeric fields NaN, unset vectors empty,
%       Converged/Identifiable/Separated false, and Message "".

F = struct();

% What was asked for; overwritten by the caller with its own options.
F.Shape          = "Logistic";
F.Direction      = "increasing";
F.GuessRate      = 0;
F.LapseRate      = 0;
F.LapseEstimated = false;

% Estimates
F.Alpha = NaN;
F.Beta  = NaN;

% Threshold
F.Threshold                  = NaN;
F.ThresholdCriterionAbsolute = NaN;
F.ThresholdInRange           = false;

% The data the fit was made from
F.Levels        = zeros(1,0);
F.NumYes        = zeros(1,0);
F.NumTotal      = zeros(1,0);
F.Proportion    = zeros(1,0);
F.NumLevels     = 0;
F.NumTrials     = 0;
F.NumParameters = NaN;

% The fitted curve, for plotting
F.Curve = struct('x', zeros(1,0), 'P', zeros(1,0));

% Fit quality
F.LogLikelihood  = NaN;
F.NegLogLik      = NaN;
F.Deviance       = NaN;
F.DevianceDF     = NaN;
F.DeviancePValue = NaN;
F.AIC            = NaN;

% Whether to believe any of it
F.Converged     = false;
F.Identifiable  = false;
F.Separated     = false;
F.ResponseRange = NaN;
F.Message       = "";

% Bootstrap interval
F.CI = struct('Level', NaN, 'Requested', 0, 'Replicates', 0, ...
    'Alpha', [NaN NaN], 'Beta', [NaN NaN], 'Threshold', [NaN NaN]);
