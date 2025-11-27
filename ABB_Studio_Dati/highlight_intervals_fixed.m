%% --- Funzione modificata per evidenziare intervalli ---
function highlight_intervals_fixed(t, val, mask, colorRGB, alphaVal)
    inInterval = false;
    for i=1:length(mask)
        if mask(i) && ~inInterval
            startIdx = i;
            inInterval = true;
        elseif ~mask(i) && inInterval
            endIdx = i-1;
            inInterval = false;
            fill([t(startIdx) t(endIdx) t(endIdx) t(startIdx)], ...
                 [min(val) min(val) max(val) max(val)], colorRGB, ...
                 'FaceAlpha', alphaVal, 'EdgeColor','none');
        end
    end
    % Se termina in intervallo
    if inInterval
        fill([t(startIdx) t(end) t(end) t(startIdx)], ...
             [min(val) min(val) max(val) max(val)], colorRGB, ...
             'FaceAlpha', alphaVal, 'EdgeColor','none');
    end
end