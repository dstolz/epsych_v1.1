function curState = FigOnTop(figh,state)
% [curState] = FigOnTop(figh)
% [curState] = FigOnTop(figh,state)
% 
% Maintain figure (figure handle = figh) on top of all other windows if
% state = true.
% 
% No errors or warnings are thrown if for some reason this function is 
% unable to keep figh on top.
% 
% Daniel.Stolzberg 2014

% DJS 2020; added curState output

narginchk(1,2);

drawnow expose

if nargin < 2, state = []; end


try %#ok<TRYNC>
    warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    J = get(figh,'JavaFrame');
   if verLessThan('matlab','8.1')
        curState = J.fHG1Client.getWindow.isAlwaysOnTop;
        if ~isempty(state)
            J.fHG1Client.getWindow.setAlwaysOnTop(state);
        end
    else
        curState = J.fHG2Client.getWindow.isAlwaysOnTop;
        if ~isempty(state)
            J.fHG2Client.getWindow.setAlwaysOnTop(state);
        end
    end
    warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
end

                