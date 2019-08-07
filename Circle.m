% NewImage = Circle(OrigImage, Center_m, Center_n, InnerRadius, OuterRadius, Color)
function NewImage = Circle(OrigImage, Center_m, Center_n, InnerRadius, OuterRadius, Color)
    if ~exist('Color', 'var') || isempty(Color)
        iswhite = false;
        isblack = true;
    else
        iswhite = strcmpi(Color, 'white') || strcmpi(Color, 'w');
        isblack = strcmpi(Color, 'black') || strcmpi(Color, 'b');
        if ~iswhite && ~isblack
            error('Invalid color. Please specify either ''white''/''w'' or ''black''/''b''.');
        end
    end
    FillColor = [uint8(255), uint8(0)];
    FillColor = FillColor([iswhite, isblack]);
    
    [ColumnCoordinates, RowCoordinates] = ...
        meshgrid(1 : size(OrigImage, 2), 1 : size(OrigImage, 1));
    CircularMask = ((RowCoordinates - Center_m) .^ 2 + ...
        (ColumnCoordinates - Center_n) .^ 2 >= InnerRadius ^ 2) & ...
        ((RowCoordinates - Center_m) .^ 2 + ...
        (ColumnCoordinates - Center_n) .^ 2 <= OuterRadius ^ 2);
    OrigImage(CircularMask) = FillColor;
    NewImage = OrigImage;