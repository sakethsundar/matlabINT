function Plot_EdgeDensity_EISweep()
    load('Results_EdgeDensity_EISweep.mat');  % Load the sweep results

    netTypes = ["BA", "ER", "WS"];
    eiRatios = unique([Results(1,:,1).EIRatio]);
    numNets = numel(netTypes);
    numEIs = numel(eiRatios);

    figure('Position', [100 100 1800 800]);
    tiledlayout(numNets, numEIs, 'Padding', 'compact');

    for iNet = 1:numNets
        for iEI = 1:numEIs
            nexttile;

            INTs = [];
            params = [];

            for iM = 1:size(Results, 3)
                result = Results(iNet, iEI, iM);
                if ~isempty(result.MeanINT) && ~isnan(result.MeanINT)
                    INTs(end+1) = result.MeanINT;
                    params(end+1) = result.Param;
                end
            end

            % Plot INT vs edge density
            plot(params, INTs, '-o', 'LineWidth', 1.5, 'MarkerSize', 4);
            grid on;

            % Compute correlation
            if length(params) >= 2
                r = corrcoef(params, INTs);
                r_val = r(1,2);
            else
                r_val = NaN;
            end

            % Title with E/I and correlation
            title(sprintf('%s | E/I = %.1f\nr = %.2f', netTypes(iNet), eiRatios(iEI), r_val));

            % Y-label on first column
            if iEI == 1
                ylabel('Mean INT');
            end

            % X-axis label on every subplot (adjusted per row)
            switch netTypes(iNet)
                case "BA"
                    xlabel('M (Edges per New Node)');
                case "ER"
                    xlabel('p (Connection Probability)');
                case "WS"
                    xlabel('k (Nearest Neighbors)');
            end
        end
    end

    sgtitle('INT vs. Edge Density across Networks and E/I Ratios');
    saveas(gcf, 'INT_vs_EdgeDensity_EIRatio_Subplots.png');
end
