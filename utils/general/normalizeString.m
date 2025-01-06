% Normalizing strings for string query. Covers most cases of Portuguese language.
function str = normalizeString(str)
    % Lowercase replacements
    str = strrep(str, 'á', 'a');
    str = strrep(str, 'à', 'a');
    str = strrep(str, 'é', 'e');
    str = strrep(str, 'í', 'i');
    str = strrep(str, 'ó', 'o');
    str = strrep(str, 'ú', 'u');
    str = strrep(str, 'ã', 'a');
    str = strrep(str, 'õ', 'o');
    str = strrep(str, 'â', 'a');
    str = strrep(str, 'ê', 'e');
    str = strrep(str, 'î', 'i');
    str = strrep(str, 'ô', 'o');
    str = strrep(str, 'û', 'u');
    str = strrep(str, 'ç', 'c');

    % Uppercase replacements
    str = strrep(str, 'Á', 'A');
    str = strrep(str, 'À', 'A');
    str = strrep(str, 'É', 'E');
    str = strrep(str, 'Í', 'I');
    str = strrep(str, 'Ó', 'O');
    str = strrep(str, 'Ú', 'U');
    str = strrep(str, 'Ã', 'A');
    str = strrep(str, 'Õ', 'O');
    str = strrep(str, 'Â', 'A');
    str = strrep(str, 'Ê', 'E');
    str = strrep(str, 'Î', 'I');
    str = strrep(str, 'Ô', 'O');
    str = strrep(str, 'Û', 'U');
    str = strrep(str, 'Ç', 'C');
end
