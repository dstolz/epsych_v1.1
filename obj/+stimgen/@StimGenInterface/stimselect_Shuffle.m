function idx = stimselect_Shuffle(obj)

% select according to shuffled list

SO = obj.StimPlayObjs;


rep = [SO.Reps];
cnt = [SO.RepsPresented];


m = min(cnt);

idx = find(cnt == m);

idx(cnt >= rep) = [];


if isempty(idx) % all stim presented
    idx = -1; 
    return
end

idx = idx(randperm(length(idx),1));

