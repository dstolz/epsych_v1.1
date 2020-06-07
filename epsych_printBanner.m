function epsych_printBanner
% ep_printBanner
%
% Print text EPsych banner and a link to the online manual
%
% daniel.stolzberg@gmail.com 2020 (c)

f = {'utopiab','pebbles','marquee','letters','stellar','weird','bell','5lineoblique','speed','univers'};
h = sprintf('http://artii.herokuapp.com/make?text=EPsych&font=%s',f{randi(length(f))});
try
    cm = {webread(h)};
catch
    cm = {  '_________________                     ______  ', ...
            '___  ____/__  __ \___________  __________  /_ ', ...
            '__  __/  __  /_/ /_  ___/_  / / /  ___/_  __ \', ...
            '_  /___  _  ____/_(__  )_  /_/ // /__ _  / / /', ...
            '/_____/  /_/     /____/ _\__, / \___/ /_/ /_/ ', ...
            '                        /____/             '};   
end
cm{end} = sprintf('%s\nv1.1 <a href="matlab: edit(''%s'')">(C) 2019  Daniel Stolzberg, PhD</a>',cm{end},fullfile(epsych_path,'LICENSE'));
lnk = 'https://github.com/dstolz/epsych_v1.1';
cm{end+1} = sprintf('Repository: <a href="matlab: web(''%s'',''-browser'')">%s</a>',lnk,lnk);
cm{end+1} = '-> <a href="matlab: ep_LaunchPad">ep_LaunchPad</a>  ... Launch panel for EPsych utilities';
cm{end+1} = '--> <a href="matlab: ep_ExperimentDesign">ep_ExperimentDesign</a>  ... Define parameters for experiments';
cm{end+1} = '--> <a href="matlab: ep_BitmaskGen">ep_BitmaskGen</a>        ... Bitmask table generator for behavioral experiments';
cm{end+1} = '--> <a href="matlab: ep_CalibrationUtil">ep_CalibrationUtil</a>   ... Sound calibration utility';
cm{end+1} = '--> <a href="matlab: ep_EPhys">ep_EPhys</a>             ... Electrophysiology experiments with OpenEx';
cm{end+1} = '--> <a href="matlab: ep_RunExpt">ep_RunExpt</a>           ... Behavioral/Electrophysiology with or without OpenEx';

fprintf('\n')
for i = 1:length(cm), fprintf('%s\n',cm{i}); end







