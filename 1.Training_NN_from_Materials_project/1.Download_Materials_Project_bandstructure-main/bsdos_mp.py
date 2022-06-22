
from pymatgen.ext.matproj import MPRester
from pymatgen.electronic_structure.plotter import BSDOSPlotter
import os

ff=open("data_index","r+")
aa=float(ff.read())
#print(aa)
#print(type(aa))
ff.close()
id_min=int(aa)
id_max=13
m = MPRester("*****")

for i in range(id_min,id_max):
    os.remove("data_index")
    f=open("data_index","w")
    f.write(str(i+1))
    f.close()

    mid="mp-"+str(i)
    data = m.query(criteria={"task_id": mid}, properties=["pretty_formula","icsd_ids"])
    if len(data)==0:
        continue

    aa=data[0]
    comp=aa["pretty_formula"]
    print(mid)
    print(comp)

    # Dos for material id
    dos = m.get_dos_by_material_id(mid)

    # Bandstructure for material id
    bs = m.get_bandstructure_by_material_id(mid)

    if bs is None:
        continue
    bsdosplot = BSDOSPlotter(bs_projection=None, dos_projection=None, vb_energy_range=1, cb_energy_range=1,fixed_cb_energy=True, font='Times New Roman', axis_fontsize=0, tick_fontsize=0, legend_fontsize=0, bs_legend=None, dos_legend=None, rgb_legend=False, fig_size=(5, 3))
    s=bsdosplot.get_plot(bs,dos=None)
    filename=mid+"_"+comp
    #s.subplots_adjust(left=0.0, right=0.99, top=1.0, bottom=0.01)
    #s.subplots_adjust(left=-0.003, right=.999, top=1.004, bottom=0.003, wspace=None, hspace=None)
    s.subplots_adjust(left=0.0, right=1.0, top=1.0, bottom=0.0)
    s.grid(False)
    s.axis('off')
    s.savefig(filename,dpi=50)
    s.close()
    del bs
    del dos
    del s

