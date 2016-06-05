function flag = isRGBZero(w)
    for i=1:length(w(1,:,:))
        for j=1:length(w(:,1,:))
            if w(i,j,:) == 0
                flag = 1;
            else
                flag = 0;
            end
        end
    end
end


