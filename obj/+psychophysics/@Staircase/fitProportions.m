function F = fitProportions(levels, numYes, numTotal, options)
% F = psychophysics.Staircase.fitProportions(levels, numYes, numTotal)
% F = psychophysics.Staircase.fitProportions(..., Shape="Weibull")
% F = psychophysics.Staircase.fitProportions(..., Bootstrap=1000)
% Maximum-likelihood psychometric fit from per-level response counts.
%
% Fits P(x) = gamma + (1 - gamma - lambda)*F(x; alpha, beta) to binomial
% counts by maximizing the likelihood with fminsearch (Nelder-Mead, core
% MATLAB -- no Optimization, Curve Fitting, or Statistics Toolbox is used
% anywhere in this file). The shapes and their parameterization are
% psychophysics.Staircase.psychometricFunction's.
%
% Counts in, so it is pure: psychophysics.Staircase.fitPsychometric turns a
% session into (levels, numYes, numTotal) and calls this, and so can anything
% else with proportions to fit. That split is what makes the estimator
% testable against known parameters with no DATA, no runtime, and no figure.
%
% WHAT IT REFUSES TO FIT
% An unfittable dataset returns a result whose Converged or Identifiable
% field is false and whose Message says why, rather than a plausible-looking
% number. Four situations are refused outright, before any optimization:
% fewer than two distinct levels; every scored trial with the same outcome
% (alpha runs to +/-Inf); a Weibull with a nonpositive level or a decreasing
% Direction; and asymptotes leaving the function no span. Two more are
% fitted and then flagged Identifiable = false: COMPLETE SEPARATION, where
% every "no" level lies below every "yes" level so the slope is unbounded,
% and a fit whose curve varies by less than MinResponseRange across the
% levels actually tested, which is what a flat or backwards dataset produces.
% Both are exact tests on the data, not thresholds on the estimate.
%
% THE THRESHOLD CRITERION IS A CHOICE, so it is named. ThresholdCriterion is
% read on the BETWEEN-ASYMPTOTE scale by default (CriterionScale="relative"):
% 0.5 means halfway from gamma to 1 - lambda, which is alpha itself for the
% Logistic and Normal shapes whatever the asymptotes are, and is always
% reachable. CriterionScale="absolute" reads it as a raw response
% proportion instead -- "the 70.7% level" -- and returns NaN when that
% proportion lies outside the asymptotes rather than extrapolating to it.
% F.ThresholdCriterionAbsolute always reports the absolute proportion used.
%
% UNCERTAINTY is a parametric bootstrap (Wichmann & Hill 2001) and is off by
% default because it costs Bootstrap complete refits. It resamples binomial
% counts from the fitted curve at the observed levels and refits, so it
% conditions on the levels the session happened to run: on adaptive data
% those levels are themselves a response to the subject, and the interval
% does not carry that. No Hessian-based standard error is offered, because
% its asymptotic assumptions are the ones adaptive sampling breaks.
%
% Parameters:
%   levels             - Stimulus levels, one per tested level.
%   numYes             - Responses counted as "yes" at each level.
%   numTotal           - Scored trials at each level; numYes <= numTotal.
%   Shape              - "Logistic" (default), "Normal", or "Weibull".
%   Direction          - "increasing" (default) or "decreasing", for a
%                        parameter where a HIGHER level means WORSE
%                        performance (a masker level, say). Fitted as a
%                        negative beta; Weibull cannot be decreasing.
%   GuessRate          - Fixed lower asymptote gamma (default 0).
%   LapseRate          - Fixed upper asymptote offset lambda (default 0);
%                        ignored when EstimateLapse is true.
%   EstimateLapse      - Fit lambda as a third free parameter (default false).
%   MaxLapse           - Upper bound on a fitted lambda (default 0.05).
%   ThresholdCriterion - Proportion the threshold is read at (default 0.5).
%   CriterionScale     - "relative" (default) or "absolute"; see above.
%   StartAlpha         - An ADDITIONAL starting value for the optimizer, tried
%                        alongside the data-derived one; the highest
%                        likelihood wins. NaN (default) to use only the
%                        data-derived start.
%   StartBeta          - The same, for the slope. NaN (default) to derive.
%   Bootstrap          - Parametric bootstrap replicates (default 0 = none).
%   ConfidenceLevel    - Bootstrap interval coverage (default 0.95).
%   RandomSeed         - Seed for a private RNG stream, so a bootstrap is
%                        reproducible. [] (default) uses the global stream;
%                        nothing here ever reseeds it.
%   CurvePoints        - Samples in F.Curve (default 200); 0 to skip it.
%   MinResponseRange   - Smallest change in the fitted curve across the
%                        tested levels that counts as identifiable
%                        (default 0.05).
%   MaxIterations      - fminsearch iteration and evaluation cap (default 2000).
%   Quiet              - Suppress the per-fit log messages (default false).
%                        The bootstrap sets it on its own replicates: a
%                        thousand refits of resampled counts would otherwise
%                        write a thousand records about resampled counts.
%
% Returns:
%   F - Fit result struct; see documentation/psychophysics/psychophysics_StaircaseFit.md
%       for every field. The ones to read first are Alpha, Beta, Threshold,
%       Converged, Identifiable, and Message.
%
% Example:
%   F = psychophysics.Staircase.fitProportions( ...
%           [-30 -25 -20 -15 -10], [1 4 11 17 19], [20 20 20 20 20]);
%   fprintf('threshold %.2f  slope %.3f\n', F.Threshold, F.Beta);
%
% See also psychophysics.Staircase.fitPsychometric,
% psychophysics.Staircase.psychometricFunction, psychophysics.BestPEST,
% documentation/psychophysics/psychophysics_StaircaseFit.md

arguments
    levels {mustBeNumeric, mustBeReal}
    numYes {mustBeNumeric, mustBeReal, mustBeNonnegative, mustBeInteger}
    numTotal {mustBeNumeric, mustBeReal, mustBeNonnegative, mustBeInteger}
    options.Shape (1,1) string {mustBeMember(options.Shape,["Logistic","Normal","Weibull"])} = "Logistic"
    options.Direction (1,1) string {mustBeMember(options.Direction,["increasing","decreasing"])} = "increasing"
    options.GuessRate (1,1) double {mustBeInRange(options.GuessRate,0,1)} = 0
    options.LapseRate (1,1) double {mustBeInRange(options.LapseRate,0,1)} = 0
    options.EstimateLapse (1,1) logical = false
    options.MaxLapse (1,1) double {mustBeInRange(options.MaxLapse,0,1,"exclusive")} = 0.05
    options.ThresholdCriterion (1,1) double {mustBeInRange(options.ThresholdCriterion,0,1,"exclusive")} = 0.5
    options.CriterionScale (1,1) string {mustBeMember(options.CriterionScale,["relative","absolute"])} = "relative"
    options.StartAlpha (1,1) double = NaN
    options.StartBeta (1,1) double = NaN
    options.Bootstrap (1,1) double {mustBeNonnegative, mustBeInteger} = 0
    options.ConfidenceLevel (1,1) double {mustBeInRange(options.ConfidenceLevel,0,1,"exclusive")} = 0.95
    options.RandomSeed = []
    options.CurvePoints (1,1) double {mustBeNonnegative, mustBeInteger} = 200
    options.MinResponseRange (1,1) double {mustBeInRange(options.MinResponseRange,0,1)} = 0.05
    options.MaxIterations (1,1) double {mustBePositive, mustBeInteger} = 2000
    options.Quiet (1,1) logical = false
end

F = psychophysics.Staircase.emptyFit_();
F.Shape     = options.Shape;
F.Direction = options.Direction;

% ---- Input shape ---------------------------------------------------------
% Rows or columns, but never a matrix reshaped into one behind the caller's
% back: three vectors of counts is the only thing this function can mean.
if ~isvector(levels) || ~isvector(numYes) || ~isvector(numTotal)
    error('psychophysics:Staircase:FitNotVectors', ...
        'levels, numYes and numTotal must each be a vector.');
end
levels   = reshape(double(levels),   1, []);
numYes   = reshape(double(numYes),   1, []);
numTotal = reshape(double(numTotal), 1, []);

if numel(levels) ~= numel(numYes) || numel(levels) ~= numel(numTotal)
    error('psychophysics:Staircase:FitSizeMismatch', ...
        'levels, numYes and numTotal must have the same number of elements.');
end
if any(numYes > numTotal)
    error('psychophysics:Staircase:FitCountsExceedTotal', ...
        'numYes cannot exceed numTotal at any level.');
end

% A level with no scored trials carries no information and would divide by
% zero in the saturated likelihood; dropping it is not a judgement call.
keep = numTotal > 0 & isfinite(levels) & isfinite(numYes) & isfinite(numTotal);
levels   = levels(keep);
numYes   = numYes(keep);
numTotal = numTotal(keep);

[levels, order] = sort(levels);
numYes   = numYes(order);
numTotal = numTotal(order);

F.Levels     = levels;
F.NumYes     = numYes;
F.NumTotal   = numTotal;
F.Proportion = psychophysics.Metrics.rate(numYes, numTotal);
F.NumLevels  = numel(levels);
F.NumTrials  = sum(numTotal);

gamma   = options.GuessRate;
lambda  = options.LapseRate;
lambda0 = options.LapseRate;              % the optimizer's starting lapse
if options.EstimateLapse
    lambda0 = min(0.02, options.MaxLapse/2);
end
F.GuessRate      = gamma;
F.LapseRate      = lambda;
F.LapseEstimated = options.EstimateLapse;

% ---- Refusals ------------------------------------------------------------
% Each is an exact statement about the data rather than a tolerance, and each
% describes a likelihood with no interior maximum.
if options.EstimateLapse
    largestLapse = options.MaxLapse;
else
    largestLapse = lambda;
end
if 1 - gamma - largestLapse <= 0
    F.Message = "GuessRate and LapseRate leave no range for the function to span.";
    vprintf(0, 1, char(F.Message));
    return
end

if numel(unique(levels)) < 2
    F.Message = "A psychometric fit needs at least two distinct stimulus levels.";
    return
end

if sum(numYes) == 0 || sum(numYes) == sum(numTotal)
    F.Message = "Every scored trial had the same outcome; the location parameter is unbounded.";
    return
end

if options.Shape == "Weibull" && any(levels <= 0)
    F.Message = "The Weibull shape is defined for positive stimulus levels only.";
    return
end

if options.Shape == "Weibull" && options.Direction == "decreasing"
    F.Message = "Direction=""decreasing"" is not supported for the Weibull shape.";
    return
end

% ---- Fit -----------------------------------------------------------------
cfg = struct( ...
    'levels',        levels, ...
    'numYes',        numYes, ...
    'numTotal',      numTotal, ...
    'shape',         options.Shape, ...
    'gamma',         gamma, ...
    'sign',          1 - 2*(options.Direction == "decreasing"), ...
    'estimateLapse', options.EstimateLapse, ...
    'lapseFixed',    options.LapseRate, ...
    'maxLapse',      options.MaxLapse);

nFree = 2 + double(options.EstimateLapse);
F.NumParameters = nFree;

[alpha0, beta0] = startValues_(cfg, lambda0);

% The lapse transform lambda = maxLapse/(1 + exp(-v)) keeps it inside its
% bounds without a constrained solver; v0 places the start at lambda above.
v0 = 0;
if options.EstimateLapse
    v0 = log(lambda0 / (options.MaxLapse - lambda0));
end

% Nelder-Mead finds a local optimum, and a psychometric likelihood is flat in
% the slope when the levels are sparse, so the slope is started from several
% magnitudes and the best likelihood wins. A caller's StartAlpha/StartBeta --
% a staircase's own reversal threshold, say -- is an ADDITIONAL start rather
% than a replacement, so prior information can only improve the optimum, and
% is dropped when it is not usable for the shape.
alphaStarts = alpha0;
if isfinite(options.StartAlpha) && (options.Shape ~= "Weibull" || options.StartAlpha > 0)
    alphaStarts = [alphaStarts options.StartAlpha];
end
betaStarts = beta0 .* [0.25 1 4];
if isfinite(options.StartBeta) && options.StartBeta > 0
    betaStarts = [betaStarts options.StartBeta];
end

opts = optimset('Display','off', ...
    'MaxIter', options.MaxIterations, 'MaxFunEvals', options.MaxIterations, ...
    'TolX', 1e-8, 'TolFun', 1e-10);

bestU = []; bestF = Inf; bestFlag = 0;
for a = alphaStarts
    for b = betaStarts
        % Only as many dimensions as there are free parameters: a fixed
        % lapse leaves the likelihood flat along a third one, and a simplex
        % has no business searching a direction that cannot change anything.
        u0 = [locate_(a, cfg.shape), log(b)];
        if options.EstimateLapse
            u0(3) = v0;
        end
        [u, fv, ef] = fminsearch(@(uu) negLogLik_(uu, cfg), u0, opts);
        if fv < bestF
            bestF    = fv;
            bestU    = u;
            bestFlag = ef;
        end
    end
end

if isempty(bestU)
    F.Message = "The optimizer produced no usable estimate.";
    return
end

% One restart from the winner: a Nelder-Mead simplex collapses onto its
% solution, and rebuilding it there is the standard way to confirm it.
[u, fval, exitflag] = fminsearch(@(uu) negLogLik_(uu, cfg), bestU, opts);
if fval > bestF
    u        = bestU;
    fval     = bestF;
    exitflag = bestFlag;
end

[alpha, beta, lambda] = unpackParams_(u, cfg);
F.Alpha          = alpha;
F.Beta           = beta;
F.LapseRate      = lambda;
F.Converged      = exitflag == 1 && isfinite(fval) && fval < realmax;
F.NegLogLik      = fval;

if ~isfinite(alpha) || ~isfinite(beta)
    F.Message = "The optimizer left the parameter space; no estimate was produced.";
    F.Converged = false;
    return
end

pfArgs = {'Shape', options.Shape, 'GuessRate', gamma, 'LapseRate', lambda};

% ---- Threshold -----------------------------------------------------------
if options.CriterionScale == "relative"
    critAbs = gamma + (1 - gamma - lambda)*options.ThresholdCriterion;
else
    critAbs = options.ThresholdCriterion;
end
F.ThresholdCriterionAbsolute = critAbs;
F.Threshold = psychophysics.Staircase.psychometricLevel(critAbs, alpha, beta, pfArgs{:});

F.ThresholdInRange = isfinite(F.Threshold) && ...
    F.Threshold >= min(levels) && F.Threshold <= max(levels);
if isfinite(F.Threshold) && ~F.ThresholdInRange && ~options.Quiet
    vprintf(1, 'Psychometric fit: threshold %.4g lies outside the tested levels [%.4g %.4g]; it is an extrapolation.', ...
        F.Threshold, min(levels), max(levels));
end

% ---- Identifiability -----------------------------------------------------
% Complete separation: every level with a "no" below (or above, going the
% other way) every level with a "yes". The likelihood then rises without
% bound as the slope steepens, so whatever the optimizer stopped at is an
% artifact of where it ran out of iterations.
levNo  = levels(numTotal - numYes > 0);
levYes = levels(numYes > 0);
if ~isempty(levNo) && ~isempty(levYes)
    if cfg.sign > 0
        F.Separated = max(levNo) < min(levYes);
    else
        F.Separated = min(levNo) > max(levYes);
    end
end

pAtLevels = psychophysics.Staircase.psychometricFunction(levels, alpha, beta, pfArgs{:});
F.ResponseRange = max(pAtLevels) - min(pAtLevels);

if F.Separated
    F.Identifiable = false;
    F.Message = "The responses separate completely at one level, so the slope is unbounded; treat the estimate as a lower bound on steepness.";
elseif F.ResponseRange < options.MinResponseRange
    F.Identifiable = false;
    if trendSign_(levels, numYes, numTotal) * cfg.sign < 0
        F.Message = "The observed proportion runs against Direction=""" + options.Direction + """; refit with the other Direction.";
    else
        F.Message = "The fitted function varies by less than MinResponseRange across the tested levels; these data do not determine a slope.";
    end
else
    F.Identifiable = true;
end

if strlength(F.Message) > 0 && ~options.Quiet
    vprintf(1, char("Psychometric fit: " + F.Message));
end

% ---- Goodness of fit -----------------------------------------------------
% Reported without the binomial coefficients, which do not depend on the
% parameters; the deviance differences them out either way.
pFit = min(max(pAtLevels, eps), 1 - eps);
pSat = min(max(F.Proportion, eps), 1 - eps);
F.LogLikelihood = sum(numYes.*log(pFit) + (numTotal - numYes).*log(1 - pFit));
llSat           = sum(numYes.*log(pSat) + (numTotal - numYes).*log(1 - pSat));

F.Deviance   = 2*(llSat - F.LogLikelihood);
F.DevianceDF = F.NumLevels - nFree;
if F.DevianceDF > 0
    % chi2cdf(D,df) == gammainc(D/2, df/2); gammainc is core MATLAB, so this
    % costs no Statistics Toolbox licence.
    F.DeviancePValue = 1 - gammainc(F.Deviance/2, F.DevianceDF/2);
end
F.AIC = -2*F.LogLikelihood + 2*nFree;

% ---- Curve ---------------------------------------------------------------
if options.CurvePoints > 1
    F.Curve.x = linspace(min(levels), max(levels), options.CurvePoints);
    F.Curve.P = psychophysics.Staircase.psychometricFunction(F.Curve.x, alpha, beta, pfArgs{:});
end

% ---- Parametric bootstrap ------------------------------------------------
if options.Bootstrap > 0
    F.CI = bootstrapCI_(F, options, pFit);
end
end

% =========================================================================
function nll = negLogLik_(u, cfg)
% Binomial negative log-likelihood at the transformed parameters in u.
[alpha, beta, lambda] = unpackParams_(u, cfg);

if ~isfinite(alpha) || ~isfinite(beta) || beta == 0
    nll = realmax;
    return
end

p = psychophysics.Staircase.psychometricFunction(cfg.levels, alpha, beta, ...
    'Shape', cfg.shape, 'GuessRate', cfg.gamma, 'LapseRate', lambda);

% Tested BEFORE the clamp: MATLAB's min and max drop NaN, so clamping first
% would turn an undefined probability into eps and make this check dead.
if any(~isfinite(p))
    nll = realmax;
    return
end

% Clamped so a saturated cell gives a large finite penalty rather than an Inf
% the simplex cannot order against its neighbours.
p = min(max(p, eps), 1 - eps);

nll = -sum(cfg.numYes.*log(p) + (cfg.numTotal - cfg.numYes).*log(1 - p));

if ~isfinite(nll)
    nll = realmax;
end
end

% =========================================================================
function [alpha, beta, lambda] = unpackParams_(u, cfg)
% Natural parameters from the unconstrained vector the optimizer works in.
% alpha is fitted in log units for Weibull (where it must stay positive),
% the slope magnitude always in log units, and the lapse on a logistic
% transform of its bound -- so every point the simplex visits is legal.
if cfg.shape == "Weibull"
    alpha = exp(u(1));
else
    alpha = u(1);
end

beta = cfg.sign * exp(u(2));

if cfg.estimateLapse
    lambda = cfg.maxLapse / (1 + exp(-u(3)));
else
    lambda = cfg.lapseFixed;
end
end

% =========================================================================
function a = locate_(alpha, shape)
% The optimizer's coordinate for a natural alpha.
if shape == "Weibull"
    a = log(max(alpha, eps));
else
    a = alpha;
end
end

% =========================================================================
function [alpha0, beta0] = startValues_(cfg, lambda)
% Data-derived starting values.
%
% alpha0 interpolates where the observed proportion crosses the middle of
% the asymptotes, and beta0 comes from a weighted least-squares fit of the
% transform that linearizes the shape. Both fall back to a range-based guess
% when the data are too sparse for them, which is why the caller still runs a
% multi-start over the slope.
levels   = cfg.levels;
numTotal = cfg.numTotal;
span     = 1 - cfg.gamma - lambda;

p  = cfg.numYes ./ numTotal;
pn = (p - cfg.gamma) ./ span;      % on the base-CDF scale

spread = max(levels) - min(levels);
if spread <= 0
    spread = max(abs(levels(1)), 1);
end

% --- alpha0
alpha0 = NaN;
for k = 1:numel(levels)-1
    lo = pn(k); hi = pn(k+1);
    if ~isfinite(lo) || ~isfinite(hi) || lo == hi
        continue
    end
    if (lo - 0.5)*(hi - 0.5) <= 0
        alpha0 = levels(k) + (0.5 - lo)*(levels(k+1) - levels(k))/(hi - lo);
        break
    end
end
if ~isfinite(alpha0) || (cfg.shape == "Weibull" && alpha0 <= 0)
    alpha0 = sum(levels.*numTotal)/sum(numTotal);
end
if cfg.shape == "Weibull" && alpha0 <= 0
    alpha0 = median(levels);
end

% --- beta0
ok = pn > 0 & pn < 1;
beta0 = NaN;
if sum(ok) >= 2
    switch cfg.shape
        case "Logistic"
            y = log(pn(ok) ./ (1 - pn(ok)));
        case "Normal"
            y = psychophysics.Metrics.z(pn(ok));
        case "Weibull"
            y = log(-log(1 - pn(ok)));
    end

    if cfg.shape == "Weibull"
        x = log(levels(ok));
    else
        x = levels(ok);
    end

    if max(x) > min(x) && all(isfinite(y))
        w = sqrt(numTotal(ok))';           % weight each level by its trials
        X = [x(:) ones(numel(x),1)] .* w;
        c = X \ (y(:) .* w);
        beta0 = cfg.sign * c(1);           % magnitude; the sign is cfg.sign's
    end
end
if ~isfinite(beta0) || beta0 <= 0
    if cfg.shape == "Weibull"
        beta0 = 2;
    else
        % Traverses 0.1 -> 0.9 across half the tested range.
        beta0 = 2*log(9)/spread;
    end
end
end

% =========================================================================
function s = trendSign_(levels, numYes, numTotal)
% Sign of the weighted least-squares slope of proportion on level; says which
% way the data actually run when a fit comes out flat.
p = numYes ./ numTotal;
w = sqrt(numTotal)';
X = [levels(:) ones(numel(levels),1)] .* w;
c = X \ (p(:) .* w);
s = sign(c(1));
if ~isfinite(s) || s == 0
    s = 1;
end
end

% =========================================================================
function CI = bootstrapCI_(F, options, pFit)
% Parametric bootstrap: resample binomial counts from the fitted curve at the
% observed levels, refit, and take percentiles of the replicate estimates.
if isempty(options.RandomSeed)
    stream = RandStream.getGlobalStream;
else
    % A private stream rather than rng(seed): a fit must not silently move a
    % session's global random state, which a trial selector may be drawing from.
    stream = RandStream('twister', 'Seed', options.RandomSeed);
end

n = options.Bootstrap;
alphaB = nan(1, n);
betaB  = nan(1, n);
thrB   = nan(1, n);

passThrough = {'Shape', options.Shape, 'Direction', options.Direction, ...
    'GuessRate', options.GuessRate, 'LapseRate', options.LapseRate, ...
    'EstimateLapse', options.EstimateLapse, 'MaxLapse', options.MaxLapse, ...
    'ThresholdCriterion', options.ThresholdCriterion, ...
    'CriterionScale', options.CriterionScale, ...
    'StartAlpha', F.Alpha, 'StartBeta', abs(F.Beta), ...
    'MinResponseRange', options.MinResponseRange, ...
    'MaxIterations', options.MaxIterations, ...
    'CurvePoints', 0, 'Bootstrap', 0, 'Quiet', true};

for k = 1:n
    kb = zeros(1, F.NumLevels);
    for j = 1:F.NumLevels
        % rand(stream,...) rather than binornd: no Statistics Toolbox, and
        % the counts here are small enough that it costs nothing.
        kb(j) = sum(rand(stream, 1, F.NumTotal(j)) < pFit(j));
    end

    Fb = psychophysics.Staircase.fitProportions(F.Levels, kb, F.NumTotal, passThrough{:});
    if ~Fb.Converged
        continue
    end

    alphaB(k) = Fb.Alpha;
    betaB(k)  = Fb.Beta;
    thrB(k)   = Fb.Threshold;
end

pct = 100*[(1 - options.ConfidenceLevel)/2, (1 + options.ConfidenceLevel)/2];

CI.Level      = options.ConfidenceLevel;
CI.Requested  = n;
CI.Replicates = sum(isfinite(alphaB));
CI.Alpha      = percentile_(alphaB, pct);
CI.Beta       = percentile_(betaB,  pct);
CI.Threshold  = percentile_(thrB,   pct);

if CI.Replicates < n
    vprintf(1, 'Psychometric fit: %d of %d bootstrap replicates produced no estimate and were dropped.', ...
        n - CI.Replicates, n);
end
end

% =========================================================================
function q = percentile_(v, pct)
% Percentiles by linear interpolation of the order statistics -- the same
% definition prctile uses, without the Statistics Toolbox.
v = sort(v(isfinite(v)));
n = numel(v);

if n == 0
    q = nan(size(pct));
    return
end
if n == 1
    q = repmat(v, size(pct));
    return
end

pos = 100*((1:n) - 0.5)/n;
q = interp1(pos, v, pct, 'linear');
q(pct < pos(1))   = v(1);
q(pct > pos(end)) = v(end);
end
