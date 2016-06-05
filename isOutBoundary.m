function flags = isOutBoundary(i,j,len_x,len_y,imResizeRatio)
    flags = [];
    if i+(len_x/imResizeRatio)+2 > len_x
        flags(end+1) = 1;      %% out on bottom
    end
    if i-(len_x/imResizeRatio)-2 <= 0   
        flags(end+1) = 2;      %% out on top
    end
    if j+(len_y/imResizeRatio)+2 > len_y
        flags(end+1) = 3;      %% out on right
    end
    if j-(len_y/imResizeRatio)-2 <= 0
        flags(end+1) = 4;      %% out on left
    end
end