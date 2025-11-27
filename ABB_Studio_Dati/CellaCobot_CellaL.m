%% ===================================================================
%% 2) BOXPLOT CON STATISTICHE REALI E SUPERAMENTI (>3000W)
%% ===================================================================

figure('Name','Boxplot E & P','NumberTitle','off');

colsBox = [2 3]; % Energia e Potenza
yLabelsBox = {'[J]', '[W]'};

for idx = 1:length(colsBox)
    c = colsBox(idx);
    subplot(1,length(colsBox),idx);

    dati1 = file1(:,c); % <-- NON filtrati
    dati2 = file2(:,c);

    % Concatenazione dati e definizione gruppi
    dati_comb = [dati1; dati2];
    gruppi = [repmat({'Cella Lineare'}, length(dati1),1);
              repmat({'Cella Cobot'}, length(dati2),1)];

    % == STATISTICHE COMPLETE (NON filtrate)
    fprintf('\n---------------------------------------------\n');
    fprintf('Colonna: %s\n', colNamesData{c-1});
    fprintf('  Cella Lineare -> Mean: %.3f, Q25: %.3f, Median: %.3f, Q75: %.3f, Min: %.3f, Max: %.3f\n', ...
            mean(dati1), prctile(dati1,25), median(dati1), prctile(dati1,75), min(dati1), max(dati1));
    fprintf('  Cella Cobot   -> Mean: %.3f, Q25: %.3f, Median: %.3f, Q75: %.3f, Min: %.3f, Max: %.3f\n', ...
            mean(dati2), prctile(dati2,25), median(dati2), prctile(dati2,75), min(dati2), max(dati2));

    % ==========================================================
    %  SUPERAMENTI SOGLIA SOLO PER LA POTENZA - STAMPA BELLA
    % ==========================================================
    if strcmp(colNames{c}, 'Potenza Motore')
        soglia = 3000;
        count1 = sum(dati1 > soglia);
        count2 = sum(dati2 > soglia);

        fprintf('\n');
        fprintf('╔═══════════════════════════════════════════╗\n');
        fprintf('║         SUPERAMENTI SOGLIA POTENZA         ║\n');
        fprintf('╠═════════════════════╦═════════════════════╣\n');
        fprintf('║ Soglia: %4d W        ║                     ║\n', soglia);
        fprintf('╠═════════════════════╬═════════════════════╣\n');
        fprintf('║ Cella Lineare       ║ %5d volte           ║\n', count1);
        fprintf('║ Cella Cobot         ║ %5d volte           ║\n', count2);
        fprintf('╚═════════════════════╩═════════════════════╝\n\n');
    end

    % ==========================================================
    %  BOXPLOT REALI (NESSUN OUTLIER RIMOSSO)
    % ==========================================================
    boxplot(dati_comb, gruppi, 'whisker', Inf, 'Symbol','');
    hold on;

    % ===========================
    %  LINEE DI MEDIA E MASSIMO
    % ===========================
    mean1 = mean(dati1);
    mean2 = mean(dati2);
    max1  = max(dati1);
    max2  = max(dati2);

    % Media (linea orizzontale)
    plot([0.7 1.3], [mean1 mean1], 'b-', 'LineWidth', 2);
    plot([1.7 2.3], [mean2 mean2], 'b-', 'LineWidth', 2);

    % Massimo (linea orizzontale rossa)
    plot([0.7 1.3], [max1 max1], 'r-', 'LineWidth', 2);
    plot([1.7 2.3], [max2 max2], 'r-', 'LineWidth', 2);

    % ===========================
    %  ETICHETTE TESTUALI
    % ===========================
    text(1.35, mean1, sprintf('Mean = %.1f', mean1), ...
         'Color','b','FontSize',8, 'HorizontalAlignment','left','BackgroundColor','w');

    text(2.35, mean2, sprintf('Mean = %.1f', mean2), ...
         'Color','b','FontSize',8,'HorizontalAlignment','left','BackgroundColor','w');

    text(1.35, max1, sprintf('Max = %.1f', max1), ...
         'Color','r','FontSize',8,'HorizontalAlignment','left','BackgroundColor','w');

    text(2.35, max2, sprintf('Max = %.1f', max2), ...
         'Color','r','FontSize',8,'HorizontalAlignment','left','BackgroundColor','w');
end

sgtitle('Boxplot Energia e Potenza - Cella Lineare vs Cella Cobot');
