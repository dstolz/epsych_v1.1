function capture_scatter_trend_shot(outDir)
% capture_scatter_trend_shot(outDir)
% Render gui.components.ParameterScatter with each trend overlay to PNG, so
% the drawn line and its reported statistics can be looked at rather than
% only asserted. Scratch tooling, not a test.
%
%   matlab -batch "run('tmp/capture_scatter_trend_shot.m')"

if nargin < 1 || isempty(outDir), outDir = tempdir; end
here = fileparts(mfilename('fullpath'));
run(fullfile(here,'..','epsych_startup.m'));

n = 300;
D = struct([]);
for k = 1:n
    D(k).TrialID = k;
    D(k).LevelDB = 30 + 0.06*k + 4*sin(k/9) + 3*rem(k*7919,13)/13;
    D(k).FreqHz = 1000*2^mod(k,5);
end

shots = {'linear','movmean','mean','cubic'};
for s = 1:numel(shots)
    f = uifigure('Position',[100 100 640 420],'Name','Parameter Scatter', ...
        'Tag',sprintf('TrendShot%d',s));
    S = gui.components.ParameterScatter(D, f, PreferenceTag=sprintf('trendShot%d',s));
    if strcmp(shots{s},'mean')
        S.XParameter = 'FreqHz';
    else
        S.XParameter = 'Trial Number';
    end
    S.YParameter = 'LevelDB';
    S.TrendType = shots{s};
    S.TrendWindow = 25;
    S.update;
    drawnow;
    out = fullfile(outDir,sprintf('scatter_trend_%s.png',shots{s}));
    exportapp(f,out);
    fprintf('wrote %s\n',out);
    delete(S); close(f);
    if ispref('epsych2_gui_ParameterScatter',sprintf('trendShot%d',s))
        rmpref('epsych2_gui_ParameterScatter',sprintf('trendShot%d',s));
    end
end
end
