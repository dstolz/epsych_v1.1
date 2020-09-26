function epsych_printBanner
% ep_printBanner
%
% Print text EPsych banner and a link to the online manual
%
% daniel.stolzberg@gmail.com 2020 (c)


try
    f = {'utopiab','pebbles','marquee','letters','stellar','weird','bell','5lineoblique','speed','univers'};
    h = sprintf('http://artii.herokuapp.com/make?text=EPsych %s&font=%s',epsych.Info.Version,f{randi(length(f))});
    cm = {webread(h)};
    
    
catch
    cm = {  '_________________                     ______  ', ...
            '___  ____/__  __ \___________  __________  /_ ', ...
            '__  __/  __  /_/ /_  ___/_  / / /  ___/_  __ \', ...
            '_  /___  _  ____/_(__  )_  /_/ // /__ _  / / /', ...
            '/_____/  /_/     /____/ _\__, / \___/ /_/ /_/ ', ...
            '                        /____/             '};   
end
cm{end} = sprintf('%s\n<a href="matlab: edit(''%s'')">(C) 2020  Daniel Stolzberg, PhD</a>', ...
    cm{end},fullfile(epsych_path,'LICENSE'));
lnk = 'https://github.com/dstolz/epsych_v1.1';
cm{end+1} = sprintf('Repository: <a href="matlab: web(''%s'',''-browser'')">%s</a>',lnk,lnk);

fprintf('\n')
cellfun(@(a) fprintf('%s\n',a),cm)







