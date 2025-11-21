function colDouble = toNumeric(col)
    % Converte un vettore colonna (cell o double) in double
    if iscell(col)
        colDouble = nan(size(col));
        for i = 1:length(col)
            val = col{i};
            if isnumeric(val)
                colDouble(i) = val;
            elseif ischar(val) || isstring(val)
                colDouble(i) = str2double(val);
            end
        end
    else
        colDouble = double(col);
    end
end
