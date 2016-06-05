function flag = ifWeighted(w,w2,thres)
    v = w2(logical(w));             %% values apart from ones to be filled 
    v_mean = sum(v)/length(v); 
    
    v2 = sum(w2(3,3,:))/3;
    if v_mean > v2 && v_mean-thres > v2               %% darker than surrounding
        flag = 1;
    elseif v_mean < v2 && v_mean < v2+thres          %% brighter than surrounding
        flag = 0;
    else
        flag = 3;
    end
end