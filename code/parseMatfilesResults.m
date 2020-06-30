list_of_all_matfiles = dir('../results/*.mat');
T = [];
for index = 1:length(list_of_all_matfiles)
    filename = strcat('../results/', list_of_all_matfiles(index).name);
    data = load(filename, 'prob_thresh', 'max_reach_prob', ...
        'elapsed_time_cco', 'ratio_volume');
    disp(filename)
    disp(data)
    T = [T;struct2table(data)];
end
T.Properties.RowNames = {list_of_all_matfiles.name};
writetable(T, '../results/table.csv', 'Delimiter', ',', 'WriteRowNames', true);
