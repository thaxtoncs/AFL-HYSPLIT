function infiles2023_500
clear all
% Read in aerosol data
load("aerosol.mat")
DATE=table2array(aerosol(:,1));
TIME=table2array(aerosol(:,2));
LOAD=table2array(aerosol(:,3));
num=length(DATE);
for i=1:num
    A=char(DATE(i));
    B=char(TIME(i));
    YY(i)=str2num(A(7:8));
    MM(i)=str2num(A(1:2));
    DD(i)=str2num(A(4:5));
    ttemp=str2num(B(1));
    if ttemp==1 ||ttemp==2
        if B(2)==":"
            TT(i)=ttemp;
        else
            TT(i)=10*ttemp+str2num(B(2));
        end
    else    
        TT(i)=ttemp;
    end
    ltemp=char(LOAD(i));
    LL(i)=ltemp(1);
end

% Now, go to the tdump directory and start parsing file names
%%%% 500
tdumpfolder='C:\HYSPLIT\working_appalair\Summer2023\allsummer_NAM\500';
InfilePath = 'C:\HYSPLIT\working_appalair\Summer2023\INFILES\500';

if ~exist(InfilePath,'dir')
    mkdir(InfilePath);
end

% Get number of tdump files in folder
List=dir(fullfile(tdumpfolder,'\tdump*'));
ttlfiles=length(List);
%
for i=1:ttlfiles
    filename(i,:)=List(i).name;
    yy(i)=str2num(filename(i,15:16));
    mm(i)=str2num(filename(i,18:19));
    dd(i)=str2num(filename(i,21:22));
    tt(i)=str2num(filename(i,24:25));
end

% Hang on to your hat...
iLO=0;
iAV=0;
iHI=0;
iVH=0;
for i=1:ttlfiles
    for j=1:num
        if YY(j)==yy(i) && MM(j)==mm(i) && DD(j)==dd(i) && TT(j)==tt(i)
            if LL(j)=='L'
                iLO=iLO+1;
                LOfiles(iLO,:)=filename(i,:);
            elseif LL(j)=='A'
                iAV=iAV+1;
                AVfiles(iAV,:)=filename(i,:);          
            elseif LL(j)=='H'
                iHI=iHI+1;
                HIfiles(iHI,:)=filename(i,:);            
            else 
                iVH=iVH+1;
                VHfiles(iVH,:)=filename(i,:);              
            end
        end
    end
end
ttlfiles=iLO+iAV+iHI+iVH;
fmt = '%s\n';
fileid=fopen(fullfile(InfilePath,'INFILE_500_LO.txt'),'w');
for i=1:iLO
    fprintf(fileid,fmt,LOfiles(i,:));
end
fclose(fileid);
fileid=fopen(fullfile(InfilePath,'INFILE_500_AV.txt'),'w');
for i=1:iAV
    fprintf(fileid,fmt,AVfiles(i,:));
end
fclose(fileid);
fileid=fopen(fullfile(InfilePath,'INFILE_500_HI.txt'),'w');
for i=1:iHI
    fprintf(fileid,fmt,HIfiles(i,:));
end
fclose(fileid);
fileid=fopen(fullfile(InfilePath,'INFILE_500_VH.txt'),'w');
for i=1:iVH
    fprintf(fileid,fmt,VHfiles(i,:));
end
fclose(fileid);

return
