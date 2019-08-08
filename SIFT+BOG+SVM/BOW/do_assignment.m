function []=do_assignment(opts,assignment_opts)

display('Computing assignments');
assign_flag=1;
%% check if assignment already exists
try
    assignment_opts2=getfield(load([opts.globaldatapath,'/',assignment_opts.name,'_settings']),'assignment_opts');
    if(isequal(assignment_opts,assignment_opts2))
        assign_flag=0;
        display('Recomputing assignments for this settings');
    else
        display('Overwriting assignment with same name, but other Assignment settings !!!!!!!!!!');
    end
end

if(assign_flag)
    %% load data set information and vocabulary
    load(opts.image_names);
    nimages=opts.nimages;
    vocabulary=getfield(load([opts.globaldatapath,'/',assignment_opts.dictionary_type]),'dictionary');
    vocabulary_size=size(vocabulary,1);
    featuretype=assignment_opts.featuretype;
    
    %% apply assignment method to data set
    BOW=[];
    for ii=1:nimages   % �ܹ�360��ͼƬ
        image_dir=sprintf('%s/%s/',opts.localdatapath,num2string(ii,3));                    % location where detector is saved
        inFName = fullfile(image_dir, sprintf('%s', featuretype));
        load(inFName, 'features');
        points = features.data;
        
        
        texton_ind.x = features.x;
        texton_ind.y = features.y;
        texton_ind.wid = features.wid;
        texton_ind.hgt = features.hgt;
        
        
        
        switch assignment_opts.type                      % select assignment method
            case '1nn'
                d2 = EuclideanDistance(points, vocabulary); % ��һ��ͼƬ���ֵ��ŷ�Ͼ���576*300
                [minz, index] = min(d2', [], 1); % minz��¼��С���룬index��¼���Ǹ������������
                
                BOW(:,ii)=hist(index,(1:vocabulary_size)); % 576���ؼ������뵽300���������ĵ�Ƶ��
                texton_ind.data = index; % ��ÿһ��ͼ��576���ؼ����Ӧ��300��ֲ�������ÿ��ͼƬ��Ӧ���ļ�����
                save ([image_dir,'/',assignment_opts.texton_name],'texton_ind');
                
            otherwise
                display('A non existing assignment method is selected !!!!!');
        end
        fprintf('Assign the %d th image\n',ii);
    end
    
    BOW=do_normalize(BOW,1);   % normalize the BOW histograms to sum-up to one.    % ��һ���ʴ�ģ��BOW��300*360����ÿһ�к�Ϊ1
    save ([opts.globaldatapath,'/',assignment_opts.name],'BOW');    % save the BOW representation in opts.globaldatapath
    save ([opts.globaldatapath,'/',assignment_opts.name,'_settings'],'assignment_opts');
end
end