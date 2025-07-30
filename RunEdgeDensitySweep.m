function RunEdgeDensitySweep()
    %% Settings
    NetworkTypes = ["BA", "ER", "WS"];
    NumNodes = 100;
    MValues = 2:2:20;          % Controls average degree (edge density)
    NumExp = 10;
    Alpha = 100;
    EIRatio = 0.8;

    Results = struct();

    %% Start parallel pool if needed
    if isempty(gcp('nocreate'))
        parpool('local');  % Adjust if needed
    end

    for iNet = 1:length(NetworkTypes)
        netType = NetworkTypes(iNet);
        fprintf('\nRunning %s network edge density sweep...\n', netType);

        for iM = 1:length(MValues)
            M = MValues(iM);
            INTs = nan(1, NumExp);

            % Run experiments in parallel
            parfor j = 1:NumExp
                try
                    switch netType
                        case "BA"
                            A = BAmodel(10, NumNodes - 10, M);
                        case "ER"
                            p = 2 * M / NumNodes;
                            A = ERmodel(NumNodes, p);
                        case "WS"
                            k = 2 * M;
                            beta = 0.1;
                            A = WSmodel(NumNodes, k, beta);
                    end

                    A = AddEIBalanceByNode(A, EIRatio);
                    assert(~issymmetric(A), 'Network should be asymmetric');

                    % Oscillator sim
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
                    warning('Failed at %s M=%d: %s', netType, M, ME.message);
                end
            end

            % Save results
            Results(iNet, iM).Network = netType;
            Results(iNet, iM).M = M;
            Results(iNet, iM).MeanINT = mean(INTs, 'omitnan');
            Results(iNet, iM).AllINT = INTs;
        end
    end

    save('Results_EdgeDensitySweep.mat', 'Results');
    fprintf('\n✅ Edge density sweep complete. Results saved.\n');
end
