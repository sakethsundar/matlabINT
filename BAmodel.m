function OutPutA = BAmodel(N0, NumAddNode, M)
% BAmodel - Generates a Barabási–Albert scale-free network.
% N0         = initial fully connected nodes
% NumAddNode = number of nodes to add
% M          = number of edges each new node forms

    % Initialize with a fully connected graph of N0 nodes
    A_temp = ones(N0, N0) - diag(ones(1, N0));

    for add_node = 1:NumAddNode
        A_temp_add_row = zeros(1, size(A_temp, 1) + 1);
        Degree_temp = sum(A_temp, 1);

        % First connection
        SelectedNode = Ratio2Prob(Degree_temp');
        A_temp_add_row(SelectedNode) = 1;
        Degree_temp(SelectedNode) = 0;

        % Remaining M-1 connections
        for ite = 1:M-1
            NextSelectedNode = Ratio2Prob(Degree_temp');
            A_temp_add_row(NextSelectedNode) = 1;
            Degree_temp(NextSelectedNode) = 0;
        end

        % Update adjacency matrix
        NumNode_temp = size(A_temp, 1);
        A_temp_new = zeros(NumNode_temp + 1);
        A_temp_new(1:NumNode_temp, 1:NumNode_temp) = A_temp;
        A_temp_new(NumNode_temp + 1, :) = A_temp_add_row;
        A_temp_new(:, NumNode_temp + 1) = A_temp_add_row';
        A_temp = A_temp_new;
    end

    OutPutA = A_temp;
end

%% Supporting function used in BAmodel
function selected = Ratio2Prob(degrees)
    degrees(degrees < 0) = 0;         % Sanitize
    prob = degrees / sum(degrees);   % Convert to probabilities
    cumprob = cumsum(prob);
    r = rand;
    selected = find(r <= cumprob, 1, 'first');
end
