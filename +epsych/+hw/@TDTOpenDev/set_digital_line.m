function set_digital_line(obj,src,event)

D = event.AffectedObject;
obj.handle.SetTagVal(D.Label,D.State);

