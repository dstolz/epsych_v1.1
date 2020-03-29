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

            interface.ControlPanel;
        end
    end

end