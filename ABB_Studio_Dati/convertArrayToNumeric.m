
% Funzione ausiliaria
function arr_num = convertArrayToNumeric(arr)
    if istable(arr)
        arr = table2array(arr);
    end
    [nRows, nCols] = size(arr);
    arr_num = zeros(nRows, nCols);
    for i = 1:nCols
        col = arr(:,i);
        if isnumeric(col)
            arr_num(:,i) = col;
        elseif iscell(col) || isstring(col)
            col_num = str2double(string(col));
            col_num(isnan(col_num)) = 0; % sostituisci valori non numerici con 0
            arr_num(:,i) = col_num;
        elseif isdatetime(col)
            arr_num(:,i) = datenum(col);
        elseif isduration(col)
            arr_num(:,i) = seconds(col);
        else
            error('Colonna %d contiene un formato non supportato.', i);
        end
    end
end