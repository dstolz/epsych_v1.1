function idx = stimselect_Serial(obj)

% select the next stimulus in the queue

SO = obj.StimPlayObjs;

cnt = [SO.RepsPresented];

idx = find(cnt < [SO.Reps],1,'first');

if isempty(idx) % all stim presented
    idx = -1; 
end

    
