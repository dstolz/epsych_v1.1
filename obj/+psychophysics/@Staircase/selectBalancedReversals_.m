function [used, why] = selectBalancedReversals_(isAscending, eligible, numReversals)
% [used, why] = psychophysics.Staircase.selectBalancedReversals_(isAscending, eligible, numReversals)
% The reversals a weighted threshold is computed from: an equal number of
% ascending and descending ones, the most recent of each.
%
% The weighted-staircase threshold is DEFINED on a balanced set (Hoover
% 2025), and imbalance is not a rounding matter: on a psi = 0.75 track the
% peaks alone sit near p = 0.86 and the troughs near 0.60, so one surplus
% reversal in twelve moves the estimate by about 0.02 in probability --
% comparable to the bias the correction removes.
%
% The rule: take the last numReversals eligible reversals, keep the most
% recent k of each direction where k is the smaller count, and return them
% in chronological order. A staircase's reversals alternate by construction,
% so in practice this drops at most the oldest one -- but it does not rely
% on that, because an ineligible (non-finite) value removed from the middle
% breaks the alternation.
%
% Parameters:
%   isAscending  - logical vector, true for a peak (an increase followed by a
%                  decrease). Which axis "up" is does not matter: the set is
%                  balanced, so a mirrored axis selects the same reversals.
%   eligible     - logical vector, same size; false drops a reversal before
%                  counting (a non-finite value).
%   numReversals - how many of the most recent eligible reversals to start
%                  from; Inf for all of them.
%
% Returns:
%   used - logical row vector, one per reversal, true for those selected.
%          At most numReversals are true, and exactly as many ascending as
%          descending; all false when either direction is absent.
%   why  - "" when a pair survived; otherwise the one sentence that says
%          why none did, shared by every caller so a session that is too
%          short reads the same everywhere.

isAscending = reshape(logical(isAscending), 1, []);
eligible    = reshape(logical(eligible), 1, []);

idx = find(eligible);
if isfinite(numReversals)
    idx = idx(max(1, numel(idx) - numReversals + 1):end);
end

asc  = idx(isAscending(idx));
desc = idx(~isAscending(idx));
k = min(numel(asc), numel(desc));

used = false(1, numel(isAscending));
used(asc(end-k+1:end))  = true;
used(desc(end-k+1:end)) = true;

why = "";
if k > 0
    return
elseif isempty(isAscending)
    why = "There are no reversals to average.";
elseif ~any(eligible)
    why = "There are no reversals with a defined value to average.";
elseif numReversals < 2
    why = sprintf(['NumReversals = %d leaves too few reversals to balance; the threshold ' ...
        'needs at least one ascending and one descending.'], numReversals);
else
    why = sprintf(['The reversals run in one direction only (%d ascending, %d descending), ' ...
        'and the threshold needs an equal number of each.'], numel(asc), numel(desc));
end
why = string(why);
