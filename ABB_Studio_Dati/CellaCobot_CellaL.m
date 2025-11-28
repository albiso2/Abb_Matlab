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
    legend('Cella Lineare','Cella Cobot','Location','best');
    title(colNamesData{idx});
    grid on;

 end

sgtitle('Confronto colonne tra Cella Lineare e Cella Cobot');

%% ===================================================================
%% 2) BOXPLOT CON STATISTICHE REALI E SUPERAMENTI (>3000W)
%% ===================================================================

figure('Name','Boxplot E & P','NumberTitle','off');

colsBox = [2 3];
yLabelsBox = {'[J]', '[W]'};

for idx = 1:length(colsBox)
    
    c = colsBox(idx);
    subplot(1,length(colsBox),idx);

    dati1 = file1(:,c);
    dati2 = file2(:,c);

    dati_comb = [dati1; dati2];
    gruppi = [repmat({'Cella Lineare'}, length(dati1),1);
              repmat({'Cella Cobot'}, length(dati2),1)];

    % === BOXPLOT REALI
    boxplot(dati_comb, gruppi, 'whisker', Inf, 'Symbol','');
    hold on;

    % ================================
    %  CALCOLO STATISTICHE (visive)
    % ================================
    mean1 = mean(dati1);   mean2 = mean(dati2);
    max1  = max(dati1);    max2  = max(dati2);

    off_mean = 0.01 * (max([dati1; dati2]) - min([dati1; dati2]));
    off_max  = 0.03 * (max([dati1; dati2]) - min([dati1; dati2]));

    plot([0.9 1.1], [max1 max1], 'r-', 'LineWidth', 1.8);
    plot([1.9 2.1], [max2 max2], 'r-', 'LineWidth', 1.8);

    text(1, max1 + off_max, sprintf('Max = %.1f', max1), ...
        'Color','r','FontSize',10,'FontWeight','bold', ...
        'HorizontalAlignment','left');

    text(2, max2 + off_max, sprintf('Max = %.1f', max2), ...
        'Color','r','FontSize',10,'FontWeight','bold', ...
        'HorizontalAlignment','left');

    ylabel(yLabelsBox{idx});
    xlabel('Gruppo');
    title(colNames{c});
    grid on;
end

sgtitle('Boxplot Energia & Potenza');

% ==========================================================
% SUPERAMENTI SOGLIA SOLO PER LA POTENZA - STAMPA BELLA
% ==========================================================
if strcmp(colNames{c}, 'Potenza Motore')
    soglia = 3000;
    count1 = sum(dati1 > soglia);
    count2 = sum(dati2 > soglia);

    fprintf('\n');
    fprintf('╔═══════════════════════════════════════════╗\n');
    fprintf('║        SUPERAMENTI SOGLIA POTENZA        ║\n');
    fprintf('╠═════════════════════╦═══════════════════╣\n');
    fprintf('║ Soglia: %4d W       ║                   ║\n', soglia);
    fprintf('╠═════════════════════╬═══════════════════╣\n');
    fprintf('║ Cella Lineare       ║ %5d volte        ║\n', count1);
    fprintf('║ Cella Cobot         ║ %5d volte        ║\n', count2);
    fprintf('╚═════════════════════╩═══════════════════╝\n\n');
end

%% ===================================================================
%% 3) ZONE DI VARIAZIONE RAPIDA DELLE ACCELERAZIONI (WINDOW ~60s)
%% ===================================================================

accCols = nCol-1:nCol;  % ultime 2 colonne
accNames = colNamesData(accCols);
window_size = 1948;  % circa 60 secondi

window_sec = 500;  
t_min = min([tempo1(1) tempo2(1)]);
t_max = max([tempo1(end) tempo2(end)]);
edges = t_min:window_sec:t_max;  
nSegments = length(edges)-1;

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

        idx1 = tempo1 >= t_start & tempo1 <= t_end;
        idx2 = tempo2 >= t_start & tempo2 <= t_end;

        h1 = plot(tempo1(idx1), d1(idx1), 'b', 'LineWidth', 1.2);
        h2 = plot(tempo2(idx2), d2(idx2), 'r', 'LineWidth', 1.2);

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
        legend([h1 h2], {'Cella Lineare','Cella Cobot'},'Location','best');
        grid on;
    end
end

sgtitle('Zone di accelerazione rapida (finestre da 500 s)');
