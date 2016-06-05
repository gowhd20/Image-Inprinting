function im2 = inPrint(imResizeRatio, thres, search_step, thres_cen_weighted, weight_v_l, weight_v_h)

im = imread('statue_test.png');
im_grid = im;

count = 1;

%% get location of the grid
%% works only for rectangular grid
for i=1:length(im(:,1,1))
    for j=1:length(im(1,:,1))
        if im_grid(i,j,:) == 255
            if im_grid(i:i+5,j:j+5,:) == 255
                if count == 1
                    grid_x = i;
                    grid_y = j;
                    p = i;
                    q = j;
                    while im_grid(p,q,:) == 255
                        while im_grid(p,q,:) == 255
                            im_grid(p,q,:) = 0;
                            p = p+1;
                        end
                        grid_x_e = p-1;
                        p = i;
                        q = q+1;
                    end
                    grid_y_e = q-1;
                    count = count+1;
                end
            end
        end
    end
end

im = im_grid;
im = single(im);
im_origin = im;
im2 = im;

%% parameters that affect to the result %%
imResizeRatio = 6;
thres = 20; %62;             %% low value will cause the algorithm more selective range 0~255
search_step = 5; 
thres_cen_weighted = 10;      %% recommanded range 15~25
weight_v_l = 1;                %% 0.1~ 2
weight_v_h = 2.0;
%
w = zeros(5,5,3);
s = struct('coordinate',0,'filter',zeros(5,5,3),'sum',100000, 'iteration',1);
len_x = length(im(:,1,1));
len_y = length(im(1,:,1));
count = 1;
count_find_ = 1;

%%test
coordi = zeros(1,2);
diff = zeros(5,5,3);

for i=3:len_x-2
    for j=3:len_y-2
        w = im2(i-2:i+2,j-2:j+2,:);  %% move mask around the image
        %if isRGBZero(w) == 1        %% check if found 0 values are made by me
        if isInsideGrid(i, j, grid_x, grid_x_e, grid_y, grid_y_e) == 1  %% check if inside grid
            boundary = isOutBoundary(i, j, len_x, len_y, imResizeRatio);
            %% when there is no collision to boundaries
            if isempty(boundary) == 1
                k = i-(len_x/imResizeRatio);
                k_e = i+(len_x/imResizeRatio);
                
                z = j-(len_y/imResizeRatio);
                z_e = j+(len_y/imResizeRatio);
            %% when there is a collision 
            elseif length(boundary) == 1 
                if boundary == 1    %% bottom
                    k = i-(len_x/imResizeRatio);
                    k_e = (len_x/imResizeRatio)-2;
                    
                    z = j-(len_y/imResizeRatio);
                    z_e = j+(len_y/imResizeRatio);
                elseif boundary == 2    %% top
                    k = 3;         %% depends on the size of filter
                    k_e = i+(len_x/imResizeRatio);
                    
                    z = j-(len_y/imResizeRatio);
                    z_e = j+(len_y/imResizeRatio);
                elseif boundary == 3    %% right
                    k = i-(len_x/imResizeRatio);
                    k_e = i+(len_x/imResizeRatio);
                    
                    z = j-(len_y/imResizeRatio);
                    z_e = len_y-2;
                elseif boundary == 4    %% left
                    k = i-(len_x/imResizeRatio);
                    k_e = i+(len_x/imResizeRatio);
                    
                    z = 3;
                    z_e = j+(len_y/imResizeRatio);
                end
            %% when there is two-aspects collision
            elseif length(boundary) == 2
                if boundary == [1,3]    %% bottom right
                    k = i-(len_x/imResizeRatio);
                    k_e = len_x-2;
                    
                    z = j-(len_y/imResizeRatio);
                    z_e = len_y-2;
                elseif boundary == [1,4]    %% bottom left
                    k = i-(len_x/imResizeRatio);
                    k_e = len_x-2;
                    
                    z = 3;
                    z_e = j+(len_y);
                elseif boundary == [2,3]    %% top right
                    k = 3;
                    k_e = i+(len_x/imResizeRatio);
                    
                    z = j-(len_y/imResizeRatio);
                    z_e = len_y-2;
                elseif boundary == [2,4]    %% top left
                    k = 3;
                    k_e = i+(len_x/imResizeRatio);
                    
                    z = 3;
                    z_e = j+(len_y/imResizeRatio);
                end
            elseif length(boundary) == 4
                k = 3;
                k_e = grid_x_e-2;
                
                z = 3;
                z_e = grid_y_e-2;
            end
      
            %% sub-filter to search similar patterns
            while k <= k_e
                while z <= z_e
                    if z == z_e-1 || z == z_e        %% at the end, attempt to fill pixel value where has been filled by prior filter 
                       break;
                    end
                    w2 = im2(k-2:k+2,z-2:z+2,:);  %% new filter to find idential matrix 
                    %if isRGBZero(w2) == 1     %% skip filter includes zero values
                    %% skip, if inside the grid. this only works when the grid is rectangular      
                    if isInsideGrid(k, z, grid_x, grid_x_e, grid_y, grid_y_e) == 1       
                    else
                        f = ifWeighted(w,w2,thres_cen_weighted);
                        if f == 3
                        elseif f == 1
                            w2(3,3,:) = w2(3,3,:)*weight_v_l;
                        elseif f == 2
                            w2(3,3,:) = w2(3,3,:)*weight_v_h;
                        end
                        r = abs(w2-w);
                        sm = sum(r(:));
                        if sm < s.sum                        %% difference
                            
                            if isRelevant(w,w2,thres) == 1   %% detail in the function 
                                s.coordinate = [k,z];        %% when it finds a more similar matrix then store the coordi
                                s.filter = w2;
                                s.sum = sm;
                                count_find_ = count_find_+1;
                                s.iteration = count_find_;
                            end
                        end
                    end
                    z = z+search_step; %% when filter collides with side there will be margin left unsearched between current i,j with sides 
                end
                %z=3;
                k = k+search_step;    %% //
            end
            %k=3;
             % end
            %% things have to be done after finding a similar matrix %
            %% get matrix that is size of filter and is most similar to original
            if s.coordinate == 0
            else
                w_temp = im2(s.coordinate(1)-2:s.coordinate(1)+2,s.coordinate(2)-2:s.coordinate(2)+2,:);  
    %             w(~w) = w_temp(~w);   %% replace values in corresponses of matrix found
    %             im2(i-2:i+2,j-2:j+2,:) = w;  %% apply to original image

                %% testing algorithm
                %im2(i-2:i+2,j-2:j+2,:) = w_temp; 
                v = [25,50,75];
                w(v(:)-1) = w_temp(v(:)-1);
                w(v(:)-5) = w_temp(v(:)-5);
                w(v(:)-6) = w_temp(v(:)-6);
                w(~w) = w_temp(~w);
                im2(i-2:i+2,j-2:j+2,:) = w; 
                
                fprintf('iteration : %d, old coordi :  (%d,%d), replaced by coordi : (%d,%d)\n', ...
                    count_find_, i, j, s.coordinate(1), s.coordinate(2));
                
                %% reset struct for the next row
                s.coordinate = 0;
                s.filter = zeros(5,5,3);
                s.sum = 100000;
                s.iteration = 1;
                count_find_ = 1;
            end
            
        end
    end
    imshow(uint8(im2));
    
end
end %% function end



    
    