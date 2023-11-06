function genappbatch_nam12km_2023(height)
%
% C. Thaxton - AppState, (2023)
%
% Creates a HYSPLIT back trajectory batch file that calls, many times in
% sequence, an accompanying batch file that builds HYSPLIT back trajectory
% runs. For nam12km, it calls appalair_nam12km
%
% Special code for just 2023 summer fire analysis - 1 hour steps (not 6)
%
maxdays=5; % Skip the first few days to ensure all files are there.
ht=num2str(height);
%
year(1,:)='2023';
for i=5:9
    if i<10
        month(i,:)=strcat('0',num2str(i));
    else
        month(i,:)=num2str(i);
    end
end
it=0;
s=' ';
us='_';
outfile=strcat('appalair_2023_batch_nam12km_',ht,'.bat');
fileID=fopen(outfile,'w');
%
% Step through each year and get the "datestamp" based on leap years.
for i=1:1
    for j=5:9
        if j==1 || j==3 || j==5 || j==7 || j==8 || j==10 || j==12
            daysinmonth(j)=31;
        elseif j==2 
            if i==4 || i==8 || i==12
                daysinmonth(j)=29;
            else 
                daysinmonth(j)=28;
            end
        else 
            daysinmonth(j)=30;
        end
        for k=1:daysinmonth(j)
            it=it+1;
            iy(it)=str2num(year(i,:));
            im(it)=str2num(month(j,:));
            id(it)=k;
            if k<10
                datestamp(it,:)=strcat(year(i,:),month(j,:),'0',num2str(k),'_nam12');
            else
                datestamp(it,:)=strcat(year(i,:),month(j,:),num2str(k),'_nam12');
            end
        end
    end
end
sp=' ';
hours(1,:)='00';
hours(2,:)='01';
hours(3,:)='02';
hours(4,:)='03';
hours(5,:)='04';
hours(6,:)='05';
hours(7,:)='06';
hours(8,:)='07';
hours(9,:)='08';
hours(10,:)='09';
hours(11,:)='10';
hours(12,:)='11';
hours(13,:)='12';
hours(14,:)='13';
hours(15,:)='14';
hours(16,:)='15';
hours(17,:)='16';
hours(18,:)='17';
hours(19,:)='18';
hours(20,:)='19';
hours(21,:)='20';
hours(22,:)='21';
hours(23,:)='22';
hours(24,:)='23';
%
% Step through each 1 hour interval and build the call line in the batch
% file.
for i=1:it
    if i<maxdays
        continue
    end
    y(:)=datestamp(i,3:4);
    m(:)=datestamp(i,5:6);
    d(:)=datestamp(i,7:8);    
    datestr(:)=[datestamp(i,:),sp,datestamp(i-1,:),sp,datestamp(i-2,:),sp,datestamp(i-3,:),sp,datestamp(i-4,:)];
    for j=1:24
        filestr(:)=strcat('APP_',num2str(height),'_',y,'_',m,'_',d,'_',hours(j,:),'_00');
        app_batch(:)=['call appalair_nam12km_2023',sp,y,sp,m,sp,d,sp,hours(j,:),sp,'00',sp,ht,sp,'APP ',filestr,s,datestr];
        fprintf(fileID,'%s\n',app_batch(:));
    end
end

fclose(fileID);
