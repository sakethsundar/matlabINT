function RunEdgeDensity_EISweep()
    %% Settings
    NetworkTypes = ["BA", "ER", "WS"];
    EIRatios = 0.05:0.1:0.95;
    EdgeDensities = 2:2:46;  % M for BA, maps to p or k for others
    NumNodes = 100;
    NumExp = 10;
    Alpha = 100;

    Results = struct();

    %% Start parallel pool if needed
    if isempty(gcp('nocreate'))
        parpool('local');
    end

    %% Main sweep
    for iNet = 1:length(NetworkTypes)
        netType = NetworkTypes(iNet);
        fprintf('\n🔁 %s network sweep...\n', netType);

        for iEI = 1:length(EIRatios)
            eiRatio = EIRatios(iEI);

            for iM = 1:length(EdgeDensities)
                M = EdgeDensities(iM);
                INTs = nan(1, NumExp);

                parfor j = 1:NumExp
                    try
                        % Generate network
                        switch netType
                            case "BA"
                                A = BAmodel(10, NumNodes - 10, M);
                                param = M;
                            case "ER"
                                p = 2 * M / NumNodes;
                                A = ERmodel(NumNodes, p);
                                param = p;
                            case "WS"
                                k = 2 * M;
                                beta = 0.1;
                                A = WSmodel(NumNodes, k, beta);
                                param = k;
                        end

                        % Apply E/I balance
                        A = AddEIBalanceByNode(A, eiRatio);
                        assert(~issymmetric(A), 'Network should be asymmetric');

                        % Simulate oscillator dynamics
                        epsilon = 0.3;
                        NumSample = 1;
                        Omega = (rand(NumNodes, 1) - 0.5);
                        dt = 0.01;
                        NumRepeat = 1000;
                        x = zeros(NumNodes, NumSample);
                        X_List = nan(NumNodes, NumRepeat);

                        for t = 1:NumRepeat
                            Noise = (rand(NumNodes, 1) - 0.5) * Alpha;
                            dxdt = SinOscillatorWithNoise01(x, A, epsilon, NumSample, Omega, Noise);
                            x = x + dxdt * dt;
                            X_List(:, t) = x;
                        end

                        Pi = floor(X_List / (2 * pi));
                        Binary = [zeros(size(Pi, 1), 1), diff(Pi, 1, 2) ~= 0];
                        AvgBinary = mean(Binary, 1);
                        [INT, ~, ~, ~] = AutoCorrFactor_tw01(AvgBinary, dt);
                        INTs(j) = INT;

                    catch ME
                        warning('❌ Failed at %s (E/I=%.2f, Param=%.2f): %s', ...
                            netType, eiRatio, M, ME.message);
                    end
                end
                switch netType
                    case "BA"
                        param = M;
                    case "ER"
                        param = 2 * M / NumNodes;
                    case "WS"
                        param = 2 * M;
                end

                % Store results
                Results(iNet, iEI, iM).Network = netType;
                Results(iNet, iEI, iM).EIRatio = eiRatio;
                Results(iNet, iEI, iM).Param = param;
                Results(iNet, iEI, iM).MeanINT = mean(INTs, 'omitnan');
                Results(iNet, iEI, iM).AllINT = INTs;
            end
        end
    end

    %% Save output
    save('Results_EdgeDensity_EISweep.mat', 'Results');
    fprintf('\n✅ Saved combined sweep results to Results_EdgeDensity_EISweep.mat\n');
end
