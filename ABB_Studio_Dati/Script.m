%% --- SCRIPT DI CONFRONTO COLONNE CON TEMPO INGRESSO ---
clear all;
load('miei_dati.mat');  % ricarica Data1 e Data2

% --- Inizio script ---
file1 = Data1; % sostituire con il nome reale
file2 = Data2;

% Conversione in array numerici
file1 = convertArrayToNumeric(file1);
file2 = convertArrayToNumeric(file2);

% Estrazione tempo (colonna 1)
tempo1 = file1(:,1);
tempo2 = file2(:,1);

% --- Allineamento file2 sui tempi di file1 ---
if length(tempo1) ~= length(tempo2) || any(tempo1 ~= tempo2)
    file2_interp = zeros(length(tempo1), size(file2,2));
    file2_interp(:,1) = tempo1; % tempo allineato

    for k = 2:size(file2,2)
        file2_interp(:,k) = interp1(tempo2, file2(:,k), tempo1, 'linear', 'extrap');
    end

    file2 = file2_interp; % ora file2 ha la stessa dimensione di file1
    tempo2 = tempo1;      % allineiamo tempo2
end

%% Escludiamo le colonne 4 e 7 (colonne da scartare)
% Nomi colonne
colNames = {'Energia Totale','Potenza Motore','Max.Acc LineareR1','Massima Accelerazione in Lineare IRB1','ColD', 'Massima Accelerazione Lineare in Universale IRB4600 40'};

colsToKeep = setdiff(2:length(colNames), [4,7]);  % 2 perché colonna 1 = tempo
colNamesData = colNames(colsToKeep);
nCol = length(colNamesData);

% --- Plot serie temporali ---  
figure;
for idx = 1:nCol
    c = colsToKeep(idx);  % colonna reale nel file
    subplot(ceil(nCol/2),2,idx);
    plot(tempo1, file1(:,c), '-o'); hold on;
    plot(tempo1, file2(:,c), '-x');
    xlabel('Tempo'); ylabel('Valore');
    legend('File1','File2');
    title(colNames{c}); 
    grid on;
end
sgtitle('Confronto colonne tra file1 e file2');


%% --- Analisi aggiuntiva: Medie, Massimi e Picchi ---

% Preallocazione
mediaFile1 = zeros(1,nCol);
mediaFile2 = zeros(1,nCol);
maxFile1   = zeros(1,nCol);
maxFile2   = zeros(1,nCol);

% Calcolo medie e massimi
for c = 1:nCol
    col1 = file1(:,c+1);
    col2 = file2(:,c+1);
    
    mediaFile1(c) = mean(col1);
    mediaFile2(c) = mean(col2);
    
    maxFile1(c) = max(col1);
    maxFile2(c) = max(col2);
end

%% --- Grafico medie e massimi ---
figure('Name','Statistiche Medie e Massimi','NumberTitle','off');

% Media
subplot(2,1,1);
bar([mediaFile1; mediaFile2]');
set(gca,'XTickLabel', colNamesData);
ylabel('Valore medio');
legend('File1','File2');
title('Confronto valori medi');
grid on;

% Massimo
subplot(2,1,2);
bar([maxFile1; maxFile2]');
set(gca,'XTickLabel', colNamesData);
ylabel('Valore massimo');
legend('File1','File2');
title('Confronto valori massimi');
grid on;

%% --- Analisi aggiuntiva: Valori medi e picchi massimi ---

% Preallocazione
mediaFile1 = zeros(1,nCol);
mediaFile2 = zeros(1,nCol);
maxFile1   = zeros(1,nCol);
maxFile2   = zeros(1,nCol);

% Calcolo medie e picchi massimi
for c = 1:nCol
    col1 = file1(:,c+1);
    col2 = file2(:,c+1);
    
    mediaFile1(c) = mean(col1);
    mediaFile2(c) = mean(col2);
    
    [maxFile1(c), idx1] = max(col1); % picco massimo File1
    [maxFile2(c), idx2] = max(col2); % picco massimo File2
end

%% --- Grafico medie e massimi ---
figure('Name','Statistiche Medie e Massimi','NumberTitle','off');

% Media
subplot(2,1,1);
bar([mediaFile1; mediaFile2]');
set(gca,'XTickLabel', colNamesData);
ylabel('Valore medio');
legend('File1','File2');
title('Confronto valori medi');
grid on;

% Picchi massimi
subplot(2,1,2);
bar([maxFile1; maxFile2]');
set(gca,'XTickLabel', colNamesData);
ylabel('Valore massimo');
legend('File1','File2');
title('Confronto picchi massimi');
grid on;

%% --- Grafico serie con picchi massimi evidenziati ---
figure('Name','Picchi massimi colonne','NumberTitle','off');

for c = 1:nCol
    subplot(ceil(nCol/2),2,c);
    
    col1 = file1(:,c+1);
    col2 = file2(:,c+1);
    
    % Trova indice del picco massimo
    [pks1, idx1] = max(col1);
    [pks2, idx2] = max(col2);
    
    % Plotta serie temporali
    plot(tempo1, col1, '-o'); hold on;
    plot(tempo1, col2, '-x');
    
    % Evidenzia picchi massimi
    plot(tempo1(idx1), pks1, 'ro', 'MarkerFaceColor','r', 'MarkerSize',8);
    plot(tempo1(idx2), pks2, 'go', 'MarkerFaceColor','g', 'MarkerSize',8);
    
    xlabel('Tempo'); ylabel('Valore');
    legend('File1','File2','Picco massimo File1','Picco massimo File2');
    title(colNamesData{c});
    grid on;
end
sgtitle('Picchi massimi per ciascuna colonna');

x=100;
