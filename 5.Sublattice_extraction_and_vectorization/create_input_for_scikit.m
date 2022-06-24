%% Create input of structure fingerprint for clustering using scikit
% Input data
% ====================
% Json data : {'mat_id':[fingerprint vector....]}

clc
clear all
close all
%% Reading fingerprint input json
fid = fopen('../Reduced_lattice_fingerprint_from_ASE_SOAP/SOAP_fingerprint_reduced_lattice_DOS_only_flatmaterials.json');
raw = fread(fid,inf);
str = char(raw');
fclose(fid);
val = jsondecode(str);

%% Reading all extracted data from 2dmatpedia
fid1=fopen('../../2dmatpedia_spin_polarised_corrected_divided_by_high_symmetry_pts_16_11_2021/extracted_data_1_6500.json');
raw1 = fread(fid1,inf);
str1 = char(raw1');
fclose(fid1);
val1 = jsondecode(str1);

%% Read flat materials matrix from matlab output
opts=detectImportOptions('../../write_and_plot_clusters_calculate_flatness_score/All_mat_new_test_score_with_horz_flat_index.csv');
T = readtable('../../write_and_plot_clusters_calculate_flatness_score/All_mat_new_test_score_with_horz_flat_index.csv',opts);
t=table2cell(T);

% find all stoichiometry
U_sto=unique(string(t(:,3)));
%% creating input matrix X
ind=[];
rem_ind=[];
X=zeros(6500,length(val.x2dm_3.structure_fingerprint)); %%%% x2dm_3 is used to find length of fingerprint
sublattice=strings(6500,1);
for i=1:size(X,1)
    name=strcat('x2dm_',string(i));name2=strcat('2dm-',string(i));
    index_in_T=find(string(t(:,1))==name2);
    if isempty(find(string(t(:,1))==name2))
        rem_ind(end+1)=i;
    % condition item is in (fingerprint DB and matlab_prediction) and flatness score > 0.5  and num(flat_segments)=num(segments)
    elseif isfield(val,name)==1 && isfield(val1,name)==1 && double(string(t(index_in_T,7)))> 0.5  && double(string(t(index_in_T,5)))==double(string(t(index_in_T,6)))
        X(i,:)=val.(name).structure_fingerprint;
        sublattice(i)=string(val.(name).sublattice_element);
        ind(end+1)=i;
%         % adding an extra variable to structure fingerprints: nelements
%         nelem=val1.(name).nelements;
%         X(i,245)=2*nelem;
%         % adding an extra variable to structure fingerprints: common formula
%         gen_formula=val1.(name).formula_anonymous;
%         X(i,245)=0*(find(U_sto==gen_formula))/size(U_sto,1);
    else
        rem_ind(end+1)=i;
    end
end          
X(rem_ind,:)=[];
sublattice(rem_ind,:)=[];

%% dump the input X and ind to a csv file
writematrix(X,'../Reduced_lattice_fingerprint_from_ASE_SOAP/input_flat_materials_SOAP.csv');
writematrix(ind','../Reduced_lattice_fingerprint_from_ASE_SOAP/input_indices_SOAP.csv');
writematrix(sublattice,'../Reduced_lattice_fingerprint_from_ASE_SOAP/sublattice_element_SOAP.csv');
