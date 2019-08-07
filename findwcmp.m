function [p, r] = findwcmp(A)
    [m, n] = size(A);
    N = m * n;
    K = reshape(1 : N, m, n);
    East = [(K(:, 2 : n) .* (A(:, 1 : n - 1) & A (:, 2 : n))), zeros(m,1)];
    E = find(East);
    South = [(K(2 : m, :) .* (A(1 : m - 1, :) & A (2 : m, :))); zeros(1, n)];
    S = find(South);

    G = sparse([K(E); K(S)], [East(E); South(S)], 1, N, N);
    G = G + G' + speye(N);
    [p, ~, r, ~] = dmperm(G);
    nc = length(r) - 1;
    [~, i] = sortrows([diff(r)', double(A(p(r(1:end-1)))')], [-1, -2]);
    
    p2 = zeros(1, N);
    r2 = zeros(1, nc + 1);
    k2 = 0;
    k = 1;
    while true
        c = i(k);
        if ~A(p(r(c)))
            break;
        end
        nodes = p(r(c) : r(c + 1) - 1);
        csize = length(nodes);
        p2(k2 + 1 : k2 + csize) = nodes;
        r2(k) = k2 + 1;
        k2 = k2 + csize;
        k = k + 1;
    end
    p = p2(logical(p2));
    r2(k + 1) = length(p) + 1;
    r = r2(logical(r2));