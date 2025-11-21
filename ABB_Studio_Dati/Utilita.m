% Perfetto, ti spiego in dettaglio perché e come la FFT e le heatmap possono essere utili con i tuoi dati di robot (energia, potenza, accelerazioni).
% 
%% 1️⃣ FFT (Fast Fourier Transform)
% Cosa fa:
% 
% La FFT trasforma un segnale dal dominio del tempo al dominio della frequenza. In altre parole, ti dice quali frequenze sono presenti in un segnale e con quale ampiezza.
% 
% Applicazione ai tuoi dati:
% 
% I tuoi segnali sono tempo vs accelerazione o potenza dei robot.
% 
% La FFT ti permette di capire se ci sono oscillazioni periodiche o vibrazioni nei robot.
% 
% Esempi pratici:
% 
% Se un robot vibra ad una certa frequenza durante l’operazione, la FFT lo mostra come picco a quella frequenza.
% 
% Puoi confrontare i due robot e vedere se uno ha più “rumore” o vibrazioni rispetto all’altro.
% 
% Utile per analisi di manutenzione predittiva o verifica della stabilità del robot.
% 
% Come interpretarla:
% 
% Sull’asse X: frequenza (Hz)
% 
% Sull’asse Y: ampiezza del segnale a quella frequenza
% 
% Picchi alti → presenza significativa di oscillazioni a quella frequenza
% 
%% 2️⃣ Heatmap
% Cosa fa:
% 
% La heatmap rappresenta i dati come una matrice di colori, dove:
% 
% Asse X = tempo
% 
% Asse Y = colonne/variabili (energia, potenza, accelerazioni)
% 
% Colore = valore della grandezza
% 
% Applicazione ai tuoi dati:
% 
% Visualizzi rapidamente come cambiano tutti i valori nel tempo.
% 
% Rende facile individuare:
% 
% Picchi improvvisi
% 
% Pattern periodici
% 
% Zone di valori bassi o alti
% 
% Confronto immediato tra File1 e File2:
% 
% Vedi se i due robot hanno comportamenti simili o differenze marcate in certe colonne o periodi di tempo
% 
% Esempio pratico:
% 
% Heatmap delle accelerazioni → puoi subito vedere se un robot ha accelerazioni più intense o più frequenti in alcune fasi.
% 
% 💡 In sintesi:
% 
% FFT = analisi in frequenza → per vedere vibrazioni, oscillazioni e periodicità.
% 
% Heatmap = visualizzazione rapida dei dati nel tempo → per pattern, picchi e confronti tra variabili.