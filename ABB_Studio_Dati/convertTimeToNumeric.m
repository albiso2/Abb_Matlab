function t_num = convertTimeToNumeric(t)
    % Se già numerico
    if isnumeric(t)
        t_num = t;
        return;
    end

    % Se datetime
    if isdatetime(t)
        t_num = datenum(t);
        return;
    end

    % Se duration
    if isduration(t)
        t_num = seconds(t);
        return;
    end

    % Se cell o string
    if iscell(t) || isstring(t)
        t_str = string(t);            % convertiamo in string array
        t_num = str2double(t_str);    % prova a convertire in numero
        % gestiamo eventuali NaN (non numerici)
        if any(isnan(t_num))
            % sostituire NaN con interpolazione o error
            warning('Alcuni valori della colonna tempo non sono numerici. Vengono ignorati.');
            t_num(isnan(t_num)) = 0; % puoi anche usare interpolazione se vuoi
        end
        return;
    end

    error('Formato della colonna tempo non supportato.');
end

