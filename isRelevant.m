function flag = isRelevant(w,w2,thres)
    v = w2(logical(w));             %% values apart from ones to be filled 
    v_mean = sum(v)/length(v);      %% mean of above values
    v2 = w2(~w);                    %% values to be filled
    v2_mean = sum(v2)/length(v2);   %% mean of above values
    diff = abs(v_mean-v2_mean);
    
    if diff < thres
        flag = 1;
    else
        flag = 0;
    end
end