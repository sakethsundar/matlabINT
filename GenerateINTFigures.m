% Load if not already loaded
if ~exist('Results', 'var')
    load('Results_Reproducibility.mat');
end

% Setup
alphas = unique([Results.Alpha]);
nets_raw = {Results.Network};  % cell array of chars
nets = unique(nets_raw, 'stable');  % e.g., {'BA', 'ER', 'WS'}

% Make heatmap matrix
heat = nan(length(nets), length(alphas));

for i = 1:length(nets)
    for j = 1:length(alphas)
        idx = strcmp(nets_raw, nets{i}) & [Results.Alpha] == alphas(j);
        if any(idx)
            heat(i, j) = mean([Results(idx).CorrR]);
        end
    end
end

%% Figure 1 — Heatmap
figure;
imagesc(heat);
colormap(parula);
colorbar;

xticks(1:length(alphas));
xticklabels(string(alphas));
yticks(1:length(nets));
yticklabels(nets);
xlabel('Noise Level (Alpha)');
ylabel('Network Type');
title('Correlation between INT and Network Size');

for i = 1:size(heat, 1)
    for j = 1:size(heat, 2)
        if ~isnan(heat(i,j))
            text(j, i, sprintf('%.2f', heat(i,j)), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'Color', 'w', 'FontWeight', 'bold');
        end
    end
end
saveas(gcf, 'Figure1_Heatmap.png');

%% Figure 2 — Line Plot: Correlation vs. Alpha
figure; hold on;
colors = lines(length(nets));

for i = 1:length(nets)
    r_vals = nan(size(alphas));
    for j = 1:length(alphas)
        idx = strcmp(nets_raw, nets{i}) & [Results.Alpha] == alphas(j);
        if any(idx)
            r_vals(j) = mean([Results(idx).CorrR]);
        end
    end
    plot(alphas, r_vals, '-o', 'DisplayName', nets{i}, ...
        'Color', colors(i,:), 'LineWidth', 2);
end

xlabel('Noise Level (Alpha)');
ylabel('Correlation (INT vs. Network Size)');
title('Reproducibility Across Networks');
legend('Location', 'northwest');
grid on;
saveas(gcf, 'Figure2_CorrelationVsNoise.png');

%% Figure 3: Mean INT vs. Network Size
figure; hold on;
for i = 1:numel(Results)
    plot(node_sizes, Results(i).MeanINT, ...
         'DisplayName', sprintf('%s, \\alpha = %d', Results(i).Network, Results(i).Alpha));
end
xlabel('Network Size');
ylabel('Mean INT');
title('INT vs. Network Size');
legend('Location', 'bestoutside');
grid on;
saveas(gcf, 'Figure3_INTvsSize.png');

%% Figure 4: Boxplot of INT Distributions
AllINTs = [];
Groups = [];

for i = 1:numel(Results)
    thisINT = Results(i).MeanINT(:);  % Fix: use MeanINT instead of missing INT
    label = repmat({sprintf('%s | \\alpha = %d', Results(i).Network, Results(i).Alpha)}, ...
                   length(thisINT), 1);
    AllINTs = [AllINTs; thisINT];
    Groups = [Groups; label];
end

figure;
boxplot(AllINTs, Groups);
xtickangle(45);
ylabel('INT');
title('INT Distribution Across Simulations');
grid on;
saveas(gcf, 'Figure4_Boxplot.png');
