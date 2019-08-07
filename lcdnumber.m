% StringFig = lcdnumber(NumericString, Size, Spacer, Color)
function StringFig = lcdnumber(NumericString, Size, Spacer, Color)
    if any(~ismember(NumericString, '0123456789 '))
        error('Input string contains an invalid character.');
    end
    if ~exist('Color', 'var') || isempty(Color)
        Color = 'b';
    end
    
    Display =  [0, 0, 0, 0, 0, 0, 0; % space
                1, 1, 1, 0, 1, 1, 1; % 0
                0, 0, 0, 0, 0, 1, 1; % 1
                0, 1, 1, 1, 1, 1, 0; % 2
                0, 0, 1, 1, 1, 1, 1; % 3
                1, 0, 0, 1, 0, 1, 1; % 4
                1, 0, 1, 1, 1, 0, 1; % 5
                1, 1, 1, 1, 1, 0, 1; % 6
                0, 0, 1, 0, 0, 1, 1; % 7
                1, 1, 1, 1, 1, 1, 1; % 8
                1, 0, 1, 1, 1, 1, 1]; % 9
    %      (3)
    %    \-----/
    %    |     |
    % (1)|     |(6)
    %    |     |
    %    X-(4)-X
	%    |     |
    % (2)|     |(7)
    %    |     |
    %    /-----\
    %      (5)

    Width = Size * 5;
    Height = Size * 9;
    DiagSize = ceil(Size / 20);
    
    UpperLeft = ones(Height, Width);
    UpperLeft(1 : Size, 1 : Size) = triu(UpperLeft(1 : Size, 1 : Size), 1 - DiagSize);
    UpperLeft(Size + 1 : Size * 4, 1 : Size) = 0;
    UpperLeft(Size * 4 + 1 : Size * 5, 1 : Size) = triu(UpperLeft(Size * 4 + 1 : Size * 5, 1 : Size), DiagSize);
    UpperLeft(Size * 4 + 1 : Size * 5, 1 : Size) = fliplr(UpperLeft(Size * 4 + 1 : Size * 5, 1 : Size));
    UpperLeft(Size * 4 + 1 : Size * 5, 1 : Size) = triu(UpperLeft(Size * 4 + 1 : Size * 5, 1 : Size), DiagSize);
    UpperLeft(Size * 4 + 1 : Size * 5, 1 : Size) = ~UpperLeft(Size * 4 + 1 : Size * 5, 1 : Size);
    UpperLeft = ~UpperLeft;
        LowerLeft = flipud(UpperLeft);
        UpperRight = fliplr(UpperLeft);
        LowerRight = flipud(UpperRight);
    
    Upper = ones(Height, Width);
    Upper(1 : Size, 1 : Size) = tril(Upper(1 : Size, 1 : Size), DiagSize - 1);
    Upper(1 : Size, Size + 1 : Size * 4) = 0;
    Upper(1 : Size, Size * 4 + 1 : Width) = fliplr(Upper(1 : Size, 1 : Size));
    Upper = ~Upper;
        Lower = flipud(Upper);
    
    Middle = ones(Height, Width);
    Middle(Size * 4 + 1 : Size * 5, 1 : Size) = triu(Middle(Size * 4 + 1 : Size * 5, 1 : Size), DiagSize);
    Middle(Size * 4 + 1 : Size * 5, 1 : Size) = fliplr(Middle(Size * 4 + 1 : Size * 5, 1 : Size));
    Middle(Size * 4 + 1 : Size * 5, 1 : Size) = tril(Middle(Size * 4 + 1 : Size * 5, 1 : Size), - DiagSize);
    Middle(Size * 4 + 1 : Size * 5, 1 : Size) = ~fliplr(Middle(Size * 4 + 1 : Size * 5, 1 : Size));
    Middle(Size * 4 + 1 : Size * 5, Size + 1 : Size * 4) = 0;
    Middle(Size * 4 + 1 : Size * 5, Size * 4 + 1 : Width) = fliplr(Middle(Size * 4 + 1 : Size * 5, 1 : Size));
    Middle = ~Middle;
    
    NumericString = mod(uint8(NumericString) - 31, 15); % uint8(' 0123456789') = [32, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57]
    StringLength = length(NumericString);
    StringFig = zeros(Height, Width * StringLength + Spacer * (StringLength - 1));
    for i  = 1 : StringLength
        StringFig(1 : Height, (Width + Spacer) * (i - 1) + 1 : (Width + Spacer) * (i - 1) + Width) = ...
            UpperLeft * Display(NumericString(i), 1) + ...
            LowerLeft * Display(NumericString(i), 2) + ...
            Upper * Display(NumericString(i), 3) + ...
            Middle * Display(NumericString(i), 4) + ...
            Lower * Display(NumericString(i), 5) + ...
            UpperRight * Display(NumericString(i), 6) + ...
            LowerRight * Display(NumericString(i), 7);
    end
    
    if strcmpi(Color, 'black') || strcmpi(Color, 'b')
        StringFig = logical(~StringFig);
    end
    if strcmpi(Color, 'white') || strcmpi(Color, 'w')
        StringFig = uint8(StringFig * 255);
    end
    if isnumeric(Color) && (numel(Color) == 1) && (Color >= 0)
        StringFig = uint16(StringFig) * uint16(Color);
    end
end
