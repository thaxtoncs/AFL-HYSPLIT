function genappbatch_nam12km(height)
%
% C. Thaxton - AppState, (2023)
%
% Creates a HYSPLIT back trajectory batch file that calls, many times in
% sequence, an accompanying batch file that builds HYSPLIT back trajectory
% runs. For nam12km, it calls appalair_nam12km
%
% Back trajectory limit in [days]
% Using trial and error, it is best to limit the back trajectory time so
% that most if not all of the back trajectories remain within the domain of
% the data set. For example, with NAM, 164 hour BTs cause nearly 40% of our
% BTs to be incomplete.
maxdays=5; 
ht=num2str(height);
%
% Hardcoded: Start in 2009 and go through 2023 (15 year sequence)
for i=1:15
    year(i,:)=num2str(i+2008);
end
for i=1:12
    if i<10
        month(i,:)=strcat('0',num2str(i));
    else
        month(i,:)=num2str(i);
    end
end
it=0;
s=' ';
us='_';
outfile=strcat('appalair_batch_nam12km_',ht,'.bat');
fileID=fopen(outfile,'w');
%
% Step through each year and get the "datestamp" based on leap years.
for i=1:15
    for j=1:12
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
hours(2,:)='06';
hours(3,:)='12';
hours(4,:)='18';
%
% Step through each 6 hour interval and build the call line in the batch
% file.
for i=1:it
    if i<maxdays
        continue
    end
    y(:)=datestamp(i,3:4);
    m(:)=datestamp(i,5:6);
    d(:)=datestamp(i,7:8);    
    datestr(:)=[datestamp(i,:),sp,datestamp(i-1,:),sp,datestamp(i-2,:),sp,datestamp(i-3,:),sp,datestamp(i-4,:)];
    for j=1:4
        filestr(:)=strcat('APP_',num2str(height),'_',y,'_',m,'_',d,'_',hours(j,:),'_00');
        app_batch(:)=['call appalair_nam12km',sp,y,sp,m,sp,d,sp,hours(j,:),sp,'00',sp,ht,sp,'APP ',filestr,s,datestr];
        fprintf(fileID,'%s\n',app_batch(:));
    end
end

fclose(fileID);
