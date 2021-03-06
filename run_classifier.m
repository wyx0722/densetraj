function [model, predicted_label, accuracy, decision_values, probability_estimates, ...
        recall, precision, ap_info, testing_labels_fname, testing_labels_vector, ...
        pred_pos, actual_pos] = ...
        run_classifier(dset_dir, base_dir, cl, train_fv, test_fv, fileorder) 
    % addpath('/nfs/bigeye/sdaptardar/installs/liblinear-1.94/matlab')
    addpath('/nfs/bigeye/sdaptardar/installs/libsvm/matlab')
    run('/nfs/bigeye/sdaptardar/installs/vlfeat/toolbox/vl_setup')
    % which train
    % which predict
    which svmtrain
    which svmpredict
    fileorder.train_files
    fileorder.test_files
    size(train_fv)
    size(test_fv)
    
    labels_dict_file_train = sprintf('%s%s%s%s%s%s%s%s', dset_dir, '/', 'ClipSets', '/', cl, '_', 'train', '.txt');
    fprintf('%s\n', labels_dict_file_train); 
    [training_labels_fname, training_labels_vector] = textread(labels_dict_file_train, '%s %d');
    tr_sz = size(training_labels_fname);
    num_tr = tr_sz(1);

    labels_dict_file_test = sprintf('%s%s%s%s%s%s%s%s', dset_dir, '/', 'ClipSets', '/', cl, '_', 'test', '.txt');
    fprintf('%s\n', labels_dict_file_test); 
    [testing_labels_fname, testing_labels_vector] = textread(labels_dict_file_test, '%s %d');
    te_sz = size(testing_labels_fname);
    num_te = te_sz(1);
    
    num_samples = size(training_labels_vector, 1);
    weight_neg = sum(training_labels_vector == 1);
    weight_pos = sum(training_labels_vector == -1);
    
    liblinear_opt = sprintf('-w1 %f -w-1 %f', weight_pos, weight_neg);
    
     %training_labels_vector(training_labels_vector == 1) = 1;
    %training_labels_vector(training_labels_vector == -1) = 0;
    %testing_labels_vector(testing_labels_vector == 1) = 1;
    %testing_labels_vector(testing_labels_vector == -1) = 0;
    
    tr_ix = [ find(training_labels_vector == 1) ; find(training_labels_vector == -1)]; 
    te_ix = [ find(testing_labels_vector == 1) ; find(testing_labels_vector == -1)];

%%%%     % fileorder_train = cell(num_tr, 1);
%%%%     % for i = 1:num_tr
%%%%     %    fileorder_train{i} = fileorder.train_files(i).name;
%%%%     % end
%%%%     % [labels_fname, fileorder_train]
%%%%     
%%%%     % cv = train(training_labels_vector, sparse(train_fv), '-v 5'); 
%%%%     % model = train(training_labels_vector, sparse(train_fv)); 
%%%%     %[predicted_label, accuracy, decision_values] = predict(testing_labels_vector, sparse(test_fv), model); 


%%       % Use AUC as criteria for validation and tuning hyper parameters
%%       n_fold = 3;
%%       bestcv = 0;
%%       for log2c = -10:10,
%%           cmd = ['-c ', num2str(2^log2c), ' ', liblinear_opt ];
%%           cv = do_binary_cross_validation(training_labels_vector(tr_ix,:), sparse(train_fv(tr_ix,:)), cmd, n_fold); 
%%           if (cv >= bestcv),
%%             bestcv = cv; bestc = 2^log2c;
%%           end
%%           fprintf('%g %g (best c=%g, rate=%g)\n', log2c, cv, bestc, bestcv);
%%       end 
%%   
%%       best_cmd = ['-c ', num2str(bestc), ' ', liblinear_opt];
%%       model = train(training_labels_vector(tr_ix,:), sparse(train_fv(tr_ix,:)), best_cmd ); 

   
    
    % liblinear_opt = sprintf('-c 100 %s', liblinear_opt);
    liblinear_opt = sprintf('-c 100 %s -s 0 -t 0', liblinear_opt);
    % model = train(training_labels_vector(tr_ix,:), sparse(train_fv(tr_ix,:)), liblinear_opt); 
    model = svmtrain(training_labels_vector(tr_ix,:), train_fv(tr_ix,:), liblinear_opt); 
    
    %[predicted_label, accuracy, decision_values] = do_binary_predict(testing_labels_vector(te_ix,:), sparse(test_fv(te_ix,:)), model); 
    [predicted_label, accuracy, decision_values] = svmpredict(testing_labels_vector(te_ix,:), test_fv(te_ix,:), model); 
    probability_estimates = softmax_pr(decision_values);

    %training_labels_vector(training_labels_vector == 1) = 1;
    %training_labels_vector(training_labels_vector == 0) = -1;
    %testing_labels_vector(testing_labels_vector == 1) = 1;
    %testing_labels_vector(testing_labels_vector == 0) = -1;
    %predicted_label(predicted_label == 1) = 1;
    %predicted_label(predicted_label == 0) = -1;

    pred_pos = sum(predicted_label == 1);
    actual_pos = sum(testing_labels_vector == 1);
    fprintf('Predicted Number of positives: %d\n', pred_pos);
    fprintf('True number of positives: %d\n', actual_pos);
    %disp(predicted_label)
    %fprintf('Accuracy: %f', accuracy);
    %disp(probability_estimates);
    %[recall, precision, ap_info] = vl_pr(testing_labels_vector, probability_estimates);
    [recall, precision, ap_info] = vl_pr(testing_labels_vector(te_ix,:), decision_values);
end
