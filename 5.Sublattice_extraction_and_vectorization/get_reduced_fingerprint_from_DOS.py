import json
import sys
import os
import pymatgen
from pymatgen.core import Lattice, Structure, Molecule
from matminer.featurizers.site import CrystalNNFingerprint
from matminer.featurizers.structure import SiteStatsFingerprint
import numpy as np
import matplotlib.pyplot as plt
import chemparse


count=0
D={}


###################### Read flatness core csv to find which horizontal seg is flat
import csv
Inp=[]
with open('../../write_and_plot_clusters_calculate_flatness_score/All_mat_new_test_score_with_horz_flat_index.csv','r') as file:
    csvreader = csv.reader(file)
    for row in csvreader:
        Inp.append(row)
Input=np.array(Inp)


ssf = SiteStatsFingerprint(CrystalNNFingerprint.from_preset('ops', distance_cutoffs=None, x_diff_weight=0),stats=('mean','std_dev','maximum','minimum'))
#ssf = SiteStatsFingerprint(CrystalNNFingerprint.from_preset('cn'),stats=('mean'))

with open('../../../2dmatpedia/2D_matpedia_downloaded_data/data/db.json') as f:
        for jsonobj in f:
                count=count+1
                strDict=json.loads(jsonobj)
                matid=strDict['material_id']
                try:
                    indexx=np.where(Input==matid)[0][0]  ### Find entry in the flatband_score file
                except:
                    print(matid)
                    print(np.where(Input==matid))
                    continue
                mid=matid.split('-')
                mmid=float(mid[1])
                if mmid > 0 and mmid < 6500 and float(Input[indexx,9]) > 0:     ##### condition requires predicted flat materials within mmid bound
                    #print(matid)
                    ##############################
                    ###### Reading DOS file to find which element to choose for sublattice
                    DOS_dir= '../../../2dmatpedia/2D_matpedia_downloaded_data/data/2dmatpedia_band.json/dos/'
                    filename_dos=DOS_dir+matid+'.json'
                    if not os.path.isfile(filename_dos):      ###when DOS is not available
                        print("No such file %s" % filename_dos)
                        formulae=strDict['formula_pretty']
                        print(formulae)
                        list_comp=chemparse.parse_formula(formulae)
                        #print(type(list_comp))
                        bb=min(list_comp, key=list_comp.get)
                        #print(bb)
                    else:
                        dos_dict=json.load(open(filename_dos))   ### when atom projected DOS is available
                        if "atom_dos" in dos_dict:
                            elems=strDict['elements']
                            print(matid+' '+str(elems))
                            dos_max={}
                            for i in elems:
                                ef=dos_dict['atom_dos'][i]['efermi']
                                eng=np.array(dos_dict['atom_dos'][i]['energies'])
                                denst=dos_dict['atom_dos'][i]['densities']
                                for j in denst.keys():
                                    if j=='1':
                                        sum_density=np.array(denst[j])
                                    else:
                                        sum_density=sum_density+np.array(denst[j])
                                dos_full=np.stack((eng-ef,sum_density),axis=1)
                                dos_seg=float(Input[indexx,9])     ####find which horizontal segment of DOS is chosen
                                range_dos=[1.5-(dos_seg*0.5),1-(dos_seg*0.5)]
                                b = dos_full[dos_full[:, 0] <= range_dos[0]]
                                b = b[b[:, 0] >= range_dos[1]]
                                print(max(b[:,1]))
                                dos_max[i]=max(b[:,1])
                                bb=max(dos_max,key=dos_max.get)
                        else:                               #### when DOS is available but atom projection is not available
                            formulae=strDict['formula_pretty']
                            print(formulae)
                            list_comp=chemparse.parse_formula(formulae)
                            #print(type(list_comp))
                            bb=min(list_comp, key=list_comp.get)
                            #print(bb)
                    #############################################
                    ################## Truncating the structure from its basis: 
                    ################    only one type of elements remains based on DOS or min stoichiometry in case DOS NA
                    aa=strDict['structure']
                    #print(type(aa['sites']))
                    sites=[]
                    for n in aa['sites']:
                        #print(n)
                        if n['label']==bb:
                            #print(n)
                            sites.append(n)
                        #else:
                         #   aa['sites'].remove(n)
                    #print(sites)
                    aa['sites']=sites
                    #print(aa)
                    #############################################
                    structure = Structure.from_dict(aa)
                    #print(structure)
                    try:
                        v=ssf.featurize(structure)
                        D[matid]={}
                        D[matid]['structure_fingerprint']=v
                        D[matid]['sublattice_element']=bb
                        del aa,matid,v
                    except:
                        print('Error:  '+matid+'     '+formulae)

with open('244_fingerprint_reduced_lattice_DOS_only_flatmaterials.json', 'w', encoding='utf-8') as f:
        json.dump(D, f, ensure_ascii=False, indent=4)
