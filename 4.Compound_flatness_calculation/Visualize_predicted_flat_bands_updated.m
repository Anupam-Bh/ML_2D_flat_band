%% Visualize the predicted flat bands
clc
clear all
close all

fid = fopen('../2dmatpedia_spin_polarised_corrected_divided_by_high_symmetry_pts_16_11_2021/extracted_data_1_6500.json');
raw = fread(fid,inf);
str = char(raw');
fclose(fid);
val = jsondecode(str);

load('../2dmatpedia_spin_polarised_corrected_divided_by_high_symmetry_pts_16_11_2021/Overall_prediction_ML_1_6500.mat');

%% space group and symmetry
Triclinic=[1 2];
Monoclinic=[3 15];
Orthorhombic=[16 74];
Tetragonal=[75 142];
Trigonal=[143 167];
Hexagonal=[168 194];
Cubic=[195 230];
All=[1 230];
Brav_lattice=All;


%% Flatness criteria
flatness_criteria_min=0.5
flatness_criteria_max=1.0

%% 
count=0;

for i=1:length(Overall_pred{1})
    name=Overall_pred{1}(i);
    name1=split(name,'.'); name2=replace(name1(1),'-','_'); name3=strcat('x',name2);name4=split(name3,'_');
    info=val.(name3);
    prediction=Overall_pred{2}(i);
    if info.space_group >= Brav_lattice(1) && info.space_group <= Brav_lattice(2)
        flatness_pred_div=transpose(Overall_pred{3}{i});
        flatness_pred_reshaped=reshape(flatness_pred_div,info.num_divisions,length(flatness_pred_div)/info.num_divisions)'; % flatness score of each segment
        %% Find best flat segment in each column
        flat_segment=max(flatness_pred_reshaped);                                       % max flatness of each column
        segments=intersect(find(flat_segment> flatness_criteria_min),find(flat_segment<flatness_criteria_max));% flatness prediction based on max flatness of each column
        %% Find how many flat segments are in the same row
        [a,b]=find(flatness_pred_reshaped > flatness_criteria_min & flatness_pred_reshaped < flatness_criteria_max); % a finds the row of flatbands; b finds column of flatbands
        for m=1:size(flatness_pred_reshaped,1)
            flat_in_a_row(m)=length(find(a==m));                % finds how many flat segments are in each row
            flat_score_rowwise(m)=sum(flatness_pred_reshaped(m,:))/info.num_divisions;  % average the flatness score of each row
        end
        % finding the best row of flatband
        all_segments_in_row_flat=find(flat_in_a_row>=info.num_divisions);
        if isempty(all_segments_in_row_flat)==0
            if isempty(find(all_segments_in_row_flat==3))==0
                best_flat_row=3;
            elseif isempty(find(all_segments_in_row_flat==2))==0
                best_flat_row=2;
            elseif isempty(find(all_segments_in_row_flat==4))==0
                best_flat_row=4;
            elseif isempty(find(all_segments_in_row_flat==1))==0
                best_flat_row=1;
            end                
        end
        %% save in a matrix
        count=count+1;
        materials(count,:)=[name1(1) string(info.formulae) string(info.formula_anonymous) string(info.space_group) string(info.num_divisions) string(max(flat_in_a_row)) string(max(flat_score_rowwise)) string(info.discovery_route) "0" "0" fillmissing(string(info.exfoliation_energy),'constant',"") fillmissing(string(info.decomposition_energy),'constant',"") info.band_gap info.point_group info.crystal];
        tags(count,:)={string(info.tags')};
        elements(count,:)=strings(1,8);
%         elements(count,:)=replace(elements(count,:),""," ");
        elements(count,1:length(info.elements))=string(info.elements)';
        %% Identify radioactive materials and mark if present in 'elements' matrix
        Rad_elements=["Po","At","Rn","Fr","Ra","Ac","Th","Pa","U","Np","Pu","Am","Cm","Bk","Cf","Es","Fm","Md","No","Lr"];
        for k=1:size(elements,1)
            elements(count,7)="non-radioactive";
            if isempty(intersect(Rad_elements,elements(count,:)))==0
                elements(count,7)="radioactive";
            end
        end
        %% Identify f orbital materials and mark if present in 'elements' matrix
        f_elements=["Ce","Pr","Nd","Pm","Sm","Eu","Gd","Tb","Dy","Ho","Er","Tm","Yb","Lu","Ac","Th","Pa","U","Np","Pu","Am","Cm","Bk","Cf","Es","Fm","Md","No","Lr"];
        for k=1:size(elements,1)
            elements(count,8)="no-f-in-valence";
            if isempty(intersect(f_elements,elements(count,:)))==0
                elements(count,8)="f-in-valence";
            end
        end
        
        %% Coordinate transform
        high_symm_pts_cart=info.rec_lattice'*info.tag_coordinates';         % coordinate transformation from rec coord to cart coord
        
        %% plot flat bands as straight lines in Cartesian coordinates
%         figure(1)
        if max(flat_in_a_row)>= info.num_divisions  && max(flat_score_rowwise)>flatness_criteria_min && max(flat_score_rowwise)<flatness_criteria_max % flat segment in all BZ
            materials(count,9)=1;                       % materials which satifies the screening criteria
            materials(count,10)=best_flat_row;
            fprintf('%s ',string(info.tags'))
            fprintf('%s %s %s %f %f %d %f\n',name3,info.formulae,info.formula_anonymous, info.num_divisions,max(flat_in_a_row),info.space_group, max(flat_score_rowwise));
            for j=1:length(segments)
                symmpt1=high_symm_pts_cart(:,((segments(j)-1)*2)+1);
                symmpt2=high_symm_pts_cart(:,((segments(j)-1)*2)+2);
                if symmpt1(3)|| symmpt2(3) > 0
                    (1);
                end
%                 plot3([symmpt1(1) symmpt2(1)],[symmpt1(2) symmpt2(2)],[double(name4(2)) double(name4(2))],'Color',[0,(1-i/length(Overall_pred{1})),i/length(Overall_pred{1})]);
                hold on
            end
        end
    end
end
materials=[materials elements];
fprintf('%d materials were found',count);

%% Plot selected materials in 2D with space group and general chemical formula
figure(2)
X=categorical(materials(:,3));
Y=categorical(double(materials(:,4)));
Z=categorical(materials(:,9));
XYZ=[X Y Z];
[uniqueXYZ,ia,ic]=unique(XYZ,'rows');
similar_mat_index={};
for i=1:length(ic)
    sz(i)=length(intersect(find(ic==ic(i)) , find(materials(:,9)=="1")));
    if sz(i) < 1    %%%%%% Used to change minimum size of cluster that plotted
        sz(i)=NaN;
    end
    similar_mat_index{end+1}=intersect(find(ic==ic(i)) , find(materials(:,9)=="1"));
    flatness_param=[];
    flatness_param=double(materials(similar_mat_index{i},7));
    flatness_param_color(i)=sum(flatness_param)/length(flatness_param);
end
scatter(Y,X,20*sz,flatness_param_color,'filled');
szv=sz; 
% szv(szv<3)=NaN;  % If text for smaller than 3 cluster needs to be removed
szx=string(szv);
text(Y,X,szx);
colorbar
set(gca,'Xgrid','on','Ygrid','on','Fontweight','normal','Fontsize',8,'FontName','Heveltica');
ylabel('Common formulae');
xlabel('#space group');
box on;
set(gca,'Position',[0.25    0.1557    0.7    0.76])
pbaspect([1.9 3 1]);
set(gcf,'PaperUnits','inches','PaperPosition',[-1 0 13 18])

%% Normalized clusters
total_mat_sg_and_sto=zeros(size(uniqueXYZ,1),1);
percentage_flat=NaN(length(ic),1);
sg_sto_type_id=NaN(length(ic),1);
for i=1:length(uniqueXYZ)
    sg=double(string(uniqueXYZ(i,2)));
    sto=string(uniqueXYZ(i,1));
    total_mat_sg_and_sto(i)=length(intersect(find(string(X)==sto),find(double(materials(:,4))==sg)));
    percentage_flat(similar_mat_index{ia(i)})=sz(similar_mat_index{ia(i)})./total_mat_sg_and_sto(i);
    sg_sto_type_id(similar_mat_index{ia(i)})=i;
end
figure(3)
scatter(Y,X,500*percentage_flat,flatness_param_color,'filled');
percentage_flat=round(percentage_flat,3);
pctg_flat=string(percentage_flat*100);
text(Y,X,pctg_flat,'fontsize',8);
set(gca,'Xgrid','on','Ygrid','on','Fontweight','normal','Fontsize',8,'FontName','Heveltica');
ylabel('Common formulae');
xlabel('#space group');
box on;
colorbar
set(gca,'Position',[0.25    0.1557    0.7    0.76])
pbaspect([1 3 1]);

% Merging Percentage flat with materials matrix 
pctg_flat=fillmissing(pctg_flat,'constant',"");
sg_sto_type_id=string(sg_sto_type_id);
sg_sto_type_id=fillmissing(sg_sto_type_id,'constant',"");
materials=[materials sg_sto_type_id pctg_flat];

% set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 12])

% Find high percentage normalized flatband materials
% high_perc_flat_cluster_id=intersect(find(sz>2),find(percentage_flat>=0.5));
% high_perc_flat_mat=materials(high_perc_flat_cluster_id,:);
% M=categorical(high_perc_flat_mat(:,4));
% N=categorical(high_perc_flat_mat(:,3));
% Size=categorical(sz(high_perc_flat_cluster_id));
% Perc=categorical(100*(percentage_flat(high_perc_flat_cluster_id)));
% MN=[M N Perc' Size'];
% [uniqueMN,im,in]=unique(MN,'rows');

%% List materials in same cluster
% indices={};
% selected_materials=materials(find(materials(:,9)=="1"),:);
% X=categorical(selected_materials(:,3));
% Y=categorical(double(selected_materials(:,4)));
% Z=categorical(selected_materials(:,9));
% XYZ=[X Y Z];
% [uniqueXYZ,ia,ic]=unique(XYZ,'rows');
% for n=1:length(uniqueXYZ)
%     A=uniqueXYZ(n,:);
%     indices{end+1}=intersect(find(selected_materials(:,3)==string(A(1))),find(selected_materials(:,4)==string(A(2))));
% end
% [~,I] = sort(cellfun(@length,indices),'descend');
% sorted_indices=indices(I);
% fileID = fopen('All_new.txt','w');
% for n=1:length(sorted_indices)
%     if length(sorted_indices{n})>=3
%         fprintf(fileID,'\n====================== cluster # %d=================\n',n);
%         fprintf(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s\n',selected_materials(sorted_indices{n},:)');
%         fprintf(fileID,'++++++++++++++++++++++++++++++\n');
%         fprintf(fileID,'++++++++++++++++++++++++++++++\n');
%     end
% end
% fclose(fileID);
%% List all materials in a file 
writematrix(materials,'All_mat_new_test.csv')
% fileID = fopen('All_new.txt','w');
% fprintf(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s\n',materials');
% fclose(fileID);