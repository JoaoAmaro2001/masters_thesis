function cleanStr = removeSpecialChars(str)
    % removeSpecialChars Removes special characters from a string
    %
    %   cleanStr = removeSpecialChars(str)
    %
    %   Input:
    %       str - Original string possibly containing special characters
    %
    %   Output:
    %       cleanStr - String with special characters removed
    %
    %   This function replaces special characters with their closest ASCII equivalents,
    %   and removes any remaining non-alphanumeric characters.

    % Replace accented characters with ASCII equivalents
    str = regexprep(str, '([ÀÁÂÃÄÅàáâãäå])', 'a');
    str = regexprep(str, '([ÈÉÊËèéêë])', 'e');
    str = regexprep(str, '([ÌÍÎÏìíîï])', 'i');
    str = regexprep(str, '([ÒÓÔÕÖØòóôõöø])', 'o');
    str = regexprep(str, '([ÙÚÛÜùúûü])', 'u');
    str = regexprep(str, '([Çç])', 'c');
    str = regexprep(str, '([Ññ])', 'n');
    str = regexprep(str, '([Ýýÿ])', 'y');

    % Remove any remaining non-alphanumeric characters
    cleanStr = regexprep(str, '[^a-zA-Z0-9_]', '');
end
