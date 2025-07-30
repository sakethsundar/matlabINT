function [MeanINT, r] = RunSimulation(NetworkType, Alpha, AddNodeSize, NumExp, EIRatio)

    INT_All = nan(NumExp, AddNodeSize);

    parfor iteAddNode = 1:AddNodeSize  % Parallelizing
        try
            N0 = 10;
            NumAddNode = 89 + iteAddNode;
            M = 10;
            NumNode = N0 + NumAddNode;

            % Generate network based on type
            switch NetworkType
                case "BA"
                    A = BAmodel(N0, NumAddNode, M);
                case "ER"
                    p = 2 * M / NumNode;
                    A = ERmodel(NumNode, p);
                case "WS"
                    k = 2 * M;
                    beta = 0.1;
                    A = WSmodel(NumNode, k, beta);
            end

            % Apply E/I balance
            A = AddEIBalanceByNode(A, EIRatio);
            assert(~issymmetric(A), 'Network should be asymmetric');
            epsilon = 0.3;
            NumSample = 1;
            Omega = (rand(NumNode, 1) - 0.5);
            dt = 0.01;
            NumRepeat = 1000;

            for iteExp = 1:NumExp
                x_state = zeros(NumNode, NumSample);
                X_List = nan(NumNode, NumRepeat);

                for iteRep = 1:NumRepeat
                    Noise = (rand(NumNode, 1) - 0.5) * Alpha;
                    dxdt = SinOscillatorWithNoise01(x_state, A, epsilon, NumSample, Omega, Noise);
                    x_state = x_state + dxdt * dt;
                    X_List(:, iteRep) = x_state;
                end

                % Compute INT
                Pi_List = floor(X_List / (2 * pi));
                Binary_List = [zeros(size(Pi_List, 1), 1), diff(Pi_List, 1, 2) ~= 0];
                AvgBinary = mean(Binary_List, 1);
                [STS, ~, ~, ~] = AutoCorrFactor_tw01(AvgBinary, dt);

                INT_All(iteExp, iteAddNode) = STS;
            end

        catch ME
            warning('Error at AddNode=%d: %s', iteAddNode, ME.message);
        end
    end

    % Final INT average/corr
    MeanINT = mean(INT_All, 'omitnan');
    x_vals = (1:AddNodeSize) + 89;

    if all(~isnan(MeanINT))
        r = manual_corr(x_vals, MeanINT);
    else
        r = NaN;
    end

end
