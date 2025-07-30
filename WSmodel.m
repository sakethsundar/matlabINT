function A = WSmodel(n, k, beta)
% WSmodel - Generates a Watts–Strogatz small-world network.
% n    = number of nodes
% k    = number of neighbors each node is connected to (must be even)
% beta = rewiring probability

    if mod(k,2) ~= 0
        error('k must be even');
    end

    % Step 1: Create a ring lattice
    A = zeros(n);
    half_k = k/2;
    for node = 1:n
        for neighbor = 1:half_k
            right = mod(node-1 + neighbor, n) + 1;
            left  = mod(node-1 - neighbor, n) + 1;
            A(node, right) = 1;
            A(node, left) = 1;
        end
    end

    % Step 2: Rewire edges with probability beta
    for node = 1:n
        for neighbor = 1:half_k
            current = mod(node-1 + neighbor, n) + 1;

            if rand < beta
                % Find a new node to connect to
                possible = setdiff(1:n, [find(A(node,:)), node]);  % avoid self-loops and duplicates
                new_target = possible(randi(length(possible)));

                % Rewire
                A(node, current) = 0;
                A(current, node) = 0;
                A(node, new_target) = 1;
                A(new_target, node) = 1;
            end
        end
    end
end
