function [Track, Stats] = TrackMitoticCell(MitosisList, CorrespondingTrackingNum, LinkingDepth)
    ListLength = size(MitosisList, 2);
    Track = zeros(ListLength, 7);
        % [Row index, Column index, Corresponding frame, ...]
    Stats = zeros(1, 7);
        StartingFrame = 1;
        EndingFrame = 2;
        TotalFrames = 3;
        % Stats(4) records the Avg red signal
        % Stats(5) records the Standard error of red signal
        % Stats(6) records the Avg green signal
        % Stats(7) records the Standard error of green signal
        
    Found = 0;
    i = 1;
    ContinueSearching = LinkingDepth;
    while (i <= ListLength) && ContinueSearching
        iswanted = find(MitosisList{1, i}(:, 4) == CorrespondingTrackingNum, 1);
        if ~isempty(iswanted)
            if ~Found
                Stats(StartingFrame) = i;
            end
            Stats(EndingFrame) = i; % Stats(EndingFrame) keeps refreshing till the last frame
            Found = Found + 1;
            ContinueSearching = LinkingDepth;
            Track(Found, :) = [MitosisList{1, i}(iswanted, 1 : 2), i, 0, 0, 0, 0];
        else
            if Found
                ContinueSearching = ContinueSearching - 1;
            end
        end
        i = i + 1;
    end
    Track((Found + 1) : end, :) = [];
    if (EndingFrame < ListLength)
        Stats(TotalFrames) = Stats(EndingFrame) - Stats(StartingFrame) + 1;
    else
        Stats(EndingFrame) = NaN;
        Stats(TotalFrames) = NaN;
    end