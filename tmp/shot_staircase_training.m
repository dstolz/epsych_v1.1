function shot_staircase_training()
% shot_staircase_training()
% Capture the redesigned gui.StaircaseTraining window, collapsed and with the
% Advanced section open, over a simulated training run.
%
%   matlab -batch "run('tmp/shot_staircase_training.m')"

here = fileparts(mfilename('fullpath'));
run(fullfile(here,'..','epsych_startup.m'));

outDir = fullfile(here,'staircase_ui_shots');
if ~isfolder(outDir), mkdir(outDir); end

% Deleting the window writes its ShowAdvanced preference, and the shots
% deliberately open it. Put back whatever this rig had, the way the two
% screenshot generators do, so regenerating the docs cannot change how the
% operator's window opens tomorrow.
saved = [];
if ispref('StaircaseTraining'), saved = getpref('StaircaseTraining'); end
restore = onCleanup(@() restorePrefs(saved));

shot('collapsed', "linear", false, outDir);
shot('advanced_linear', "linear", true, outDir);
shot('advanced_log', "logarithmic", true, outDir);
shot('advanced_piecewise', "piecewise", true, outDir);

% The two the documentation embeds.
docDir = fullfile(here,'..','documentation','gui','images');
copyfile(fullfile(outDir,'collapsed.png'), fullfile(docDir,'StaircaseTraining.png'));
copyfile(fullfile(outDir,'advanced_piecewise.png'), fullfile(docDir,'StaircaseTraining_Advanced.png'));

fprintf('shots written to %s\n', outDir);
end


function restorePrefs(saved)
if ispref('StaircaseTraining'), rmpref('StaircaseTraining'); end
if isempty(saved), return; end
f = fieldnames(saved);
for i = 1:numel(f)
    setpref('StaircaseTraining', f{i}, saved.(f{i}));
end
end


function shot(name, scaleType, advanced, outDir)
sw = hw.Software;
P = sw.add_parameter('StimDelay', 1000, Unit='ms', Min=400, Max=4000, Format='%.0f');
P.Value = 1000;

fig = uifigure('Visible','off','Position',[200 200 400 620],'Name','Staircase Training');
c = onCleanup(@() delete(fig));

G = gui.StaircaseTraining(P, Parent=fig, ...
    MinValue=400, MaxValue=4000, StepUp=350, StepDown=100, ...
    StepUpLimits=[0 500], StepDownLimits=[0 500], ...
    MinValueLimits=[400 4000], MaxValueLimits=[400 4000], ...
    StepUpResponse="Miss", StepDownResponse="Hit", ...
    ShowAdvanced=advanced);

G.ScaleType = scaleType;
if scaleType == "piecewise"
    G.Breakpoints = [1500 200 100; 2500 500 250];
end

% A plausible training run: mostly correct, with the odd miss.
outcomes = ["down","down","up","down","down","down","up","up","down","down", ...
            "down","up","down","down","down","down","up","down","down","down"];
for i = 1:numel(outcomes)
    G.updateParameter(outcomes(i));
end

drawnow
exportapp(fig, fullfile(outDir, [name '.png']));
d = dir(fullfile(outDir, [name '.png']));
fprintf('  %-22s %6.1f KB\n', name, d.bytes/1024);
delete(G)
end
