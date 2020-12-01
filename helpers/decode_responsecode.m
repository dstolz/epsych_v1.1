function D = decode_responsecode(RespCodes)
% D = decode_responsecode(RespCodes)

nBits = length(epsych.BitMask.list);

for i = 1:nBits-1
    d = bitget(RespCodes,i);
%     if ~any(d), continue; end
    D.(char(epsych.BitMask(i))) = d;
end

D = structfun(@logical,D,'uni',0);
