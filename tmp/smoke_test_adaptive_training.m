function smoke_test_adaptive_training()
% smoke_test_adaptive_training()
% Exercise gui.AdaptiveTraining: the four value spaces its steps can be
% taken in, the calibration that makes them interchangeable at the reference,
% the reject-on-violation edits, and the window itself.
%
% The step rule is a pure static (gui.AdaptiveTraining.stepValue), so most of
% this runs with no figure at all; the last group builds the window over an
% hw.Software parameter to prove the widgets still wire up.
%
%   matlab -batch "run('tmp/smoke_test_adaptive_training.m')"

here = fileparts(mfilename('fullpath'));
run(fullfile(here,'..','epsych_startup.m'));
addpath(here);   % AdaptiveTrainingTestHost lives beside this test

% The window remembers whether Advanced was left open, and group 7 opens it.
% Restore whatever this rig had, or running the test would change the
% operator's window.
restorePrefs = guardPreferences("AdaptiveTraining", {"ShowAdvanced","Position"});   % group 11 opens real windows

step = @gui.AdaptiveTraining.stepValue;


% 1. Linear stepping is unchanged -----------------------------------------
assert(step(100,"up",StepUp=25) == 125, 'up adds StepUp');
assert(step(100,"down",StepDown=40) == 60, 'down subtracts StepDown');
assert(step(100,"up",StepUp=25,MaxValue=110) == 110, 'the step clamps at MaxValue');
assert(step(100,"down",StepDown=25,MinValue=90) == 90, 'the step clamps at MinValue');

[~,info] = step(100,"up",StepUp=25,MaxValue=110);
assert(info.Clamped, 'a clamped step says so');
assert(info.Delta == 10, 'Delta is what actually happened, not what was asked');
assert(info.Direction == 1, 'direction is reported for the plot');

fprintf('PASS: linear stepping and clamping\n');


% 2. Every space equals a linear step AT the reference ---------------------
% This is the property that lets an operator change space without rescaling
% a ladder that already works: at the reference the local slope matches.
ref = 400;
lin = step(ref,"up",StepUp=100);

logv = step(ref,"up",StepUp=100,ScaleType="logarithmic",ScaleReference=ref);
powv = step(ref,"up",StepUp=100,ScaleType="power",ScaleExponent=0.5,ScaleReference=ref);

% A quarter-of-the-reference step is a big one, so second-order curvature is
% visible; it still lands well within one step of the linear result.
assert(abs(logv - lin) < 0.20*100, 'a proportional step at the reference is within a step of linear');
assert(abs(powv - lin) < 0.20*100, 'a power-law step at the reference is within a step of linear');

% ... and the first-order agreement gets tighter as the step shrinks.
small = 1;
linS = step(ref,"up",StepUp=small);
logS = step(ref,"up",StepUp=small,ScaleType="logarithmic",ScaleReference=ref);
assert(abs(logS - linS) < 0.01*small, 'the calibration is exact in the limit');

fprintf('PASS: the value spaces are calibrated at the reference\n');


% 3. Proportional (logarithmic) stepping -----------------------------------
% A fixed fraction per step: the ratio is the same wherever the ladder is.
o = {"up", 'StepUp', 100, 'ScaleType', "logarithmic", 'ScaleReference', 400};
r1 = step(400, o{:}) / 400;
r2 = step(800, o{:}) / 800;
r3 = step(1600, o{:}) / 1600;
assert(abs(r1-r2) < 1e-12 && abs(r2-r3) < 1e-12, 'every proportional step is the same ratio');
assert(r1 > 1, 'up is up');

dn = step(400,"down",StepDown=100,ScaleType="logarithmic",ScaleReference=400);
assert(dn < 400 && dn > 0, 'down stays positive');
assert(abs(step(dn,"up",StepUp=100,ScaleType="logarithmic",ScaleReference=400) - 400) < 1e-9, ...
    'up undoes down when the magnitudes match');

% The rule refuses rather than producing nonsense at or below zero.
[v,info] = step(0,"up",StepUp=100,ScaleType="logarithmic",ScaleReference=400);
assert(~info.Ok && v == 0, 'a proportional step from zero is refused, not fudged');
assert(strlength(info.Message) > 0, 'the refusal says why');

fprintf('PASS: proportional stepping is geometric and refuses non-positive values\n');


% 4. Power-law stepping ----------------------------------------------------
% p < 1 compresses as the value rises; p > 1 expands.
lo = step(100,"up",StepUp=50,ScaleType="power",ScaleExponent=0.5,ScaleReference=100) - 100;
hi = step(900,"up",StepUp=50,ScaleType="power",ScaleExponent=0.5,ScaleReference=100) - 900;
assert(hi > lo, 'a compressive exponent spreads the steps out in native units');

lo2 = step(100,"up",StepUp=50,ScaleType="power",ScaleExponent=2,ScaleReference=100) - 100;
hi2 = step(900,"up",StepUp=50,ScaleType="power",ScaleExponent=2,ScaleReference=100) - 900;
assert(hi2 < lo2, 'an expansive exponent packs them closer as the value rises');

% p = 1 is linear exactly.
assert(abs(step(37,"up",StepUp=13,ScaleType="power",ScaleExponent=1,ScaleReference=99) - 50) < 1e-12, ...
    'p = 1 is the linear rule');

% Signed powers keep a negative value monotone rather than complex.
v = step(-40,"up",StepUp=10,ScaleType="power",ScaleExponent=0.5,ScaleReference=-40);
assert(isreal(v) && v > -40, 'a negative value steps up, in the reals');

fprintf('PASS: power-law stepping compresses, expands, and handles negatives\n');


% 5. Piecewise stepping ----------------------------------------------------
B = [1000 200 200; 2000 500 500];   % coarse steps once the value is high

assert(step(500,"up",StepUp=50,StepDown=50,ScaleType="piecewise",Breakpoints=B) == 550, ...
    'below the first breakpoint the base step applies');
assert(step(1500,"up",StepUp=50,ScaleType="piecewise",Breakpoints=B) == 1700, ...
    'the last breakpoint at or below the value wins');
assert(step(2500,"up",StepUp=50,ScaleType="piecewise",Breakpoints=B) == 3000, ...
    'the highest segment applies above every breakpoint');
assert(step(1000,"up",StepUp=50,ScaleType="piecewise",Breakpoints=B) == 1200, ...
    'a breakpoint is inclusive of its own From value');
assert(step(1500,"down",StepDown=50,ScaleType="piecewise",Breakpoints=B) == 1300, ...
    'down reads the segment down column');

% Rows in any order, and non-finite From values dropped.
shuffled = gui.AdaptiveTraining.sortBreakpoints([2000 500 500; 1000 200 200]);
assert(isequal(shuffled, B), 'breakpoints sort ascending by From value');
assert(size(gui.AdaptiveTraining.sortBreakpoints([Inf 1 1; 5 2 2]),1) == 1, ...
    'a non-finite breakpoint is dropped');

% An empty table degrades to the base magnitudes rather than refusing.
assert(step(500,"up",StepUp=50,ScaleType="piecewise") == 550, ...
    'piecewise with no breakpoints is linear');

fprintf('PASS: piecewise segment lookup\n');


% 6. The window ------------------------------------------------------------
sw = hw.Software;
P = sw.add_parameter('StimDelay', 1000, Unit='ms', Min=400, Max=4000);
P.Value = 1000;

fig = uifigure('Visible','off');
cleanupFig = onCleanup(@() delete(fig));

G = gui.AdaptiveTraining(P, Parent=fig, ...
    MinValue=400, MaxValue=4000, StepUp=350, StepDown=100, ...
    StepUpLimits=[0 500], StepDownLimits=[0 500], ...
    MinValueLimits=[400 4000], MaxValueLimits=[400 4000]);

assert(isequal(G.ValueHistory, 1000), 'the history starts at the current value');
assert(G.ScaleType == "linear", 'linear is still the default rule');

v = G.updateParameter("up");
assert(v == 1350 && P.Value == 1350, 'a step writes straight through to the parameter');
assert(isequal(G.ValueHistory, [1000 1350]), 'the step is appended to the history');
assert(isequal(G.StepDirections, [0 1]), 'the direction is recorded for the plot');

G.updateParameter("down");
assert(P.Value == 1250, 'down subtracts StepDown');
assert(isequal(G.StepDirections, [0 1 -1]), 'both directions are recorded');

assert(G.updateParameter("sideways") == 1250, 'an unknown direction is a no-op');
assert(numel(G.ValueHistory) == 3, 'a no-op appends nothing');

% Bounds are still enforced through the new fields.
for i = 1:20, G.updateParameter("up"); end
assert(P.Value == 4000, 'stepping up stops at MaxValue');

G.resetHistory();
assert(isequal(G.ValueHistory, 4000), 'reset restarts from the current value');

fprintf('PASS: the window steps, records, and clamps\n');


% 7. Advanced disclosure and scale switching from the window ---------------
assert(~G.ShowAdvanced, 'the limit settings are hidden by default');
G.ShowAdvanced = true;
assert(G.ShowAdvanced, 'the disclosure opens');

G.ScaleType = "logarithmic";
assert(isfinite(G.ScaleReference), 'switching space seeds a visible reference');

P.Value = 1000;
G.resetHistory();
before = P.Value;
G.updateParameter("up");
assert(P.Value > before*1.01, 'the window now steps proportionally');

G.ScaleType = "piecewise";
G.Breakpoints = [2000 500 500; 1000 200 200];
assert(G.Breakpoints(1,1) == 1000, 'the property sorts what it is handed');

G.ScaleType = "linear";
delete(G);

fprintf('PASS: the Advanced rules drive the same stepping the statics do\n');


% 8. Reject-on-violation is unchanged --------------------------------------
G = gui.AdaptiveTraining(P, Parent=fig, MinValue=400, MaxValue=4000, ...
    StepUp=350, StepDown=100, StepUpLimits=[0 500]);

G.ScaleType = "power";
G.ScaleExponent = 0.5;
assert(G.ScaleExponent == 0.5, 'the exponent commits');

try
    G.ScaleExponent = -1;
    error('a negative exponent should have been refused');
catch ME
    assert(contains(ME.identifier,'validators') || contains(ME.message,'positive'), ...
        'the exponent is validated as positive (got %s)', ME.identifier);
end

delete(G);
fprintf('PASS: rule validation refuses what it cannot step with\n');


% 9. The callback that opens the window forwards the rule ------------------
rt = epsych.Runtime;
rt.isTest = true;
rt.EVENTS = epsych.EventHub;
sw2 = hw.Software;
sw2.add_parameter('StimDelay', 1000, Unit='ms', Min=400, Max=4000);
rt.Interfaces = sw2;
pDelay = rt.find_parameter('StimDelay');
pDelay.isRandom = true;

host = AdaptiveTrainingTestHost(rt);
[~,ok] = gui.eval_adaptive_training_mode(host, [], struct('Value',1), pDelay, ...
    StepUp=100, StepDown=50, ScaleType="piecewise", ...
    Breakpoints=[2000 400 200], StepUpResponse="Miss", StepDownResponse="Hit");
assert(ok, 'training mode switches on');
assert(host.AdaptiveTrainingGUIs.isKey('StimDelay'), 'the window is registered under the parameter');

W = host.AdaptiveTrainingGUIs('StimDelay');
assert(W.ScaleType == "piecewise", 'the value space reaches the window');
assert(isequal(W.Breakpoints, [2000 400 200]), 'so do the breakpoints');
assert(W.StepUpResponse == "Miss", 'and the response mapping the header shows');
assert(~pDelay.isRandom, 'randomisation is suspended while training runs');

[~,ok] = gui.eval_adaptive_training_mode(host, [], struct('Value',0), pDelay);
assert(ok, 'training mode switches off');
assert(~host.AdaptiveTrainingGUIs.isKey('StimDelay'), 'the window is unregistered');
assert(pDelay.isRandom, 'randomisation is restored');

fprintf('PASS: eval_adaptive_training_mode forwards the rule and tears down\n');


% 10. A parameter with no value yet ----------------------------------------
% add_parameter fills Values, not Value: a parameter the trial dispatcher has
% not written is empty, and training mode can be switched on from a checkbox
% or arrive with a phase load before the first trial. The window must open
% over one of those and step only once there is something to step from.
sw3 = hw.Software;
pFresh = sw3.add_parameter('Depth', 50, Unit='%', Min=0, Max=100);
assert(isempty(pFresh.Value), 'fixture check: an unwritten parameter has no Value');

G = gui.AdaptiveTraining(pFresh, Parent=fig, MinValue=0, MaxValue=100, ...
    StepUp=5, StepDown=2, ScaleType="power", ScaleExponent=0.5);

assert(isempty(G.ValueHistory), 'no value means no history point');
assert(isempty(G.updateParameter("up")), 'a step with nothing to step from is a no-op');
assert(isempty(G.ValueHistory), 'and appends nothing');

pFresh.Value = 50;   % the first dispatch lands
assert(G.updateParameter("up") > 50, 'the ladder starts once the parameter has a value');

delete(G);
fprintf('PASS: the window opens over a parameter the dispatcher has not written\n');


% 11. The owned window counts the Advanced section once --------------------
% The section's height is added to the figure so the plot keeps its size.
% Getting the bookkeeping wrong grows the window by 232 px on every open --
% and saves the grown size, so it compounds.
DEFAULT_H = 400; ADVANCED_H = 232;   % see DEFAULT_SIZE / ADVANCED_HEIGHT

if ispref('AdaptiveTraining','Position'), rmpref('AdaptiveTraining','Position'); end
setpref('AdaptiveTraining','ShowAdvanced',true);

W = gui.AdaptiveTraining(P, WindowStyle="normal");
h1 = W.Parent.Position(4);
assert(h1 == 560 + ADVANCED_H, ...
    'first open with Advanced remembered should be %d px, got %d', 560+ADVANCED_H, h1);
delete(W);

W = gui.AdaptiveTraining(P, WindowStyle="normal");   % against the position just saved
assert(W.Parent.Position(4) == h1, 'reopening grew the window');
W.ShowAdvanced = false;
assert(W.Parent.Position(4) == 560, 'collapsing did not give the height back');
W.ShowAdvanced = true;
W.ShowAdvanced = false;
assert(W.Parent.Position(4) == 560, 'toggling drifted the window height');
assert(W.Parent.Position(3) >= DEFAULT_H, 'the width floor still applies');
delete(W);

fprintf('PASS: the Advanced section is counted once\n');


fprintf('\nALL ADAPTIVE TRAINING CHECKS PASSED\n');
end


function c = guardPreferences(group, names)
% Snapshot preferences the test writes, and put them back when it ends.
saved = repmat(struct('Name', '', 'Existed', false, 'Value', []), 1, numel(names));
for i = 1:numel(names)
    n = char(names{i});
    saved(i).Name = n;
    saved(i).Existed = ispref(group, n);
    if saved(i).Existed
        saved(i).Value = getpref(group, n);
    end
end
% Start from a known state so the disclosure assertions mean something.
setpref(group, 'ShowAdvanced', false);
c = onCleanup(@() restorePreferences(group, saved));
end


function restorePreferences(group, saved)
for i = 1:numel(saved)
    if saved(i).Existed
        setpref(group, saved(i).Name, saved(i).Value);
    elseif ispref(group, saved(i).Name)
        rmpref(group, saved(i).Name);
    end
end
end
