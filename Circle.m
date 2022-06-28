% NewImage = Circle(OrigImage, Center_m, Center_n, InnerRadius,
% OuterRadius, Color)
function NewImage = Circle(OrigImage, Center_m, Center_n, InnerRadius, ...
    OuterRadius, Color)
    if ~exist('Color', 'var') || isempty(Color)
        FillColor = uint8(0);
    else
        if isnumeric(Color) && (numel(Color) == 1) && (Color >= 0) && ...
            (Color <= 255)
            FillColor = uint8(Color);
        else
            iswhite = strcmpi(Color, 'white') || strcmpi(Color, 'w');
            isblack = strcmpi(Color, 'black') || strcmpi(Color, 'b') || ...
                strcmpi(Color, 'k');
            if ~iswhite && ~isblack
                error('Color is invalid.');
            end
            FillColor = [uint8(255), uint8(0)];
            FillColor = FillColor([iswhite, isblack]);
        end
    end
    
    [ColumnCoordinates, RowCoordinates] = ...
        meshgrid(1 : size(OrigImage, 2), 1 : size(OrigImage, 1));
    CircularMask = ((RowCoordinates - Center_m) .^ 2 + ...
        (ColumnCoordinates - Center_n) .^ 2 >= InnerRadius ^ 2) & ...
        ((RowCoordinates - Center_m) .^ 2 + ...
        (ColumnCoordinates - Center_n) .^ 2 <= OuterRadius ^ 2);
    OrigImage(CircularMask) = FillColor;
    NewImage = OrigImage;
end
