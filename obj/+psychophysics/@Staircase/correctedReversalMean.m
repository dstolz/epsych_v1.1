function T = correctedReversalMean(reversalValues, reversalIsAscending, stepAfterYes, stepAfterNo, options)
% T = psychophysics.Staircase.correctedReversalMean(values, isAscending, stepAfterYes, stepAfterNo)
% T = psychophysics.Staircase.correctedReversalMean(..., NumReversals=12, ExpectedTarget=0.75)
% Threshold of a weighted (asymmetric-step) staircase, corrected for the
% bias of the reversal mean (Hoover 2025).
%
% A weighted up-down staircase (Kaernbach 1991) targets an arbitrary
% probability of response by stepping a different distance after a "yes"
% than after a "no". The mean of its reversals is biased -- in proportion to
% the step size and always toward the tail of the psychometric function
% (Garcia-Perez 1998, 2011) -- and Hoover's Eq. (3) removes the bias:
%
%   x_psi  ~=  x_R + (delta_- - delta_+)/4
%
% where x_R is the mean of an EQUAL number of ascending and descending
% reversals, delta_- the step down after a yes and delta_+ the step up after
% a no, on an axis along which the probability of a yes increases.
%
% The steps here are SIGNED, in the tracked parameter's own units, and named
% by the response that preceded them rather than by the direction they go.
% Written that way the correction is
%
%   Correction = -(stepAfterYes + stepAfterNo)/4
%
% for a parameter whose probability of a yes rises with it (a level, dB SPL)
% AND for one whose probability falls with it (an attenuation, a masker):
% mirroring the axis flips both the steps and the correction, and the two
% flips cancel. So there is no Direction option, and none is needed.
%
% Pure: no session, no object, no figure. psychophysics.Staircase.weightedThreshold
% is the seam that turns a staircase's trials into these inputs.
%
% The correction is a rule of thumb backed by simulation, not a proof, and
% it applies to a psychometric function symmetric about 0.5 that spans
% (0, 1) -- not to an mAFC task with few alternatives, nor with a lapse rate
% much above 1/10. See documentation/psychophysics/psychophysics_WeightedStaircase.md.
%
% Parameters:
%   reversalValues      - Level at each reversal, in chronological order.
%                         A non-finite value is dropped and counted in
%                         T.NumUndefinedReversals.
%   reversalIsAscending - Logical, same size: true for a peak (an increase
%                         followed by a decrease) in the parameter's own
%                         units. The set is balanced, so which way the axis
%                         runs does not change which reversals are used.
%   stepAfterYes        - Signed change in the parameter after a "yes".
%   stepAfterNo         - Signed change after a "no"; opposite in sign.
%   NumReversals        - Start from the last N defined reversals, then
%                         balance (default Inf, all of them).
%   ExpectedTarget      - The probability the caller meant the steps to
%                         target, as an ASSERTION: a mismatch sets
%                         T.TargetMatchesExpected false and says why, but
%                         does not change T.Threshold. Default NaN, no check.
%   TargetTolerance     - How far T.TargetProbability may sit from
%                         ExpectedTarget and still match (default 0.01).
%
% Returns:
%   T - Result struct (see emptyWeightedThreshold_). Check T.Valid before
%       reading T.Threshold; T.Message says why when it is false, and
%       carries any advisory when it is true.
%
% A size mismatch between reversalValues and reversalIsAscending throws: it
% is a caller bug. Everything about the DATA -- a zero or same-signed step,
% no reversals, reversals in one direction only -- returns Valid = false.
%
% Example:
%   T = psychophysics.Staircase.correctedReversalMean( ...
%       [-18 -22 -19 -23 -20 -24], logical([1 0 1 0 1 0]), -2, 6);
%   T.Threshold          % -21 - (-2 + 6)/4 = -22
%   T.TargetProbability  % 0.75
%
% See also psychophysics.Staircase.weightedThreshold

arguments
    reversalValues {mustBeNumeric}
    reversalIsAscending {mustBeNumericOrLogical}
    stepAfterYes (1,1) double
    stepAfterNo (1,1) double
    options.NumReversals (1,1) double {mustBeCountOrInf} = Inf
    options.ExpectedTarget (1,1) double {mustBeProbabilityOrNaN} = NaN
    options.TargetTolerance (1,1) double {mustBeNonnegative} = 0.01
end

if numel(reversalValues) ~= numel(reversalIsAscending)
    error('psychophysics:Staircase:WeightedSizeMismatch', ...
        'reversalValues has %d elements but reversalIsAscending has %d.', ...
        numel(reversalValues), numel(reversalIsAscending));
end
% A direction is a fact the caller knows, not a measurement: a NaN or a 2
% here is a bug upstream, and logical() would either throw MATLAB's generic
% message or quietly read 2 as true.
if ~islogical(reversalIsAscending) && ~all(reversalIsAscending(:) == 0 | reversalIsAscending(:) == 1)
    error('psychophysics:Staircase:WeightedInvalidAscending', ...
        'reversalIsAscending must be logical, or numeric 0 and 1 only.');
end

T = psychophysics.Staircase.emptyWeightedThreshold_();
T.StepAfterYes    = stepAfterYes;
T.StepAfterNo     = stepAfterNo;
T.StepSource      = "stated";
T.StepsConsistent = true;       % nothing measured here, so nothing contradicts it
T.ExpectedTarget  = options.ExpectedTarget;

reasons = strings(1,0);         % why Valid is false
notes   = strings(1,0);         % advisories that leave it true

% ---- The steps -------------------------------------------------------------
stepsOk = false;
if ~isfinite(stepAfterYes) || ~isfinite(stepAfterNo) || stepAfterYes == 0 || stepAfterNo == 0
    reasons(end+1) = sprintf(['A step is zero or not finite (after a yes %g, after a no %g), ' ...
        'so the track targets no probability.'], stepAfterYes, stepAfterNo);
elseif sign(stepAfterYes) == sign(stepAfterNo)
    reasons(end+1) = sprintf(['The steps after a yes (%g) and after a no (%g) have the same sign, ' ...
        'so the track only moves one way and is not a staircase.'], stepAfterYes, stepAfterNo);
else
    stepsOk = true;
    T.StepDown  = abs(stepAfterYes);
    T.StepUp    = abs(stepAfterNo);
    T.StepRatio = T.StepDown / T.StepUp;
    T.TargetProbability = T.StepUp / (T.StepDown + T.StepUp);   % = 1/(r + 1)
    T.Correction = -(stepAfterYes + stepAfterNo) / 4;
end

% ---- The reversals ---------------------------------------------------------
v   = reshape(double(reversalValues), 1, []);
asc = reshape(logical(reversalIsAscending), 1, []);
defined = isfinite(v);

T.ReversalValues        = v;
T.NumUndefinedReversals = sum(~defined);

[used, why] = psychophysics.Staircase.selectBalancedReversals_(asc, defined, options.NumReversals);
T.ReversalUsed  = used;
T.NumAscending  = sum(used & asc);
T.NumDescending = sum(used & ~asc);
T.NumReversals  = sum(used);

if strlength(why) > 0
    reasons(end+1) = why;
else
    T.ReversalMean = mean(v(used));
    T.ReversalStd  = std(v(used));
end

% ---- The threshold ---------------------------------------------------------
T.Valid = isempty(reasons);
if T.Valid
    T.Threshold = T.ReversalMean + T.Correction;
end

% ---- The target the caller meant -------------------------------------------
if isnan(options.ExpectedTarget)
    T.TargetMatchesExpected = true;
else
    T.TargetMatchesExpected = abs(T.TargetProbability - options.ExpectedTarget) <= options.TargetTolerance;
    if stepsOk && ~T.TargetMatchesExpected
        note = sprintf('The steps target psi = %.3f (r = %.3g), not the expected %.3f.', ...
            T.TargetProbability, T.StepRatio, options.ExpectedTarget);
        if abs((1 - T.TargetProbability) - options.ExpectedTarget) <= options.TargetTolerance
            note = sprintf(['%s The step after a yes and the step after a no look swapped: ' ...
                'exchanged, they would target %.3f.'], note, 1 - T.TargetProbability);
        end
        notes(end+1) = note + " The threshold is correct for the probability the steps target.";
    end
end

T.Message = strjoin([reasons notes], " ");
end

% =========================================================================
function mustBeCountOrInf(x)
% A positive whole number of reversals, or Inf for all of them.
if ~(x > 0 && (isinf(x) || x == fix(x)))
    error('psychophysics:Staircase:InvalidNumReversals', ...
        'NumReversals must be a positive integer or Inf.');
end
end

% =========================================================================
function mustBeProbabilityOrNaN(x)
% NaN (no assertion), or a probability strictly between 0 and 1.
if ~(isnan(x) || (x > 0 && x < 1))
    error('psychophysics:Staircase:InvalidExpectedTarget', ...
        'ExpectedTarget must be NaN or a probability strictly between 0 and 1.');
end
end
