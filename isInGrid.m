function flag = isInsideGrid(k,z,grid_x,grid_x_e,grid_y,grid_y_e)
    if ((grid_x <= k-2 && k-2 <= grid_x_e) || (grid_x <= k+2 && k+2 <= grid_x_e)) && ...
                           ((grid_y <= z-2 && z-2 <= grid_y_e) || (grid_y <= z+2 && z+2 <= grid_y_e))
                       flag = 1;
    else
        flag = 0;
    end
end