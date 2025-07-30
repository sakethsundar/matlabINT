function Plot_NodeCount_EIRatioSweep()
    load('Results_EIBalanceSweep.mat');

    % Network types and filtered E/I ratios (0.1 steps only)
    netTypes = unique(string({Results(:,1).Network}));
    allRatios = [Results(1,:).EIRatio];
    eiRatios = unique(round(allRatios * 10) / 10);
    eiRatios = eiRatios(mod(eiRatios * 10, 1) == 0);  % only 0.1, 0.2, ..., 0.9, 1.0

    % Filter out ratios not available in all networks
    eiAvailable = true(size(eiRatios));
    for i = 1:length(eiRatios)
        for j = 1:length(netTypes)
            exists = any(abs([Results(j,:).EIRatio] - eiRatios(i)) < 1e-3);
            eiAvailable(i) = eiAvailable(i) & exists;
        end
    end
    eiRatios = eiRatios(eiAvailable);

    nodeSizes = 90:139;
    nNet = numel(netTypes);
    nEI = numel(eiRatios);

    % Create compact tiled figure
    figure('Position', [100, 100, 1800, 900]);
    t = tiledlayout(nNet, nEI, 'Padding', 'compact', 'TileSpacing', 'compact');

    for iNet = 1:nNet
        for iEI = 1:nEI
            ei_target = eiRatios(iEI);
            ei_idx = find(abs([Results(iNet,:).EIRatio] - ei_target) < 1e-3, 1);
            if isempty(ei_idx)
                continue;
            end

            INTs = Results(iNet, ei_idx).MeanINT;
            if numel(INTs) ~= numel(nodeSizes)
                INTs = nan(1, numel(nodeSizes));
            end

            nexttile;

            % Plot INT vs node size
            plot(nodeSizes, INTs, '-o', 'LineWidth', 1.2); hold on;

            % Correlation and fit
            valid = ~isnan(INTs);
            if sum(valid) >= 2
                r_val = manual_corr(nodeSizes(valid), INTs(valid));
                coeffs = polyfit(nodeSizes(valid), INTs(valid), 1);
                yfit = polyval(coeffs, nodeSizes(valid));
                plot(nodeSizes(valid), yfit, 'r--', 'LineWidth', 1);
            else
                r_val = NaN;
            end

            title(sprintf('%s\nE/I = %.1f, r = %.2f', netTypes(iNet), ei_target, r_val), 'FontSize', 10);
            xlim([89, 140]);
            ylim([0.015, 0.075]);
            grid on;

            if iNet == nNet
                xlabel('Number of Nodes');
            end
            if iEI == 1
                ylabel('Mean INT');
            end
        end
    end

    sgtitle('INT vs. Node Count across Networks and E/I Ratios (Filtered)', 'FontSize', 14);
    saveas(gcf, 'INT_vs_NodeCount_EIRatioSweep_Subplots_Filtered_Compact.png');
end

function r = manual_corr(x, y)
    x = x(:); y = y(:);
    x = x - mean(x);
    y = y - mean(y);
    r = sum(x .* y) / sqrt(sum(x.^2) * sum(y.^2));
end
