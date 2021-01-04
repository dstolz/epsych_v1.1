function seq = RandomTrialSequence(n,maxC,driftCap)


if nargin < 1 || isempty(n), n = 1000; end
if nargin < 2 || isempty(maxC), maxC = 3; end
if nargin < 3 || isempty(driftCap), driftCap = 12; end


rn = n+rem(n,driftCap);

seq = zeros(1,rn,'int8');

seq(1:maxC) = randn(1,maxC) < 0;



% for i = maxC+1:n
%     seq(i) = randn(1) < 0;
%     
%     
%     if all(seq(i-maxC:i) == seq(i))
%         seq(i) = ~seq(i);
%     end
%     
%     
% end

for j = driftCap:driftCap:rn
    
    idx = j-driftCap+1:j;
    
    
    d = inf;
    
    while d > 3
        st = randn(1,driftCap) < 0;
        
        if j > driftCap
            st(1) = ~seq(j-1);
        end
        
        x = findConsecutive(st,maxC);
        dx = diff(x)+1;
        if any(dx > maxC), continue; end
        
        
        x = findConsecutive(~st,maxC);
        dx = diff(x)+1;
        if any(dx > maxC), continue; end
        
        d = abs(driftCap/2 - sum(st));
    end
    
    
    seq(idx) = st;
        
end

seq(n+1:end) = [];


