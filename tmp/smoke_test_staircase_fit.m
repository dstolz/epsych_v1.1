% smoke_test_staircase_fit
% Standing proof for psychophysics.Staircase's psychometric fit:
% fitPsychometric, fitProportions, psychometricFunction, psychometricLevel.
%
% Headless -- no figure and no hardware. Run it
% after any change to the fit:
%
%   run(fullfile(epsychRoot,'tmp','smoke_test_staircase_fit.m'))
%
% The groups, and what each one is guarding:
%   1  function/inverse round trip for all three shapes and asymptotes
%   2  parameter recovery from counts, against known alpha and beta
%   3  the threshold criterion scales, including the 2AFC trap
%   4  every refusal, by its message
%   5  the identifiability flags: separation, flatness, wrong Direction
%   6  goodness-of-fit invariants
%   7  the bootstrap: reproducible, and it restores the global RNG
%   8  end to end from a simulated session, through epsych.BitMask codes
%   9  the forwarded option defaults in fitPsychometric have not drifted
%      away from fitProportions' own

repoRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(repoRoot);
if exist('epsych_startup','file') == 2
    epsych_startup;
end

nFail = 0;
nPass = 0;

fprintf('\n=== psychophysics.Staircase psychometric fit ===\n');

%% ---- 1. psychometricFunction / psychometricLevel round trip -------------
fprintf('\n-- 1. function and inverse --\n');
shapes = {"Logistic", -18, 0.55, -19; ...
          "Normal",   -18, 0.30, -19; ...
          "Weibull",   10, 2.00,   9};
for k = 1:size(shapes,1)
    shp = shapes{k,1}; a = shapes{k,2}; b = shapes{k,3}; x0 = shapes{k,4};
    for asym = [0 0; 0.5 0.02]'
        g = asym(1); lam = asym(2);
        P = psychophysics.Staircase.psychometricFunction(x0, a, b, ...
            Shape=shp, GuessRate=g, LapseRate=lam);
        x = psychophysics.Staircase.psychometricLevel(P, a, b, ...
            Shape=shp, GuessRate=g, LapseRate=lam);
        [nPass,nFail] = check(nPass, nFail, abs(x - x0) < 1e-9, ...
            sprintf('%s round trip (gamma=%.2g lambda=%.2g)', shp, g, lam));
    end
end

% The asymptotes are where they are claimed to be.
Plo = psychophysics.Staircase.psychometricFunction(-1e6, -18, 0.55, GuessRate=0.25, LapseRate=0.05);
Phi = psychophysics.Staircase.psychometricFunction( 1e6, -18, 0.55, GuessRate=0.25, LapseRate=0.05);
[nPass,nFail] = check(nPass, nFail, abs(Plo - 0.25) < 1e-12 && abs(Phi - 0.95) < 1e-12, ...
    'asymptotes are gamma and 1 - lambda');

% alpha is the midpoint between the asymptotes, whatever they are.
Pmid = psychophysics.Staircase.psychometricFunction(-18, -18, 0.55, GuessRate=0.25, LapseRate=0.05);
[nPass,nFail] = check(nPass, nFail, abs(Pmid - 0.6) < 1e-12, ...
    'alpha sits halfway between the asymptotes');

% A negative beta reverses Logistic and Normal.
Pup = psychophysics.Staircase.psychometricFunction([-25 -10], -18,  0.55);
Pdn = psychophysics.Staircase.psychometricFunction([-25 -10], -18, -0.55);
[nPass,nFail] = check(nPass, nFail, Pup(2) > Pup(1) && Pdn(2) < Pdn(1), ...
    'negative beta gives a decreasing function');

% Weibull is undefined below zero rather than complex.
Pneg = psychophysics.Staircase.psychometricFunction(-5, 10, 2, Shape="Weibull");
[nPass,nFail] = check(nPass, nFail, isnan(Pneg) && isreal(Pneg), ...
    'Weibull returns NaN, not a complex number, for x < 0');

% Unreachable targets have no level.
xNaN = psychophysics.Staircase.psychometricLevel(0.4, -18, 0.55, GuessRate=0.5);
[nPass,nFail] = check(nPass, nFail, isnan(xNaN), ...
    'a target below the guess rate inverts to NaN');

%% ---- 2. parameter recovery ----------------------------------------------
fprintf('\n-- 2. parameter recovery from counts --\n');
rng(20260910);
recovery = {"Logistic", -18, 0.55, 0.00, 0.00, -30:2.5:-7.5; ...
            "Normal",   -18, 0.30, 0.00, 0.00, -30:2.5:-7.5; ...
            "Weibull",   10, 2.00, 0.00, 0.00, [2 4 6 8 10 13 16 20 25]; ...
            "Logistic", -18, 0.55, 0.50, 0.00, -30:2.5:-7.5; ...
            "Logistic", -18, 0.55, 0.00, 0.03, -32:2.5:-4.5};
nPerLevel = 400;   % many trials per level, so one replicate is enough
for k = 1:size(recovery,1)
    shp = recovery{k,1}; a = recovery{k,2}; b = recovery{k,3};
    g = recovery{k,4}; lam = recovery{k,5}; lv = recovery{k,6};

    p  = psychophysics.Staircase.psychometricFunction(lv, a, b, ...
        Shape=shp, GuessRate=g, LapseRate=lam);
    ky = simulateCounts(p, nPerLevel);

    F = psychophysics.Staircase.fitProportions(lv, ky, repmat(nPerLevel,1,numel(lv)), ...
        Shape=shp, GuessRate=g, LapseRate=lam);

    ok = F.Converged && F.Identifiable && ...
        abs(F.Alpha - a) < 0.04*max(abs(a),1) && abs(F.Beta - b)/b < 0.10;
    [nPass,nFail] = check(nPass, nFail, ok, sprintf( ...
        '%s recovers alpha %.3f (%.3f) and beta %.4f (%.4f)', shp, F.Alpha, a, F.Beta, b));
end

% Decreasing direction, and the flag when Direction is wrong.
lv = -30:2.5:-7.5;
p  = psychophysics.Staircase.psychometricFunction(lv, -18, -0.55);
ky = simulateCounts(p, nPerLevel);
nT = repmat(nPerLevel,1,numel(lv));

Fdn = psychophysics.Staircase.fitProportions(lv, ky, nT, Direction="decreasing");
[nPass,nFail] = check(nPass, nFail, ...
    Fdn.Identifiable && abs(Fdn.Alpha + 18) < 1 && abs(Fdn.Beta + 0.55) < 0.06, ...
    sprintf('Direction="decreasing" recovers alpha %.3f, beta %.4f', Fdn.Alpha, Fdn.Beta));

Fup = psychophysics.Staircase.fitProportions(lv, ky, nT, Direction="increasing");
[nPass,nFail] = check(nPass, nFail, ~Fup.Identifiable && contains(Fup.Message,'runs against Direction'), ...
    'the same data with the wrong Direction is flagged, and says so');

%% ---- 3. threshold criterion ---------------------------------------------
fprintf('\n-- 3. threshold criterion --\n');
lv = -30:2.5:-7.5; nT = repmat(400,1,numel(lv));
ky = simulateCounts(psychophysics.Staircase.psychometricFunction(lv,-18,0.55), 400);

F = psychophysics.Staircase.fitProportions(lv, ky, nT);
[nPass,nFail] = check(nPass, nFail, abs(F.Threshold - F.Alpha) < 1e-9, ...
    'relative 0.5 is alpha exactly');

kyG = simulateCounts(psychophysics.Staircase.psychometricFunction(lv,-18,0.55,GuessRate=0.5), 400);
Frel = psychophysics.Staircase.fitProportions(lv, kyG, nT, GuessRate=0.5, ...
    ThresholdCriterion=0.5, CriterionScale="relative");
Fabs = psychophysics.Staircase.fitProportions(lv, kyG, nT, GuessRate=0.5, ...
    ThresholdCriterion=0.5, CriterionScale="absolute");
F75  = psychophysics.Staircase.fitProportions(lv, kyG, nT, GuessRate=0.5, ...
    ThresholdCriterion=0.75, CriterionScale="absolute");

[nPass,nFail] = check(nPass, nFail, abs(Frel.Threshold - Frel.Alpha) < 1e-9, ...
    '2AFC: relative 0.5 is still alpha');
[nPass,nFail] = check(nPass, nFail, isnan(Fabs.Threshold), ...
    '2AFC: absolute 0.5 is unreachable and returns NaN, not a number');
[nPass,nFail] = check(nPass, nFail, abs(F75.Threshold - F75.Alpha) < 1e-9, ...
    '2AFC: absolute 0.75 is alpha');

F707 = psychophysics.Staircase.fitProportions(lv, ky, nT, ...
    ThresholdCriterion=0.707, CriterionScale="absolute");
closedForm = F707.Alpha + log(0.707/0.293)/F707.Beta;
[nPass,nFail] = check(nPass, nFail, abs(F707.Threshold - closedForm) < 1e-9, ...
    'absolute 0.707 matches the closed-form logistic inverse');
[nPass,nFail] = check(nPass, nFail, abs(F707.ThresholdCriterionAbsolute - 0.707) < 1e-12, ...
    'ThresholdCriterionAbsolute reports the proportion actually used');

%% ---- 4. refusals ---------------------------------------------------------
fprintf('\n-- 4. refusals --\n');
refusals = { ...
    'two distinct',      psychophysics.Staircase.fitProportions(-18, 5, 10); ...
    'same outcome',      psychophysics.Staircase.fitProportions([-20 -18 -16],[10 10 10],[10 10 10]); ...
    'same outcome',      psychophysics.Staircase.fitProportions([-20 -18 -16],[0 0 0],[10 10 10]); ...
    'positive stimulus', psychophysics.Staircase.fitProportions([-5 0 5],[1 3 5],[6 6 6], Shape="Weibull"); ...
    'not supported',     psychophysics.Staircase.fitProportions([2 4 6],[1 3 5],[6 6 6], Shape="Weibull", Direction="decreasing"); ...
    'no range',          psychophysics.Staircase.fitProportions([-20 -18 -16],[1 3 5],[6 6 6], GuessRate=0.9, LapseRate=0.2)};
for k = 1:size(refusals,1)
    F = refusals{k,2};
    ok = ~F.Converged && ~F.Identifiable && isnan(F.Alpha) && ...
        contains(F.Message, refusals{k,1});
    [nPass,nFail] = check(nPass, nFail, ok, ...
        sprintf('refused with "%s": %s', refusals{k,1}, F.Message));
end

% A refusal still returns the full result struct, so no caller needs isfield.
Fref = refusals{1,2};
Fgood = psychophysics.Staircase.fitProportions(lv, ky, nT);
[nPass,nFail] = check(nPass, nFail, isequal(sort(fieldnames(Fref)), sort(fieldnames(Fgood))), ...
    'a refused fit has exactly the fields a successful one has');

% Malformed input is an error, not a refusal: it is a caller bug.
threw = false;
try
    psychophysics.Staircase.fitProportions([-20 -18],[5 12],[10 10]);
catch ME
    threw = strcmp(ME.identifier,'psychophysics:Staircase:FitCountsExceedTotal');
end
[nPass,nFail] = check(nPass, nFail, threw, 'numYes > numTotal throws rather than fitting');

%% ---- 5. identifiability --------------------------------------------------
fprintf('\n-- 5. identifiability --\n');
Fsep = psychophysics.Staircase.fitProportions([-25 -20 -15 -10],[0 0 6 6],[6 6 6 6]);
[nPass,nFail] = check(nPass, nFail, Fsep.Separated && ~Fsep.Identifiable, ...
    'complete separation is detected and the slope is not believed');

Fflat = psychophysics.Staircase.fitProportions([-20 -18 -16],[5 5 5],[10 10 10]);
[nPass,nFail] = check(nPass, nFail, ~Fflat.Identifiable && Fflat.ResponseRange < 0.05, ...
    'a flat dataset is flagged rather than given a slope');

Fok = psychophysics.Staircase.fitProportions([-24 -21 -18 -15 -12],[0 1 3 5 6],[6 6 6 6 6]);
[nPass,nFail] = check(nPass, nFail, Fok.Converged && Fok.Identifiable && ~Fok.Separated, ...
    'sparse but ordinary data is NOT flagged (6 trials at each of 5 levels)');

Fext = psychophysics.Staircase.fitProportions([-30 -28 -26],[1 1 2],[10 10 10]);
[nPass,nFail] = check(nPass, nFail, isfinite(Fext.Threshold) && ~Fext.ThresholdInRange, ...
    sprintf('a threshold outside the tested levels (%.2f) is reported as an extrapolation', Fext.Threshold));
[nPass,nFail] = check(nPass, nFail, Fok.ThresholdInRange, ...
    'a threshold inside the tested levels is not');

%% ---- 6. goodness of fit --------------------------------------------------
fprintf('\n-- 6. goodness of fit --\n');
F = psychophysics.Staircase.fitProportions(lv, ky, nT);
[nPass,nFail] = check(nPass, nFail, F.DevianceDF == F.NumLevels - 2, ...
    sprintf('deviance df is levels - parameters (%d)', F.DevianceDF));
[nPass,nFail] = check(nPass, nFail, F.Deviance >= -1e-9, 'deviance is nonnegative');
[nPass,nFail] = check(nPass, nFail, abs(F.AIC - (-2*F.LogLikelihood + 2*F.NumParameters)) < 1e-9, ...
    'AIC is -2LL + 2k');
[nPass,nFail] = check(nPass, nFail, F.DeviancePValue >= 0 && F.DeviancePValue <= 1, ...
    sprintf('deviance p-value is a probability (%.3f)', F.DeviancePValue));
[nPass,nFail] = check(nPass, nFail, F.NumTrials == sum(nT) && F.NumLevels == numel(lv), ...
    'the counts behind the fit are reported back');

Fsat = psychophysics.Staircase.fitProportions([-25 -10],[2 9],[10 10]);
[nPass,nFail] = check(nPass, nFail, abs(Fsat.Deviance) < 1e-4 && Fsat.DevianceDF == 0 && isnan(Fsat.DeviancePValue), ...
    'two levels and two parameters: deviance 0, no df, no p-value');

Flap = psychophysics.Staircase.fitProportions(lv, ky, nT, EstimateLapse=true);
[nPass,nFail] = check(nPass, nFail, Flap.NumParameters == 3 && Flap.DevianceDF == F.DevianceDF - 1 ...
    && Flap.LapseRate >= 0 && Flap.LapseRate <= 0.05, ...
    sprintf('EstimateLapse adds a parameter and stays in bounds (lambda=%.4f)', Flap.LapseRate));

%% ---- 7. bootstrap --------------------------------------------------------
fprintf('\n-- 7. bootstrap --\n');
Fb1 = psychophysics.Staircase.fitProportions(lv, ky, nT, Bootstrap=120, RandomSeed=7);
Fb2 = psychophysics.Staircase.fitProportions(lv, ky, nT, Bootstrap=120, RandomSeed=7);
[nPass,nFail] = check(nPass, nFail, isequaln(Fb1.CI.Alpha, Fb2.CI.Alpha) && isequaln(Fb1.CI.Beta, Fb2.CI.Beta), ...
    'RandomSeed makes the interval reproducible');
[nPass,nFail] = check(nPass, nFail, ...
    Fb1.CI.Alpha(1) < Fb1.Alpha && Fb1.Alpha < Fb1.CI.Alpha(2) && ...
    Fb1.CI.Beta(1)  < Fb1.Beta  && Fb1.Beta  < Fb1.CI.Beta(2), ...
    sprintf('the interval brackets the estimate (alpha [%.3f %.3f])', Fb1.CI.Alpha));
[nPass,nFail] = check(nPass, nFail, Fb1.CI.Replicates > 0.9*Fb1.CI.Requested, ...
    sprintf('%d of %d replicates produced an estimate', Fb1.CI.Replicates, Fb1.CI.Requested));

% A seeded bootstrap must not leave the session's random state moved: a trial
% selector may be drawing from it. binornd has no stream argument, so the fit
% seeds the global stream and puts it back -- this is what proves it does.
rng(4242);
rand();                             % advance it, so a stray reseed would show
stateBefore = rng;
psychophysics.Staircase.fitProportions(lv, ky, nT, Bootstrap=50, RandomSeed=1);
stateAfter = rng;
[nPass,nFail] = check(nPass, nFail, isequal(stateBefore.State, stateAfter.State), ...
    'a seeded bootstrap restores the global RNG stream exactly');

%% ---- 8. end to end from a session ---------------------------------------
fprintf('\n-- 8. from a simulated session --\n');
rng(31415);
TRUE_THR   = -18;
TRUE_SLOPE = 0.55;
DATA = simulateStaircaseSession(TRUE_THR, TRUE_SLOPE, 400);

S = psychophysics.Staircase(DATA, 'Depth', StaircaseDirection="Down");
F = S.fitPsychometric();

[nPass,nFail] = check(nPass, nFail, F.Converged && F.Identifiable, ...
    sprintf('a staircase session fits (%s)', ternary(F.Message == "", 'no message', char(F.Message))));
[nPass,nFail] = check(nPass, nFail, abs(F.Threshold - TRUE_THR) < 2, ...
    sprintf('fitted threshold %.2f is near the true %.2f', F.Threshold, TRUE_THR));
% They should be CLOSE but not equal: a 2-down-1-up track settles near the
% 70.7% point, log(0.707/0.293)/slope above alpha -- about 1.6 dB here.
[nPass,nFail] = check(nPass, nFail, abs(F.Alpha - S.Results.Threshold) < 4, ...
    sprintf('fit alpha (%.2f) and reversal mean (%.2f) agree to within a step or two', ...
    F.Alpha, S.Results.Threshold));

% Only stimulus trials, and aborts are out unless asked for.
nStim   = numel(S.Results.StimulusTrialIdx);
nAbort  = sum([DATA.TrialType] == 0 & bitget([DATA.RespCode], uint32(epsych.BitMask.Abort)) == 1);
[nPass,nFail] = check(nPass, nFail, F.NumScored == nStim - nAbort && F.NumAborted == nAbort, ...
    sprintf('%d stimulus trials scored, %d aborts left out', F.NumScored, F.NumAborted));

Fa = S.fitPsychometric(IncludeAborts=true);
[nPass,nFail] = check(nPass, nFail, Fa.NumScored == nStim && sum(Fa.NumTotal) == sum(F.NumTotal) + nAbort, ...
    'IncludeAborts counts them as failures to respond');
[nPass,nFail] = check(nPass, nFail, sum(Fa.NumYes) == sum(F.NumYes), ...
    'an included abort never becomes a yes');

% Catch trials are never in the counts, but can supply the lower asymptote.
Fc = S.fitPsychometric(GuessFromCatchTrials=true);
[nPass,nFail] = check(nPass, nFail, Fc.GuessRateSource == "catch" && Fc.GuessRate > 0 && Fc.GuessRate < 1, ...
    sprintf('the guess rate came from the catch trials (%.3f)', Fc.GuessRate));
[nPass,nFail] = check(nPass, nFail, isequal(Fc.NumTotal, F.NumTotal), ...
    'and the catch trials are still not in the counts');

% Exclusions and dB conversion are the staircase's, so the fit inherits them.
S.ExcludedTrials = 1:20;
Fx = S.fitPsychometric();
[nPass,nFail] = check(nPass, nFail, Fx.NumScored < F.NumScored, ...
    sprintf('ExcludedTrials reaches the fit (%d -> %d scored)', F.NumScored, Fx.NumScored));
S.ExcludedTrials = [];

% ConvertToDecibels: the fit must be in the units the plot is showing. Modulation
% depth is a proportion, so this session's levels are positive and convert.
HIT  = bitset(uint32(0), uint32(epsych.BitMask.Hit));
MISS = bitset(uint32(0), uint32(epsych.BitMask.Miss));
linLevels = [0.1 0.2 0.4 0.8];
DEPTH = struct('Depth',{},'RespCode',{},'TrialType',{});
for iLevel = 1:numel(linLevels)
    for iRep = 1:12
        rc = MISS;
        if iRep <= 3*iLevel, rc = HIT; end
        DEPTH(end+1) = struct('Depth',linLevels(iLevel),'RespCode',rc,'TrialType',0);
    end
end

Slin = psychophysics.Staircase(DEPTH, 'Depth');
Sdb  = psychophysics.Staircase(DEPTH, 'Depth', ConvertToDecibels=true);
Flin = Slin.fitPsychometric();
Fdb  = Sdb.fitPsychometric();

[nPass,nFail] = check(nPass, nFail, ...
    isequal(round(Flin.Levels,10), round(linLevels,10)) && ...
    isequal(round(Fdb.Levels,10),  round(20*log10(linLevels),10)) && ...
    isequal(Fdb.NumYes, Flin.NumYes), ...
    'ConvertToDecibels reaches the fit: the same counts, at 20*log10 of the levels');
[nPass,nFail] = check(nPass, nFail, Fdb.ConvertToDecibels && ~Flin.ConvertToDecibels, ...
    'and the fit says which units it is in');

% Nothing is written back onto the object.
resultsBefore = S.Results;
S.fitPsychometric();
[nPass,nFail] = check(nPass, nFail, isequaln(resultsBefore, S.Results), ...
    'fitPsychometric stores nothing on the staircase');

% A staircase with no trials answers, rather than throwing.
Sempty = psychophysics.Staircase(struct('Depth',{},'RespCode',{},'TrialType',{}), 'Depth');
Fempty = Sempty.fitPsychometric();
[nPass,nFail] = check(nPass, nFail, ~Fempty.Converged && contains(Fempty.Message,'no trials'), ...
    'an empty staircase returns a refusal, not an error');

delete(S); delete(Sdb); delete(Slin); delete(Sempty);

%% ---- 9. the forwarded defaults have not drifted -------------------------
fprintf('\n-- 9. option defaults --\n');
[shared, mismatched] = compareArgumentDefaults( ...
    fullfile(repoRoot,'obj','+psychophysics','@Staircase','fitProportions.m'), ...
    fullfile(repoRoot,'obj','+psychophysics','@Staircase','fitPsychometric.m'));
[nPass,nFail] = check(nPass, nFail, isempty(mismatched), sprintf( ...
    'fitPsychometric forwards %d options with fitProportions'' own defaults%s', ...
    numel(shared), ternary(isempty(mismatched), '', [' -- drifted: ' strjoin(mismatched,', ')])));
[nPass,nFail] = check(nPass, nFail, numel(shared) >= 15, ...
    sprintf('%d forwarded options were actually compared', numel(shared)));

%% ---- summary -------------------------------------------------------------
fprintf('\n=== %d passed, %d failed ===\n\n', nPass, nFail);
if nFail > 0
    error('smoke_test_staircase_fit:Failed','%d check(s) failed.', nFail);
end


%% =========================================================================
function [nPass, nFail] = check(nPass, nFail, condition, description)
% Report and tally one check.
if condition
    nPass = nPass + 1;
    fprintf('  PASS  %s\n', description);
else
    nFail = nFail + 1;
    fprintf('  FAIL  %s\n', description);
end
end

%% =========================================================================
function ky = simulateCounts(p, nPerLevel)
% Binomial draws, the same sampler the bootstrap uses.
ky = binornd(nPerLevel, p);        % scalar N broadcasts against the rates
end

%% =========================================================================
function DATA = simulateStaircaseSession(trueThreshold, trueSlope, nTrials)
% A 2-down-1-up track in dB with catch trials and the occasional abort,
% coded exactly as a paradigm's saving function would code it.
HIT   = bitset(uint32(0), uint32(epsych.BitMask.Hit));
MISS  = bitset(uint32(0), uint32(epsych.BitMask.Miss));
CR    = bitset(uint32(0), uint32(epsych.BitMask.CorrectReject));
FA    = bitset(uint32(0), uint32(epsych.BitMask.FalseAlarm));
ABORT = bitset(uint32(0), uint32(epsych.BitMask.Abort));

depth    = -6;
hitRun   = 0;
stepDown = 2;
stepUp   = 2;    % symmetric, so the track settles at the standard 70.7% point

DATA = struct('Depth',{},'RespCode',{},'TrialType',{});
for k = 1:nTrials
    if mod(k,6) == 0                       % catch trial: ~20% false alarms
        rc = CR;
        if rand < 0.2, rc = FA; end
        DATA(end+1) = struct('Depth',depth,'RespCode',rc,'TrialType',1);
        continue
    end

    if rand < 0.04                         % abort: no answer, no step
        DATA(end+1) = struct('Depth',depth,'RespCode',ABORT,'TrialType',0);
        continue
    end

    pHit = 1 ./ (1 + exp(-trueSlope*(depth - trueThreshold)));
    if rand < pHit
        DATA(end+1) = struct('Depth',depth,'RespCode',HIT,'TrialType',0);
        hitRun = hitRun + 1;
        if hitRun >= 2
            depth = max(-34, depth - stepDown);
            hitRun = 0;
        end
    else
        DATA(end+1) = struct('Depth',depth,'RespCode',MISS,'TrialType',0);
        hitRun = 0;
        depth = min(-2, depth + stepUp);
    end
end
end

%% =========================================================================
function [shared, mismatched] = compareArgumentDefaults(fileA, fileB)
% Parse both arguments blocks and compare the default of every option they
% share. MATLAB cannot inherit an arguments block, so fitPsychometric repeats
% fitProportions' declarations; this is what notices when one is edited alone.
A = parseArgumentDefaults(fileA);
B = parseArgumentDefaults(fileB);

shared = intersect(fieldnames(A), fieldnames(B));
mismatched = {};
for k = 1:numel(shared)
    name = shared{k};
    if ~strcmp(A.(name), B.(name))
        mismatched{end+1} = sprintf('%s (%s vs %s)', name, A.(name), B.(name));
    end
end
end

%% =========================================================================
function D = parseArgumentDefaults(file)
% name -> default expression, for every "options.Name ... = default" line in
% the file's first arguments block.
txt = fileread(file);
block = regexp(txt, '\n\s*arguments\s*\n(.*?)\n\s*end\s*\n', 'tokens', 'once');
D = struct();
if isempty(block), return; end

lines = strsplit(block{1}, newline);
for k = 1:numel(lines)
    tok = regexp(strtrim(lines{k}), '^options\.(\w+).*?=\s*(.+?)\s*$', 'tokens', 'once');
    if isempty(tok), continue; end
    D.(tok{1}) = tok{2};
end
end

%% =========================================================================
function out = ternary(condition, a, b)
if condition, out = a; else, out = b; end
end
