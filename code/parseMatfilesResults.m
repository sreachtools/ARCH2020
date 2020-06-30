list_of_all_matfiles = dir(strcat(root_folder, 'results/*.mat'));
T = [];
for index = 1:length(list_of_all_matfiles)
    filename = strcat(root_folder, 'results/', list_of_all_matfiles(index).name);
    data = load(filename, 'prob_thresh', 'max_reach_prob', ...
        'elapsed_time_cco', 'ratio_volume');
%     data.prob_thresh = sprintf('%1.2f', data.prob_thresh);
%     data.max_reach_prob = sprintf('%1.2f', data.max_reach_prob);
%     data.elapsed_time_cco = sprintf('%5.2f', data.elapsed_time_cco);
%     data.ratio_volume = sprintf('%1.2f', data.ratio_volume);
    disp(data)
    T = [T;struct2table(data)];
end
T.Properties.RowNames = {list_of_all_matfiles.name};
writetable(T, strcat(root_folder, 'results/table.csv'), 'Delimiter', ',', ...
    'WriteRowNames', true);
