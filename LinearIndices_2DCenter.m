function [m_mean, n_mean] = LinearIndices_2DCenter(array, base_number, by_column)
    mod_array = mod(array, base_number);
    mod_array(~mod_array) = base_number;
    if ~exist('by_column', 'var') || isempty(by_column) || (by_column)
    % base_number is the number of rows, M
        m_mean = mean(mod_array);
        n_mean = mean(ceil(array / base_number));
    else
    % base_number is the number of columns, N
        n_mean = mean(mod_array);
        m_mean = mean(ceil(array / base_number));
    end