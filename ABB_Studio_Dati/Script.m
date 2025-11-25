%% --- Seleziona cartella ---
clear all; clc; close all;
folderPath = uigetdir(pwd,'Seleziona la cartella con i dati');
if folderPath == 0
    error('Cartella non selezionata');
end

% Trova i file Excel
files = dir(fullfile(folderPath,'*.xlsx'));
if length(files) < 2
    error('Serve almeno 2 file Excel nella cartella');
end

% Prendi i primi due file
file1Path = fullfile(folderPath, files(1).name);
file2Path = fullfile(folderPath, files(2).name);

%% --- Leggi i file Excel ---
file1 = readmatrix(file1Path);
file2 = readmatrix(file2Path);

%% --- Estrazione tempo ---
tempo1 = file1(:,1);
tempo2 = file2(:,1);

%% --- Colonne da considerare ---
colNames = {'Tempo','Energia','Potenza Motore','AL IRB4600 - 40','AL IRB - Diverso'};
colsToKeep = 2:size(file1,2);
nCol = length(colsToKeep);
colNamesData = colNames(colsToKeep);

%% ===================================================================
%% 1) SERIE TEMPORALI SU TEMPI ORIGINALI (NESSUNA INTERSEZIONE)
%% ===================================================================

yLabels = {'[J]', '[W]', '[mm/s^2]', '[mm/s^2]'};

figure('Name','Confronto Serie Temporali','NumberTitle','off');

for idx = 1:nCol
    c = colsToKeep(idx);
    subplot(ceil(nCol/2),2,idx);

    dati1 = file1(:,c);
    dati2 = file2(:,c);

    % --- Filtra valori anomali estremi (1°-99° percentile)
    lowerLim = prctile([dati1; dati2], 1);
    upperLim = prctile([dati1; dati2], 99);
    dati1(dati1 < lowerLim | dati1 > upperLim) = NaN;
    dati2(dati2 < lowerLim | dati2 > upperLim) = NaN;

    plot(tempo1, dati1, '-o', 'LineWidth', 1); hold on;
    plot(tempo2, dati2, '-x', 'LineWidth', 1);

    xlabel('Tempo [s]');
    ylabel(yLabels{idx});
    legend('Cella Lineare','Cella U','Location','best');
    title(colNamesData{idx});
    grid on;

    % CONTEGGIO SUPERAMENTI SOGLIA PER LA POTENZA
    if idx == 2   % <-- colonna 3 = Potenza
        soglia = 3000;

        count1 = sum(dati1 > soglia);
        count2 = sum(dati2 > soglia);

        fprintf('\n=== SUPERAMENTI SOGLIA POTENZA (>%d W) ===\n', soglia);
        fprintf('Cella Lineare: %d volte\n', count1);
        fprintf('Cella U      : %d volte\n\n', count2);
    end
end

sgtitle('Confronto colonne tra Cella Lineare e Cella U');


%% ===================================================================
%% 2) BOXPLOT CON WHISKER AL MIN E MAX REALE (solo Energia e Potenza)
%% ===================================================================

figure('Name','Boxplot E & P','NumberTitle','off');

colsBox = [2 3]; % Energia e Potenza
yLabelsBox = {'[J]', '[W]'};

for idx = 1:length(colsBox)
    c = colsBox(idx);
    subplot(1,length(colsBox),idx);

    dati1 = file1(:,c);
    dati2 = file2(:,c);

    % --- Filtra anomalie estremamente rare (0.5°-99.5° percentile)
    p_lower = prctile([dati1; dati2],0.5);
    p_upper = prctile([dati1; dati2],99.5);
    dati1_filt = dati1; dati2_filt = dati2;
    dati1_filt(dati1 < p_lower | dati1 > p_upper) = NaN;
    dati2_filt(dati2 < p_lower | dati2 > p_upper) = NaN;

    % Rimuove NaN
    dati1_filt = dati1_filt(~isnan(dati1_filt));
    dati2_filt = dati2_filt(~isnan(dati2_filt));

    % Concatenazione dati e definizione gruppi
    dati_comb = [dati1_filt; dati2_filt];
    gruppi = [repmat({'Cella Lineare'}, length(dati1_filt),1);
              repmat({'Cella U'}, length(dati2_filt),1)];

    % Statistiche e stampa su Command Window
    fprintf('Colonna: %s\n', colNamesData{c-1});
    fprintf('  Cella Lineare -> Mean: %.3f, Q25: %.3f, Median: %.3f, Q75: %.3f, Min: %.3f, Max: %.3f\n', ...
            mean(dati1_filt), prctile(dati1_filt,25), median(dati1_filt), prctile(dati1_filt,75), min(dati1_filt), max(dati1_filt));
    fprintf('  Cella U -> Mean: %.3f, Q25: %.3f, Median: %.3f, Q75: %.3f, Min: %.3f, Max: %.3f\n', ...
            mean(dati2_filt), prctile(dati2_filt,25), median(dati2_filt), prctile(dati2_filt,75), min(dati2_filt), max(dati2_filt));

    % Boxplot con whisker al min/max filtrati
    boxplot(dati_comb, gruppi, 'whisker', Inf, 'Symbol','');

    title([colNames{c}]);
    ylabel(yLabelsBox{idx});
    xlabel('Tempo [s]');
    grid on;
end

sgtitle('Boxplot Energia e Potenza filtrati');

%% ===================================================================
%% 3) ZONE DI VARIAZIONE RAPIDA DELLE ACCELERAZIONI (WINDOW ~60s)
%% ===================================================================

accCols = nCol-1:nCol;  % ultime 2 colonne
accNames = colNamesData(accCols);
window_size = 1948;  % circa 60 secondi

% ====== NUOVO: divisione in finestre da 500 secondi ======
window_sec = 500;  
t_min = min([tempo1(1) tempo2(1)]);
t_max = max([tempo1(end) tempo2(end)]);
edges = t_min:window_sec:t_max;  
nSegments = length(edges)-1;

% ====== Precalcolo filtraggio e derivate (come il tuo codice) ======
dati1_all = cell(1,length(accCols));
dati2_all = cell(1,length(accCols));
deriv1_all = cell(1,length(accCols));
deriv2_all = cell(1,length(accCols));
thresh1_all = zeros(1,length(accCols));
thresh2_all = zeros(1,length(accCols));

for k = 1:length(accCols)
    c = accCols(k);

    d1 = file1(:,c); d2 = file2(:,c);
    datiAll = [d1; d2];
    lowerLim = prctile(datiAll,1);
    upperLim = prctile(datiAll,99);

    d1(d1 < lowerLim | d1 > upperLim) = NaN;
    d2(d2 < lowerLim | d2 > upperLim) = NaN;

    deriv1 = movmean([0; diff(d1)], window_size, 'omitnan');
    deriv2 = movmean([0; diff(d2)], window_size, 'omitnan');

    thresh1 = 3*nanstd(deriv1);
    thresh2 = 3*nanstd(deriv2);

    dati1_all{k} = d1;
    dati2_all{k} = d2;
    deriv1_all{k} = deriv1;
    deriv2_all{k} = deriv2;
    thresh1_all(k) = thresh1;
    thresh2_all(k) = thresh2;
end


% ====== NUOVO: plot suddiviso in finestre ======
for seg = 1:nSegments

    t_start = edges(seg);
    t_end   = edges(seg+1);

    figure('Name', sprintf('Accelerazioni rapide - Finestra %d (%.0f-%.0f s)', ...
           seg, t_start, t_end), 'NumberTitle', 'off');

    for k = 1:length(accCols)

        d1 = dati1_all{k};
        d2 = dati2_all{k};
        deriv1 = deriv1_all{k};
        deriv2 = deriv2_all{k};
        thresh1 = thresh1_all(k);
        thresh2 = thresh2_all(k);

        fast1 = abs(deriv1) > thresh1;
        fast2 = abs(deriv2) > thresh2;

        subplot(length(accCols),1,k); hold on;

        % -------- Filtra indici nella finestra temporale --------
        idx1 = tempo1 >= t_start & tempo1 <= t_end;
        idx2 = tempo2 >= t_start & tempo2 <= t_end;

        % Plot segnali
        h1 = plot(tempo1(idx1), d1(idx1), 'b', 'LineWidth', 1.2);
        h2 = plot(tempo2(idx2), d2(idx2), 'r', 'LineWidth', 1.2);

        % Patch per fast1
        ylimVals = ylim;
        for i = find(idx1)'
            if fast1(i) && i < length(tempo1)
                if tempo1(i) >= t_start && tempo1(i+1) <= t_end
                    patch([tempo1(i) tempo1(i+1) tempo1(i+1) tempo1(i)], ...
                          [ylimVals(1) ylimVals(1) ylimVals(2) ylimVals(2)], ...
                          'c', 'FaceAlpha', 0.6, 'EdgeColor','c');
                end
            end
        end

        % Patch per fast2
        for i = find(idx2)'
            if fast2(i) && i < length(tempo2)
                if tempo2(i) >= t_start && tempo2(i+1) <= t_end
                    patch([tempo2(i) tempo2(i+1) tempo2(i+1) tempo2(i)], ...
                          [ylimVals(1) ylimVals(1) ylimVals(2) ylimVals(2)], ...
                          'm', 'FaceAlpha', 0.6, 'EdgeColor','m');
                end
            end
        end

        xlabel('Tempo [s]');
        ylabel('Accelerazione [mm/s^2]');
        title(sprintf('%s (%.0f–%.0f s)', accNames{k}, t_start, t_end));
        legend([h1 h2], {'Cella Lineare','Cella U'},'Location','best');
        grid on;
    end
end

sgtitle('Zone di accelerazione rapida (finestre da 500 s)');
