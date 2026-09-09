function B = sortBreakpoints(B)
% B = gui.StaircaseTraining.sortBreakpoints(B)
% Put a piecewise breakpoint table into the order the lookup assumes.
%
% The segment lookup is "the last row whose From value is <= the current
% value", which is only meaningful on rows sorted ascending by From. Sorting
% on the way in rather than at every step keeps that assumption in one place
% and lets the operator type breakpoints in any order.
%
% Rows carrying a non-finite From value are dropped: they can never be the
% last row at or below a finite value, so keeping them would only put a row
% in the table that does nothing.
%
%   B - Nx3 [FromValue StepUp StepDown].
%
% See also gui.StaircaseTraining, gui.StaircaseTraining.stepValue

if isempty(B)
    B = zeros(0,3);
    return
end

B = B(isfinite(B(:,1)), :);
[~,ord] = sort(B(:,1));
B = B(ord,:);
end
