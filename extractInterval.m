% IntervalList = extractInterval(AnnotationTag)
% This function returns an N x 2 matrix 'IntervalList', each row of which
% is the interval extracted from the corresponding entry of 'AnnotationTag'.
function IntervalList = extractInterval(AnnotationTag)
    IntervalList = nan(length(AnnotationTag), 2);
    for i = 1 : length(AnnotationTag)
        SplitAnnotation = strsplit(AnnotationTag{i}, ...
            {'-', '~', '>', ' ', ',', ';', ':', '(', ')', '[', ']'});
        ValidAnnotation = SplitAnnotation(~cellfun(@isempty, ...
            SplitAnnotation));
        if (length(ValidAnnotation) ~= 2)
            warning('the annotation is not valid for entry #%d!', i);
        else
            IntervalList(i, 1) = str2double(ValidAnnotation{1});
            IntervalList(i, 2) = str2double(ValidAnnotation{2});
        end
    end
end
