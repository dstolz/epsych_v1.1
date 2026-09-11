function T = emptyWeightedThreshold_()
% T = psychophysics.Staircase.emptyWeightedThreshold_()
% The weighted-staircase threshold result skeleton, every field present.
%
% Every return path in correctedReversalMean and weightedThreshold starts
% here, so a caller reads T.Valid and T.Message on a refusal exactly as on
% a threshold -- a threshold that could not be computed returns a struct,
% never a different shape and never an error.
%
% StepDown, StepUp, StepRatio and TargetProbability are Hoover's (2025)
% delta_-, delta_+, r and psi, so a result reads straight against the paper.
%
% Returns:
%   T - Result struct with unset numeric fields NaN, unset vectors empty,
%       Valid false, and Message "".

T = struct();

% The threshold
T.Threshold    = NaN;     % ReversalMean + Correction
T.ReversalMean = NaN;     % mean of the balanced reversals, uncorrected
T.Correction   = NaN;     % -(StepAfterYes + StepAfterNo)/4 = (delta_- - delta_+)/4
T.ReversalStd  = NaN;     % std of the balanced reversals

% The steps, signed, in the tracked parameter's own units
T.StepAfterYes    = NaN;
T.StepAfterNo     = NaN;
T.StepSource      = "";          % "stated" | "field" | "inferred" | "<yes>/<no>"
T.StepConsistency = [NaN NaN];   % fraction of samples at the nominal step, [yes no]
T.StepsConsistent = false;
T.NumStepsYes     = 0;           % samples examined; 0 for a stated step
T.NumStepsNo      = 0;

% The paper's quantities
T.StepDown              = NaN;   % delta_-, |StepAfterYes|
T.StepUp                = NaN;   % delta_+, |StepAfterNo|
T.StepRatio             = NaN;   % r = delta_- / delta_+
T.TargetProbability     = NaN;   % psi = 1/(r + 1)
T.ExpectedTarget        = NaN;
T.TargetMatchesExpected = false;

% The reversals
T.NumReversals          = 0;     % used, = NumAscending + NumDescending
T.NumAscending          = 0;     % peaks, in the parameter's own units
T.NumDescending         = 0;     % troughs
T.NumUndefinedReversals = 0;     % non-finite values, never used
T.ReversalValues        = zeros(1,0);
T.ReversalUsed          = false(1,0);
T.ReversalIdx           = zeros(1,0);   % trial indices; filled by weightedThreshold

% Whether to believe it
T.ParameterName = "";
T.Valid         = false;
T.Message       = "";
