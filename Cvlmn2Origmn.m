function Origmn = Cvlmn2Origmn(Cvlmn, Bm, Bn, shape)
    Origmn = zeros(size(Cvlmn));
    if strcmp(shape, 'full') || ~exist('shape', 'var') || isempty(shape)
        Origmn(:, 1) = Cvlmn(:, 1) - floor(Bm / 2);
        Origmn(:, 2) = Cvlmn(:, 2) - floor(Bn / 2);
    end
    if strcmp(shape, 'same')
        Origmn(:, 1) = Cvlmn(:, 1);
        Origmn(:, 2) = Cvlmn(:, 2);
    end
    if strcmp(shape, 'valid')
        Origmn(:, 1) = Cvlmn(:, 1) + floor(Bm / 2);
        Origmn(:, 2) = Cvlmn(:, 2) + floor(Bn / 2);
    end