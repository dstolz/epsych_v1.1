classdef Tool < handle

    methods (Static)
        function h = find_epsych_controlpanel
            h = findall(0,'Tag','EPsychControlPanel');
        end

        function s = restart_required(h)
            f = ancestor(h,'figure');
            s = uiconfirm(f, ...
                'This change requires EPsych to be restarted.  Would you like to restart now?', ...
                'Restart Required', ...
                'Options',{'Continue','Restart Now'}, ...
                'DefaultOption',1,'CancelOption',1);
            
            figure(f);
            
            if nargout == 0 && isequal(s,'Restart Now')
                epsych.Tool.restart_epsych;
            end
        end
        
        function restart_epsych
            h = epsych.Tool.find_epsych_controlpanel;
            close(h);

            fprintf('Restarting EPsych Control Panel ...\n')

            epsych.ui.ControlPanel;
        end

        function [unit,multiplier] = time_gauge(S)
            if S >= 1
                unit = 's';
                multiplier = 1;
                return
            end
            U = {'ps','ns','ms','us','ms','s'};
            U = [U; U; U];
            U = U(:);
            G = [.1; 1; 10] * 10.^(-12:3:3);
            G = G(:);
            M = 10.^(-12:3:3);
            M = [M; M; M];
            M = M(:);
            i = find(G < S*10,1,'last');
            multiplier = 1/M(i);
            unit = U{i};
        end
        
        function [unit,multiplier] = voltage_gauge(V)
            U = {'pV','nV','uV','mV','V','KV','MV','GV'};
            U = [U; U; U];
            U = U(:);
            G = [.1; 1; 10] * 10.^(-12:3:9);
            G = G(:);
            M = 10.^(-12:3:9);
            M = [M; M; M];
            M = M(:);
            i = find(G < V,1,'last');
            if isempty(i), i = 1; end
            multiplier = 1/M(i);
            unit = U{i};
        end
        
        function estr = stack_str(idx)
            d = dbstack;
            dc = dbstack('-completenames');
            if nargin == 0 || isempty(idx), idx = 1; end
            idx = idx + 1; % relative to calling function
            idx(idx > length(d)) = length(d); 
            estr = sprintf(['\tfile:\t<a href="matlab: opentoline(''%s'',%d);">%s (%s)</a>', ...
                '\n\tname:\t%s', ...
                '\n\tline:\t%d'], ...
                dc(idx).file,d(idx).line,d(idx).file,dc(idx).file,d(idx).name,d(idx).line);
        end

        function edit_field_alert(obj,FGcolor,BGcolor)
            if nargin < 2 || isempty(FGcolor), FGcolor = [1 1 1]; end
            if nargin < 3 || isempty(BGcolor), BGcolor = [1 .6 .6]; end

            orig.BackgroundColor = obj.BackgroundColor;
            orig.FontColor       = obj.FontColor;

            obj.BackgroundColor = BGcolor;
            obj.FontColor = FGcolor;
            pause(1);
            obj.BackgroundColor = orig.BackgroundColor;
            obj.FontColor = orig.FontColor;
        end

        
        function r = validate_filename(ffn)
            ffn = cellstr(ffn);
            r = false(size(ffn));
            for i = 1:numel(ffn)
                [~,fn,ext] = fileparts(ffn{i});
                fn = [fn ext]; %#ok<AGROW>
                r(i) = length(fn) <= 255 ...
                    && length(ffn{i}) <= 32000 ...
                    && isempty(regexp(ffn{i}, ['^(?!^(PRN|AUX|CLOCK\$|NUL|CON|COM\d|LPT\d|\..*)', ...
                    '(\..+)?$)[^\x00-\x1f\\?*:\"><|/]+$'], 'once'));
            end
        end
        
        function str = truncate_str(str,maxn,side)
            if nargin < 2 || isempty(maxn), maxn = 25; end
            if nargin < 3 || isempty(side), side = 'left'; end
            mustBeMember(side,{'left' 'right'});
            if length(str) < maxn
                return
            elseif isequal(lower(side),'right')
                str = [str(1:end-maxn) '...'];
            else
                str = ['...' str(end-maxn+1:end)];
            end
        
        end

        function prevState = figure_state(h,state)
            % figure_state(h);  % toggle state of figure handle h
            % figure_state(h,state) % set state of figure handle h
            % prevState = figure_state(h,...) % return current or previous state of figure handle h
            % 
            % DJS 2020
            
            narginchk(1,2);

            drawnow expose

            figh = ancestor(h,'figure');

            if nargin < 2, state = []; end % toggle state

            try %#ok<TRYNC>
                warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
                
                if isa(figh,'matlab.ui.Figure')
                    warning('off','MATLAB:structOnObject');
                    f = struct(figh);
                    c = struct(f.Controller);
                    p = struct(c.PlatformHost);
                    prevState = p.CEF.isAlwaysOnTop;
                    if isempty(prevState), prevState = false; end
                    if isempty(state), state = ~prevState; end
                    p.CEF.setAlwaysOnTop(state);
                    warning('on','MATLAB:structOnObject');

                elseif verLessThan('matlab','8.1')
                    J = get(figh,'JavaFrame');
                    prevState = J.fHG1Client.getWindow.isAlwaysOnTop;
                    if isempty(state), state = ~prevState; end
                    J.fHG1Client.getWindow.setAlwaysOnTop(state);
                else
                    J = get(figh,'JavaFrame');
                    prevState = J.fHG2Client.getWindow.isAlwaysOnTop;
                    if isempty(state), state = ~prevState; end
                    J.fHG2Client.getWindow.setAlwaysOnTop(state);
                end
                warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            
            end

        end

        function iconPath = icon(name)
            iconPath = fullfile(epsych.Info.root,'icons',[name '.png']);
        end

        function varargout = get_icon(name)
            [~,~,im] = imread(epsych.Tool.icon(name));
            alpha = single(im ~= 0);
            varargout{1} = alpha;
            varargout{2} = im;
        end

        function set_icon(ax,name)
            [m,alpha] = epsych.Tool.get_icon(name);
            imagesc(ax,m,'AlphaData',alpha);
            axis(ax,'image');
        end
    end % methods (Static)

end