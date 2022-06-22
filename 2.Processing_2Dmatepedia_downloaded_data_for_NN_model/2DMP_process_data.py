import json
#import sys
import os
import matplotlib.pyplot as plt
from matplotlib.pyplot import figure
#import numpy as np

D={}
mat_id_list= []
sg_number_list=[]
formulae_list=[]
band_gap_list=[]
nelements_list=[]
elements_list=[]
discovery_route_list=[]
formula_anonymous_list=[]
exfoliation_energy_list=[]
decomposition_energy_list=[]
crystal_list=[]
point_group_list=[]


with open('../2D_matpedia_extract_data/data/db.json') as f:
    for jsonobj in f:
        strDict=json.loads(jsonobj)
        mat_id_list.append(strDict['material_id'])
        sg_number_list.append(strDict['sg_number'])
        formulae_list.append(strDict['formula_pretty'])
        band_gap_list.append(strDict['bandgap'])
        nelements_list.append(strDict['nelements'])
        elements_list.append(strDict['elements'])
        discovery_route_list.append(strDict['discovery_process'])
        formula_anonymous_list.append(strDict['formula_anonymous'])
        if 'exfoliation_energy_per_atom' in strDict:
            exfoliation_energy_list.append(strDict['exfoliation_energy_per_atom'])
        else:
            exfoliation_energy_list.append(float("nan"))
        if 'decomposition_energy' in strDict:
            decomposition_energy_list.append(strDict['decomposition_energy'])
        else:
            decomposition_energy_list.append(float("nan"))
        crystal_list.append(strDict['spacegroup']['crystal_system'])
        point_group_list.append(strDict['spacegroup']['point_group'])        
        
        


start_index=3501
end_index=6500

for x in range(start_index,end_index+1):
    name='2dm-'+ str(x)
    BS_dir= '../2D_matpedia_extract_data/data/bands/'
    filename_bands=BS_dir+name+'.json'
    if not os.path.isfile(filename_bands):
        print("No such file %s" % filename_bands)
        continue
    bands_dict=json.load(open(filename_bands))
    
    
    ## create a json with space_group and BS_features(no of division,labels,div locations)
    # aa=bands_dict['branches']   Using the branches feature is not advisable: This feature has a lot of errors
    # branches=len(aa)
    bb=bands_dict['labels_dict']
    cc=bands_dict['kpoints']
    k=list(bb.keys())
    v=list(bb.values())
    div = []
    tag = []
    coord=[]
    for i in range(len(cc)):
            if v.count(cc[i]) > 0:
                ind=v.index(cc[i])
                div.append(i)
                tag.append(k[ind])
                coord.append(v[ind])
    branches=len(div)/2      
    ef=bands_dict['efermi']
    dd=bands_dict['bands']    
    D[name]={}
    D[name]['num_divisions']=branches
    D[name]['tags']=tag
    D[name]['tag_coordinates']=coord
    D[name]['divisions']=div
    D[name]['rec_lattice']=bands_dict['lattice_rec']['matrix']
    D[name]['space_group']=sg_number_list[mat_id_list.index(name)]
    D[name]['formulae']=formulae_list[mat_id_list.index(name)]
    D[name]['band_gap']=band_gap_list[mat_id_list.index(name)]
    D[name]['nelements']=nelements_list[mat_id_list.index(name)]
    D[name]['elements']=elements_list[mat_id_list.index(name)]
    D[name]['discovery_route']=discovery_route_list[mat_id_list.index(name)]
    D[name]['formula_anonymous']=formula_anonymous_list[mat_id_list.index(name)]   
    D[name]['exfoliation_energy']=exfoliation_energy_list[mat_id_list.index(name)]
    D[name]['decomposition_energy']=decomposition_energy_list[mat_id_list.index(name)]
    D[name]['crystal']=crystal_list[mat_id_list.index(name)]
    D[name]['point_group']=point_group_list[mat_id_list.index(name)]
     
    ## Print a file using matplotlib
    x = [*range(0, len(cc), 1)]
    y=dd['1']
    if len(dd)==2:
        z=dd['-1']
    
    figure(figsize=(branches*2.03, 5), dpi=31.789)
    for n in range(len(y)):
        plt.plot(x,y[n],color='black',linestyle='-',linewidth=2.5)
        if len(dd)==2:
            plt.plot(x,z[n],color='black',linestyle='-',linewidth=2.5)
    plt.ylim([-1+ef,1+ef])
    plt.axis('off')
    plt.margins(0,0)
    outfile = name+'.png'
    print(outfile, branches)
    

    plt.savefig(outfile, bbox_inches='tight', pad_inches = 0)
    plt.close()
    del x, y, bb, cc, dd, branches, ef, k, v, div, tag, bands_dict, filename_bands, name, BS_dir

with open('extracted_data_3501_6500.json', 'w', encoding='utf-8') as f:
    json.dump(D, f, ensure_ascii=False, indent=4)
    







