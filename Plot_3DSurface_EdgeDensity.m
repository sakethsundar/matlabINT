function Plot_3x3_EdgeDensity_EIRatio()

    load('Results_EdgeDensity_EISweep.mat');

    networkTypes = unique(string({Results(:,1,1).Network}));
    edgeSteps = size(Results, 3);
    eiSteps = size(Results, 2);

    % Get edge density and E/I axis values from one network for consistency
    params = squeeze([Results(1,1,:).Param]);
    eiRatios = squeeze([Results(1,:,1).EIRatio]);

    figure('Position', [100, 100, 1800, 1000]);
    t = tiledlayout(3, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

    for i = 1:numel(networkTypes)
        net = networkTypes(i);

        % Extract Z matrix (MeanINT)
        Z = nan(edgeSteps, eiSteps);
        for ei = 1:eiSteps
            for p = 1:edgeSteps
                netMatch = strcmp(string({Results(:,ei,p).Network}), net);
                if any(netMatch)
                    Z(p, ei) = Results(find(netMatch,1), ei, p).MeanINT;
                end
            end
        end

        % 1. 3D Surface Plot
        nexttile((i-1)*3 + 1);
        surf(eiRatios, params, Z, 'EdgeColor', 'none');
        view(45, 30);
        xlabel('E/I Ratio');
        ylabel(getXLabel(net));
        zlabel('Mean INT');
        title(sprintf('Surface: %s', net));
        colorbar;

        % 2. Slice: INT vs Edge Density at fixed E/I
        nexttile((i-1)*3 + 2);
        ei_target = 0.5;
        [~, ei_idx] = min(abs(eiRatios - ei_target));
        y = Z(:, ei_idx);
        plot(params, y, '-o');
        hold on;
        if sum(~isnan(y)) > 2
            pfit = polyfit(params(~isnan(y)), y(~isnan(y)), 1);
            plot(params, polyval(pfit, params), '--r');
            r = corrcoef(params(~isnan(y)), y(~isnan(y)));
            r = r(1,2);
        else
            r = NaN;
        end
        title(sprintf('%s: INT vs %s (E/I=%.2f)\nr = %.2f', net, getXLabel(net), ei_target, r));
        xlabel(getXLabel(net));
        ylabel('Mean INT');
        grid on;

        % 3. Slice: INT vs E/I at fixed Param
        nexttile((i-1)*3 + 3);
        param_target = median(params);
        [~, param_idx] = min(abs(params - param_target));
        y = Z(param_idx, :);
        plot(eiRatios, y, '-o');
        hold on;
        if sum(~isnan(y)) > 2
            pfit = polyfit(eiRatios(~isnan(y)), y(~isnan(y)), 1);
            plot(eiRatios, polyval(pfit, eiRatios), '--r');
            r = corrcoef(eiRatios(~isnan(y)), y(~isnan(y)));
            r = r(1,2);
        else
            r = NaN;
        end
        title(sprintf('%s: INT vs E/I (%.0f %s)\nr = %.2f', net, param_target, getXLabel(net), r));
        xlabel('E/I Ratio');
        ylabel('Mean INT');
        grid on;
    end

    sgtitle('INT Relationships Across Network Types (Edge Density & E/I Ratio)');
    saveas(gcf, 'INT_3x3_EdgeDensity_EIRatio.png');
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
