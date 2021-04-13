function  write(obj,parameter,value)

if iscell(value)
    Screen(parameter,value{:});
else
    Screen(parameter,value);
end