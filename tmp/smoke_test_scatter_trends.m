function smoke_test_scatter_trends()
% smoke_test_scatter_trends()
% Exercise the trend-line overlay of gui.components.ParameterScatter: the
% polynomial fits and their reported statistics, the moving average, the
% per-X-value mean and median, the categorical-axis rules, the statistics
% toggle, preference persistence, inheritance by a pop-out, and the cost of
% recomputing a trend on a session-length record.
% Headless-safe: every GUI is closed before returning.
%
%   matlab -batch "run('tmp/smoke_test_scatter_trends.m')"

here = fileparts(mfilename('fullpath'));
run(fullfile(here,'..','epsych_startup.m'));

PREF_GROUP = 'epsych2_gui_ParameterScatter';
TAGS = {'smokeTR1','smokeTR2','SmokeTrend1_ParameterScatter_PopOut'};
cleanupObj = onCleanup(@() cleanupPrefs(PREF_GROUP, TAGS));

D = makeData(40);
f = uifigure('Visible','off','Tag','SmokeTrend1');
S = gui.components.ParameterScatter(D, f, PreferenceTag='smokeTR1');
S.XParameter = 'Trial Number';
S.YParameter = 'LinY';

% 1. No trend by default ---------------------------------------------------
assert(strcmp(S.TrendType,'none'), 'trend should be off by default (got %s)', S.TrendType);
assert(~isempty(S.TrendH) && isvalid(S.TrendH), 'trend line object should exist');
assert(isempty(S.TrendH.XData), 'no trend selected should draw nothing');
assert(isempty(char(S.AxesH.Title.String)), 'no trend should leave the title alone');
fprintf('PASS: no trend by default\n');

% 1b. The right-click items exist and drive the plot -----------------------
% buildContextMenu_ swallows a failure and logs it, so nothing else in this
% file would notice the menu never being built.
cm = S.AxesH.ContextMenu;
assert(~isempty(cm) && isvalid(cm), 'the aesthetics context menu should exist');
trendMenu = findall(cm,'Type','uimenu','Text','Trend Line');
assert(isscalar(trendMenu), 'the Trend Line submenu should be built');
assert(numel(trendMenu.Children) == 7, ...
    'every trend type should be offered (got %d)', numel(trendMenu.Children));
assert(isscalar(findall(cm,'Type','uimenu','Text','Trend Window')), ...
    'the moving-average window submenu should be built');
assert(isscalar(findall(cm,'Type','uimenu','Tag','tgl|ShowTrendStats')), ...
    'the statistics toggle should be on the menu');
assert(isscalar(findall(cm,'Type','uimenu','Text','Trend Line Color ...')), ...
    'the trend color picker should be on the menu');

item = findall(cm,'Type','uimenu','Tag','aes|TrendType|linear');
item.MenuSelectedFcn(item,[]); % the operator's click
assert(strcmp(S.TrendType,'linear'), 'the menu should set the trend type');
assert(~isempty(S.TrendH.XData), 'the menu should redraw without a further update');
assert(item.Checked == "on", 'the chosen trend should be check-marked');
assert(findall(cm,'Type','uimenu','Tag','aes|TrendType|none').Checked == "off", ...
    'only the chosen trend should be check-marked');

wItem = findall(cm,'Type','uimenu','Tag','aes|TrendWindow|10');
wItem.MenuSelectedFcn(wItem,[]);
assert(S.TrendWindow == 10, 'the menu should set the moving-average window');
assert(wItem.Checked == "on", 'the chosen window should be check-marked');
S.TrendWindow = 20;
S.TrendType = 'none';
S.update;
fprintf('PASS: right-click items built, wired, and check-marked\n');

% 2. Linear fit recovers a known line and reports it ----------------------
% LinY is exactly 3*trial + 5, so slope, intercept and R^2 are all knowable.
S.TrendType = 'linear';
S.update;
tx = S.TrendH.XData; ty = S.TrendH.YData;
assert(numel(tx) == 200, 'a fitted curve should be drawn on a dense grid (got %d)', numel(tx));
assert(abs(tx(1) - 1) < 1e-9 && abs(tx(end) - 40) < 1e-9, 'grid should span the plotted x range');
assert(abs(ty(1) - 8) < 1e-6, 'fit at x=1 should be 8 (got %g)', ty(1));
assert(abs(ty(end) - 125) < 1e-6, 'fit at x=40 should be 125 (got %g)', ty(end));
ttl = char(S.AxesH.Title.String);
assert(contains(ttl,'Linear fit'), 'title should name the fit (got "%s")', ttl);
assert(contains(ttl,'y = 3 x +5'), 'title should report slope and intercept (got "%s")', ttl);
assert(contains(ttl,'R^2 = 1.000'), 'an exact line should report R^2 = 1 (got "%s")', ttl);
assert(contains(ttl,'n = 40'), 'title should report the fitted point count (got "%s")', ttl);
fprintf('PASS: linear fit recovers slope, intercept, R^2\n');

% 2b. Higher orders fit their own polynomial exactly -----------------------
S.YParameter = 'QuadY'; % 2*t^2 - 3*t + 1
S.TrendType = 'quadratic';
S.update;
ttl = char(S.AxesH.Title.String);
assert(contains(ttl,'Quadratic fit') && contains(ttl,'R^2 = 1.000'), ...
    'quadratic fit of a quadratic should be exact (got "%s")', ttl);
assert(abs(S.TrendH.YData(end) - (2*40^2 - 3*40 + 1)) < 1e-3, ...
    'quadratic fit should pass through the last point');
S.TrendType = 'cubic';
S.update;
assert(contains(char(S.AxesH.Title.String),'Cubic fit'), 'cubic fit should be reported');
S.YParameter = 'LinY';
fprintf('PASS: quadratic and cubic fits\n');

% 3. Moving average ---------------------------------------------------------
% Y = trial number, so the running mean has hand-checkable values.
S.YParameter = 'Trial Number';
S.XParameter = 'Trial Number';
S.TrendType = 'movmean';
S.TrendWindow = 5;
S.update;
ty = S.TrendH.YData;
assert(numel(ty) == 40, 'moving average should give one value per trial (got %d)', numel(ty));
assert(issorted(S.TrendH.XData), 'moving average should be drawn against sorted x');
assert(abs(ty(1) - 2) < 1e-12, 'window shrinks at the start: mean(1:3) = 2 (got %g)', ty(1));
assert(abs(ty(10) - 10) < 1e-12, 'centred window: mean(8:12) = 10 (got %g)', ty(10));
assert(max(abs(ty - refMovAvg(1:40,5))) < 1e-12, 'moving average disagrees with the reference');
assert(contains(char(S.AxesH.Title.String),'window 5'), 'title should report the window');
S.TrendWindow = 200; % wider than the session: clamped to the trial count
S.update;
assert(contains(char(S.AxesH.Title.String),'window 40'), 'window should clamp to the trial count');
S.TrendWindow = 20;
fprintf('PASS: moving average, window clamping\n');

% 4. Mean and median per X value -------------------------------------------
% FreqHz repeats, so each distinct value gathers several trials.
S.XParameter = 'FreqHz';
S.YParameter = 'Noisy';
S.TrendType = 'mean';
S.update;
[ex,em] = groupRef([D.FreqHz],[D.Noisy],@mean);
assert(isequal(S.TrendH.XData, ex), 'mean should be plotted at each distinct x, in order');
assert(max(abs(S.TrendH.YData - em)) < 1e-12, 'per-X mean disagrees with the reference');
assert(contains(char(S.AxesH.Title.String),sprintf('%d values',numel(ex))), ...
    'title should report how many x values were grouped');
S.TrendType = 'median';
S.update;
[~,emed] = groupRef([D.FreqHz],[D.Noisy],@median);
assert(max(abs(S.TrendH.YData - emed)) < 1e-12, 'per-X median disagrees with the reference');
fprintf('PASS: per-X-value mean and median\n');

% 5. Categorical axes -------------------------------------------------------
% A code is not a quantity: nothing is fitted against a categorical y, and
% only the per-value aggregates are drawn over a categorical x.
S.XParameter = 'Trial Number';
S.YParameter = 'NoteStr';
S.TrendType = 'linear';
S.update;
assert(isempty(S.TrendH.XData), 'no trend should be drawn against a categorical y');
assert(isempty(char(S.AxesH.Title.String)), 'a hidden trend should leave no statistics behind');

S.XParameter = 'NoteStr';
S.YParameter = 'Noisy';
S.TrendType = 'linear';
S.update;
assert(isempty(S.TrendH.XData), 'a polynomial fit over category codes should be refused');
S.TrendType = 'mean';
S.update;
assert(numel(S.TrendH.XData) == 3, 'per-value mean should be drawn over a categorical x');
assert(isequal(S.TrendH.XData, 1:3), 'categorical means belong at the category positions');
fprintf('PASS: categorical axis rules\n');

% 6. Statistics toggle ------------------------------------------------------
S.XParameter = 'Trial Number';
S.YParameter = 'LinY';
S.TrendType = 'linear';
S.ShowTrendStats = false;
S.update;
assert(~isempty(S.TrendH.XData), 'the line should still be drawn with statistics off');
assert(isempty(char(S.AxesH.Title.String)), 'statistics off should clear the title');
S.ShowTrendStats = true;
S.update;
assert(contains(char(S.AxesH.Title.String),'Linear fit'), 'statistics should come back');
fprintf('PASS: statistics toggle\n');

% 7. Trend settings persist and a pop-out inherits them ---------------------
S.TrendType = 'movmean';
S.TrendWindow = 50;
S.TrendColor = [0 0.5 0];
S.onSelectionChanged; % the user's dropdown interaction, which persists everything
P = S.popOut();
assert(strcmp(P.TrendType,'movmean'), 'pop-out should open on the host trend (got %s)', P.TrendType);
assert(P.TrendWindow == 50, 'pop-out should inherit the window (got %d)', P.TrendWindow);
assert(isequal(P.TrendColor,[0 0.5 0]), 'pop-out should inherit the trend color');
S.closePopOut();
delete(S); close(f);

f2 = uifigure('Visible','off','Tag','SmokeTrend1b');
S2 = gui.components.ParameterScatter(D, f2, PreferenceTag='smokeTR1');
assert(strcmp(S2.TrendType,'movmean'), 'trend type not restored (got %s)', S2.TrendType);
assert(S2.TrendWindow == 50, 'trend window not restored (got %d)', S2.TrendWindow);
assert(isequal(S2.TrendColor,[0 0.5 0]), 'trend color not restored');
delete(S2); close(f2);
fprintf('PASS: trend settings persist and are inherited by a pop-out\n');

% 8. Cost: a trend must be cheap enough to redraw on every trial ------------
Dbig = makeData(5000);
f3 = uifigure('Visible','off','Tag','SmokeTrend2');
S3 = gui.components.ParameterScatter(Dbig, f3, PreferenceTag='smokeTR2');
S3.XParameter = 'Trial Number';
S3.YParameter = 'Noisy';
S3.ShowTrendStats = true;
reps = 10;
S3.TrendType = 'none'; S3.update; % warm the value caches
base = timeUpdates(S3,reps);
timings = struct('none',base);
for t = {'linear','quadratic','cubic','movmean','mean','median'}
    S3.TrendType = t{1};
    S3.update;
    timings.(t{1}) = timeUpdates(S3,reps);
    fprintf('  %-10s %6.1f ms/redraw (+%.1f ms over no trend)\n', ...
        t{1}, timings.(t{1})*1e3, (timings.(t{1})-base)*1e3);
end
for t = {'linear','quadratic','cubic','movmean','mean','median'}
    dt = timings.(t{1}) - base;
    assert(dt < 0.100, '%s trend added %.1f ms to a 5000-trial redraw', t{1}, dt*1e3);
end
delete(S3); close(f3);
fprintf('PASS: every trend adds under 100 ms to a 5000-trial redraw\n');

fprintf('smoke_test_scatter_trends: ALL PASS\n');
end


function t = timeUpdates(S,reps)
% Median seconds per redraw, so one scheduling hiccup does not set the bar.
ts = zeros(1,reps);
for k = 1:reps
    tic; S.update; ts(k) = toc;
end
t = median(ts);
end

function m = refMovAvg(v,w)
% Straightforward centred running mean, against which the component's
% cumulative-sum version is checked.
n = numel(v);
half = floor(w/2);
m = zeros(1,n);
for k = 1:n
    lo = max(1,k-half);
    hi = min(n,k+(w-1-half));
    m(k) = mean(v(lo:hi));
end
end

function [gx,gy] = groupRef(x,y,fcn)
% Per-distinct-x aggregate, computed the obvious way.
gx = unique(x);
gy = zeros(1,numel(gx));
for k = 1:numel(gx)
    gy(k) = fcn(y(x == gx(k)));
end
end

function D = makeData(n)
% Per-trial DATA struct array with parameters whose trends are knowable.
D = struct([]);
cats = {'Stim','Catch','Reminder'};
for k = 1:n
    D(k).TrialID = mod(k-1,4)+1;
    D(k).FreqHz = 1000*2^mod(k,5);          % repeats: groups for mean/median
    D(k).LinY = 3*k + 5;                    % exactly linear in trial number
    D(k).QuadY = 2*k^2 - 3*k + 1;           % exactly quadratic
    D(k).Noisy = sin(k) + 0.5*mod(k,7);     % deterministic, not a polynomial
    D(k).NoteStr = cats{mod(k-1,numel(cats))+1};
end
end

function cleanupPrefs(group, tags)
% Remove only the preference keys this test created.
for k = 1:numel(tags)
    tag = matlab.lang.makeValidName(tags{k});
    if ispref(group, tag)
        rmpref(group, tag);
    end
end
end
