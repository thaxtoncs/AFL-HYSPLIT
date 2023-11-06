function processTdumps(METDATA,HEIGHT)
% Creates infiles for cluster analysis by season and precip amount
% Works only on GDAS and NAM datasets following the naming convention in
% the fprintf statements below.
%
% C.Thaxton - AppAFL Sept. 22, 2023
%
% Infiles are placed in folders for NAM and GDAS by height.
%
if (~isstring(METDATA))
    fprintf('METDATA needs to be a string in double quotes.\n');
    fprintf('   NAM12km-96hr\n');
    fprintf('   GDAS1deg-168hr\n');
    fprintf('Try again.\n');
    return
end
if (~isstring(HEIGHT))
    fprintf('HEIGHT needs to be a string in double quotes.\n');
    fprintf('   500\n');
    fprintf('  1500\n');
    fprintf('  3500\n');
    fprintf('  5500\n');
    fprintf('Try again.\n');
    return
end

% Prompt To select folder with tdump files
strHeight = HEIGHT;
FolderPath = strcat('C:/HYSPLIT/working_appalair/results/',METDATA,'/',strHeight,'/tdp');
if METDATA=="GDAS1deg-168hr"
    dirstr='GDAS';
    rowLimit = 169;
else
    dirstr='NAM';
    rowLimit = 97;
end
InfilePath = strcat('C:/HYSPLIT/working_appalair/analysis/infiles/',dirstr,'/',strHeight);

if ~exist(InfilePath,'dir')
    mkdir(InfilePath);
end

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
List=dir(strcat(FolderPath,'/tdump*'));
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
    if ir<rowLimit                            % Do not include files less than max data length (e.g. 96 hours. 168 hours)
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
    MONTH=month(1,1);
%% Organize 
    if ttlRF<0.5
        iP00=iP00+1;
        fn_P00(iP00,:)=strcat(FolderPath,'/',filename);
    elseif ttlRF<5.0
        iP05=iP05+1;
        fn_P05(iP05,:)=strcat(FolderPath,'/',filename);        
    elseif ttlRF<10.0
        iP10=iP10+1;
        fn_P10(iP10,:)=strcat(FolderPath,'/',filename);        
    elseif ttlRF<15.0
        iP15=iP15+1;
        fn_P15(iP15,:)=strcat(FolderPath,'/',filename);        
    elseif ttlRF<20.0
        iP20=iP20+1;
        fn_P20(iP20,:)=strcat(FolderPath,'/',filename);        
    else
        iP2P=iP2P+1;
        fn_P2P(iP2P,:)=strcat(FolderPath,'/',filename);        
    end
    if MONTH==9 || MONTH==10 || MONTH==11
        iSON=iSON+1;
        fn_SON(iSON,:)=strcat(FolderPath,'/',filename);         
    elseif MONTH==12 || MONTH==1 || MONTH==2
        iDJF=iDJF+1;
        fn_DJF(iDJF,:)=strcat(FolderPath,'/',filename);         
    elseif MONTH==3 || MONTH==4 || MONTH==5        
        iMAM=iMAM+1;
        fn_MAM(iMAM,:)=strcat(FolderPath,'/',filename);         
    else          
        iJJA=iJJA+1;
        fn_JJA(iJJA,:)=strcat(FolderPath,'/',filename);         
    end
    fclose(fileID);
end
fmt = '%s\n';
    fntemp=strcat(InfilePath,'/INFILE_',strHeight,'_P00.txt');
    fileid=fopen(fntemp,'w');
    for i=1:iP00
        fprintf(fileid,fmt,fn_P00(i,:));
    end
    fclose(fileid);
    fntemp=strcat(InfilePath,'/INFILE_',strHeight,'_P05.txt');
    fileid=fopen(fntemp,'w');
    for i=1:iP05
        fprintf(fileid,fmt,fn_P05(i,:));
    end
    fclose(fileid);
    fntemp=strcat(InfilePath,'/INFILE_',strHeight,'_P10.txt');
    fileid=fopen(fntemp,'w');
    for i=1:iP10
        fprintf(fileid,fmt,fn_P10(i,:));
    end
    fclose(fileid);
    fntemp=strcat(InfilePath,'/INFILE_',strHeight,'_P15.txt');
    fileid=fopen(fntemp,'w');
    for i=1:iP15
        fprintf(fileid,fmt,fn_P15(i,:));
    end
    fclose(fileid);
    fntemp=strcat(InfilePath,'/INFILE_',strHeight,'_P20.txt');
    fileid=fopen(fntemp,'w');
    for i=1:iP20
        fprintf(fileid,fmt,fn_P20(i,:));
    end
    fclose(fileid);
    fntemp=strcat(InfilePath,'/INFILE_',strHeight,'_P2P.txt');
    fileid=fopen(fntemp,'w');
    for i=1:iP2P
        fprintf(fileid,fmt,fn_P2P(i,:));
    end
    fclose(fileid);
    fntemp=strcat(InfilePath,'/INFILE_',strHeight,'_SON.txt');
    fileid=fopen(fntemp,'w');
    for i=1:iSON
        fprintf(fileid,fmt,fn_SON(i,:));
    end
    fclose(fileid);
    fntemp=strcat(InfilePath,'/INFILE_',strHeight,'_DJF.txt');
    fileid=fopen(fntemp,'w');
    for i=1:iDJF
        fprintf(fileid,fmt,fn_DJF(i,:));    
    end
    fclose(fileid);
    fntemp=strcat(InfilePath,'/INFILE_',strHeight,'_MAM.txt');
    fileid=fopen(fntemp,'w');
    for i=1:iMAM
        fprintf(fileid,fmt,fn_MAM(i,:));
    end
    fclose(fileid);
    fntemp=strcat(InfilePath,'/INFILE_',strHeight,'_JJA.txt');
    fileid=fopen(fntemp,'w');
    for i=1:iJJA
        fprintf(fileid,fmt,fn_JJA(i,:));
    end
    fclose(fileid);

clear all
end