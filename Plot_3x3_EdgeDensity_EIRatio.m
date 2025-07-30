function Plot_3x3_EdgeDensity_EIRatio()
    load('Results_EdgeDensity_EISweep.mat');

    networkTypes = unique(string({Results(:,1,1).Network}));
    eiSteps = size(Results, 2);
    paramSteps = size(Results, 3);

    figure('Position', [100, 100, 1800, 1000]);
    t = tiledlayout(3, 3, 'Padding', 'compact', 'TileSpacing', 'compact');

    for i = 1:numel(networkTypes)
        net = networkTypes(i);

        % Extract parameter values and E/I ratios
        netIdx = find(strcmp(string({Results(:,1,1).Network}), net), 1);
        eiRatios = [Results(netIdx,:,1).EIRatio];
        paramVals = [Results(netIdx,1,:).Param];

        % Extract Mean INT matrix
        Z = nan(paramSteps, eiSteps);
        for ei = 1:eiSteps
            for p = 1:paramSteps
                match = strcmp(string({Results(:,ei,p).Network}), net);
                if any(match)
                    Z(p, ei) = Results(find(match, 1), ei, p).MeanINT;
                end
            end
        end

        %% 1. Surface Plot
        nexttile((i-1)*3 + 1);
        surf(eiRatios, paramVals, Z, 'EdgeColor', 'none');
        view(-135, 30);
        xlabel('E/I Ratio');
        ylabel(getXLabel(net));
        zlabel('Mean INT');
        title(sprintf('Surface: %s', net));
        set(gca, 'XDir', 'reverse', 'YDir', 'normal');
        colorbar;

        %% 2. Slice: INT vs Edge Density Param (at fixed E/I)
        nexttile((i-1)*3 + 2);
        ei_target = 0.5;
        [~, ei_idx] = min(abs(eiRatios - ei_target));
        y = Z(:, ei_idx);
        plot(paramVals, y, '-o'); hold on;
        if sum(~isnan(y)) > 2
            pfit = polyfit(paramVals(~isnan(y)), y(~isnan(y)), 1);
            plot(paramVals, polyval(pfit, paramVals), '--r');
            r = manual_corr(paramVals(~isnan(y)), y(~isnan(y)));
        else
            r = NaN;
        end
        xlabel(getXLabel(net)); ylabel('Mean INT');
        title(sprintf('%s: INT vs %s (E/I = %.2f)\nr = %.2f', ...
            net, getXLabel(net), ei_target, r));
        grid on;

        %% 3. Slice: INT vs E/I Ratio (at fixed param)
        nexttile((i-1)*3 + 3);
        param_target = median(paramVals);
        [~, p_idx] = min(abs(paramVals - param_target));
        y = Z(p_idx, :);
        plot(eiRatios, y, '-o'); hold on;
        if sum(~isnan(y)) > 2
            pfit = polyfit(eiRatios(~isnan(y)), y(~isnan(y)), 1);
            plot(eiRatios, polyval(pfit, eiRatios), '--r');
            r = manual_corr(eiRatios(~isnan(y)), y(~isnan(y)));
        else
            r = NaN;
        end
        xlabel('E/I Ratio'); ylabel('Mean INT');

        % Label formatting based on network type
        if net == "ER"
            param_fmt = '%.2f';
        else
            param_fmt = '%.0f';
        end

        title(sprintf('%s: INT vs E/I (%s %s)\nr = %.2f', ...
            net, sprintf(param_fmt, param_target), getXLabel(net), r));
        grid on;
    end

    sgtitle('INT Relationships Across Network Types (Edge Density × E/I Ratio)');
    saveas(gcf, 'INT_3x3_EdgeDensity_EIRatio_CorrectedAxes.png');
end

function label = getXLabel(net)
    switch net
        case "BA"
            label = 'M (Edges per New Node)';
        case "ER"
            label = 'p (Connection Probability)';
        case "WS"
            label = 'k (Nearest Neighbors)';
        otherwise
            label = 'Edge Density Param';
    end
end

function r = manual_corr(x, y)
    x = x(:); y = y(:);
    x = x - mean(x);
    y = y - mean(y);
    r = sum(x .* y) / sqrt(sum(x.^2) * sum(y.^2));
end
