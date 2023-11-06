% Script to Convert Tdump files to CSV Format 
clear all
% Prompt To select folder with tdump files
FolderPath = 'C:\HYSPLIT\working_appalair\results\NAM12km-96hr\500\tdp';
% DestPath = 'C:\HYSPLIT\working_appalair\results\NAM12km-96hr\500\cluster_infiles';
InfilePath = 'C:\HYSPLIT\working_appalair\analysis\infiles\NAM\500';
% if ~exist(DestPath,'dir')
%     mkdir(DestPath);
% end
if ~exist(InfilePath,'dir')
    mkdir(InfilePath);
end
%= uigetdir('/','Select Folder Containing tdump Files');

%% Make INFILES
%     DpathALL=strcat(DestPath,'\all');
%     if ~exist(DpathALL,'dir')
%         mkdir(DpathALL);
%     end 
%     DpathSON=strcat(DestPath,'\SON');
%     if ~exist(DpathSON,'dir')
%         mkdir(DpathSON);
%     end 
%     DpathDJF=strcat(DestPath,'\DJF');
%     if ~exist(DpathDJF,'dir')
%         mkdir(DpathDJF);
%     end 
%     DpathMAM=strcat(DestPath,'\MAM');
%     if ~exist(DpathMAM,'dir')
%         mkdir(DpathMAM);
%     end     
%     DpathJJA=strcat(DestPath,'\JJA');
%     if ~exist(DpathJJA,'dir')
%         mkdir(DpathJJA);
%     end 
%     DpathP00=strcat(DestPath,'\P00');
%     if ~exist(DpathP00,'dir')
%         mkdir(DpathP00);
%     end 
%     DpathP05=strcat(DestPath,'\P05');
%     if ~exist(DpathP05,'dir')
%         mkdir(DpathP05);
%     end 
%     DpathP10=strcat(DestPath,'\P10');
%     if ~exist(DpathP10,'dir')
%         mkdir(DpathP10);
%     end 
%     DpathP15=strcat(DestPath,'\P15');
%     if ~exist(DpathP15,'dir')
%         mkdir(DpathP15);
%     end 
%     DpathP20=strcat(DestPath,'\P20');
%     if ~exist(DpathP20,'dir')
%         mkdir(DpathP20);
%     end     
%     DpathP2P=strcat(DestPath,'\P2P');
%     if ~exist(DpathP2P,'dir')
%         mkdir(DpathP2P);
%     end 

% %% Initialize variables.
delimiter = ' ';
readRow = 1;
iskip=0;
ttlfiles=0;
j=0;
iP00=0;
iP05=0;
iP10=0;
iP15=0;
iP20=0;
iP2P=0;
iSON=0;
iDJF=0;
iMAM=0;
iJJA=0;
%
% Get number of tdump files in folder
List=dir(fullfile(FolderPath,'/tdump*'));
ttlfiles=length(List);
%
for i=1:ttlfiles
    filename=List(i).name;
    fileID = fopen(fullfile(FolderPath,filename),'r');
    formatSpec = '%f%f%[^\n\r]';
    dataArray = textscan(fileID, formatSpec, readRow, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'ReturnOnError', false);
    startRow = cell2mat(dataArray(1,1))+5; 
    % Skip header data
    dataArray = textscan(fileID,'%s%d%d%d%d%d%[^\n\r]',cell2mat(dataArray(1,1)),'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'ReturnOnError', false);
    % Skip 1 BACKWARD OMEGA
    dataArray = textscan(fileID,'%d%s%s%[^\n\r]',readRow,'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'ReturnOnError', false);
    % Skip Basic data stream
    dataArray = textscan(fileID,'%d%d%d%d%f%f%f%[^\n\r]',readRow,'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'ReturnOnError', false);
    % Skip Column headers
    dataArray = textscan(fileID,'%d%s%s%s%s%s%s%s%s%s%s%[^\n\r]',readRow,'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'ReturnOnError', false);
    % Read Data!!
    dataFormatSpec='%d%d%d%d%d%d%d%d%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
    try
        dataArray = textscan(fileID,dataFormatSpec,'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'ReturnOnError', false);
    catch
%         disp('WARNING: Missing data - skipping file.')
%         fprintf ('Filename: %s\n',filename)
        fclose(fileID);
        continue
    end
    [ir,ic]=size(dataArray{1,1});
    if ir<97                            % Do not include files less than max data length (e.g. 96 hours)
%         disp('WARNING: File too short - skipping file.')
%         fprintf ('Filename: %s\n',filename)  
        iskip=iskip+1;
        fclose(fileID);
        continue
    end
    j=j+1;
    RAINFALL = dataArray{:,16};
    ttlRF=sum(RAINFALL);
    month = dataArray{:,4};
    MONTH=month(1);
%% Organize 
    if ttlRF<0.5
        iP00=iP00+1;
        fn_P00(iP00,:)=filename(:);
    elseif ttlRF<5.0
        iP05=iP05+1;
        fn_P05(iP05,:)=filename(:);        
    elseif ttlRF<10.0
        iP10=iP10+1;
        fn_P10(iP10,:)=filename(:);        
    elseif ttlRF<15.0
        iP15=iP15+1;
        fn_P15(iP15,:)=filename(:);        
    elseif ttlRF<20.0
        iP20=iP20+1;
        fn_P20(iP20,:)=filename(:);        
    else
        iP2P=iP2P+1;
        fn_P2P(iP2P,:)=filename(:);        
    end
    if MONTH==9 || MONTH==10 || MONTH==11
        iSON=iSON+1;
        fn_SON(iSON,:)=filename(:);         
    elseif MONTH==12 || MONTH==1 || MONTH==2
        iDJF=iDJF+1;
        fn_DJF(iDJF,:)=filename(:);         
    elseif MONTH==3 || MONTH==4 || MONTH==5        
        iMAM=iMAM+1;
        fn_MAM(iMAM,:)=filename(:);         
    else          
        iJJA=iJJA+1;
        fn_JJA(iJJA,:)=filename(:);         
    end
    fclose(fileID);
end
fmt = '%s\n';

    fileid=fopen(fullfile(InfilePath,'INFILE_500_P00.txt'),'w');
    for i=1:iP00
        fprintf(fileid,fmt,fn_P00(i,:));
    end
    fclose(fileid);

    fileid=fopen(fullfile(InfilePath,'INFILE_500_P05.txt'),'w');
    for i=1:iP05
        fprintf(fileid,fmt,fn_P05(i,:));
    end
    fclose(fileid);

    fileid=fopen(fullfile(InfilePath,'INFILE_500_P10.txt'),'w');
    for i=1:iP10
        fprintf(fileid,fmt,fn_P10(i,:));
    end
    fclose(fileid);

    fileid=fopen(fullfile(InfilePath,'INFILE_500_P15.txt'),'w');
    for i=1:iP15
        fprintf(fileid,fmt,fn_P15(i,:));
    end
    fclose(fileid);

    fileid=fopen(fullfile(InfilePath,'INFILE_500_P20.txt'),'w');
    for i=1:iP20
        fprintf(fileid,fmt,fn_P20(i,:));
    end
    fclose(fileid);

    fileid=fopen(fullfile(InfilePath,'INFILE_500_P2P.txt'),'w');
    for i=1:iP2P
        fprintf(fileid,fmt,fn_P2P(i,:));
    end
    fclose(fileid);

fileid=fopen(fullfile(InfilePath,'INFILE_500_SON.txt'),'w');
for i=1:iSON
    fprintf(fileid,fmt,fn_SON(i,:));
end
fclose(fileid);

%fmt = ['%s\n',40,iDJF];
fileid=fopen(fullfile(InfilePath,'INFILE_500_DJF.txt'),'w');
for i=1:iDJF
    fprintf(fileid,fmt,fn_DJF(i,:));    
end
fclose(fileid);

%fmt = ['%s\n',40,iMAM];
fileid=fopen(fullfile(InfilePath,'INFILE_500_MAM.txt'),'w');
for i=1:iMAM
    fprintf(fileid,fmt,fn_MAM(i,:));
end
fclose(fileid);

%fmt = ['%s\n',40,iJJA];
fileid=fopen(fullfile(InfilePath,'INFILE_500_JJA.txt'),'w');
for i=1:iJJA
    fprintf(fileid,fmt,fn_JJA(i,:));
end
fclose(fileid);
% 
% 
% 
% save('RF_files.mat','fn','ttlRF','ttlfiles','iskip',...
%     'iP00','iP05','iP10','iP15','iP20','iP2P',...
%     'iSON','iDJF','iMAM','iJJA')