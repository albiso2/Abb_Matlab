function [tempo_uni, dati_uni] = collapse_duplicates(tempo, dati)
    % Collassa tempi duplicati calcolando la media dei valori corrispondenti
    [tempo_uni, ~, ic] = unique(tempo);  % tempi unici
    dati_uni = zeros(length(tempo_uni),1);
    for i = 1:length(tempo_uni)
        dati_uni(i) = mean(dati(ic==i));
    end
end
