import numpy as np
#import sys
from sklearn import manifold
from sklearn import decomposition
from sklearn import metrics
from functools import partial
import hdbscan
#from s_dbw import S_Dbw
#from internal_validation import internalIndex
import matplotlib.pyplot as plt
from matplotlib.pyplot import figure
import pandas
import networkx as nx
#import seaborn as sns
#from scipy.spatial.distance import euclidean
from matplotlib.colors import LinearSegmentedColormap
print ('import_complete')
#################################################################
####  Reading input fingerprints
###################################
from numpy import genfromtxt
X= genfromtxt('../Reduced_lattice_fingerprint_from_DOS/input_flat_materials_244.csv', delimiter=',')
indices=genfromtxt('../Reduced_lattice_fingerprint_from_DOS/input_indices_244.csv', delimiter=',')
sublattice = np.transpose(pandas.read_csv('../Reduced_lattice_fingerprint_from_DOS/sublattice_element_244.csv', header=None).values)[0]
database_index=indices.astype(int)


################################################################
####  Read all materials data with flatness prediction
################################
data = pandas.read_csv('../../write_and_plot_clusters_calculate_flatness_score/All_mat_new_test_score_with_horz_flat_index.csv')

#######################################
#### Removing duplicates by adding a small random number
def contains_duplicates(X):
    return len(np.unique(X,axis=0)) != len(X)

print('X has duplicates: '+str(contains_duplicates(X)))

if contains_duplicates(X):
    ##### identifying idices of duplicates
    unq, count = np.unique(X, axis=0, return_counts=True)
    repeated_groups = unq[count > 1]
    for repeated_group in repeated_groups:
        repeated_idx = np.argwhere(np.all(X == repeated_group, axis=1))
        AA=repeated_idx.ravel()
        #print(AA)
        for p in AA:
            for q in range(len(X[p])):
                if X[p,q]>0:
                    bb=X[p,q]
                    X[p,q]=bb+(np.random.rand(1)[0])/1e5
        
print('modified X has duplicates: '+str(contains_duplicates(X)))
# max_fingerprint=X.max(axis=1)
# min_fingerprint=X.min(axis=1)
# print(max_fingerprint-min_fingerprint)


###################################
####  HDBSCAN
MS=5
SS=5
for min_size in range(MS,MS+1,1):
    #print(min_size)
    for min_samp in range(SS,SS+1,1):
        
        fname='HDBSCAN_244_DOS_minsize_'+str(min_size)+'_minsamp_'+str(min_samp)
        f = open(fname+'_summary_india.txt', 'w')
        f.write('Minkowski_metric_p=0.2\n')
        f.write('Total#sample   Min_size   Min_samples   N_clusters   N_noise  Max_persistence  Avg_persistence \
                Max_Lambda_in_bar  Max_cluster_size  Silhouette  CH_measure DB_measure DBCV s-dbw \n')  
                
        hdb=hdbscan.HDBSCAN(algorithm='best', alpha=1.0, approx_min_span_tree=True,\
                        gen_min_span_tree=False, leaf_size=40, metric='minkowski', cluster_selection_method='eom', min_cluster_size=min_size, min_samples=min_samp, p=0.2)
        db=hdb.fit(X)
        labels = db.labels_
        
        #################
        #### all cluster properties
        n_clusters_ = db.labels_.max()+1
        n_noise_ = list(labels).count(-1)
        hist_labels=np.unique(labels, return_counts=True)  ### calculate max cluster size
        hist_labels_new=np.delete(hist_labels[1],0)  ### calculate max cluster size
        probabilities=db.probabilities_
        cluster_persistence=db.cluster_persistence_
        examples=db.exemplars_
        outlier_score=db.outlier_scores_
        ######calculate cluster size
        unique_label,cluster_rep_index, counts = np.unique(labels, return_index=True, return_counts=True)
        cluster_size=[]
        for x in labels:
            cluster_size.append(counts[np.where(unique_label==x)[0][0]])
        cluster_size=np.array(cluster_size)
        
        
        
        #################
        #### plot objects
        cond_tree=db.condensed_tree_
        plot_obj=cond_tree.get_plot_data()
        #single_link_tree=db.single_linkage_tree_
        

        ##################
        #### validation indices
        sdbw_score='unknown'
        #sdbw_score = S_Dbw(X, labels, centers_id=None, method='Tong', alg_noise='bind',centr='mean', nearest_centr=True, metric='euclidean')
        #print(score)
        #cdbw_score = CDbw(X, labels,)
        #dbcv_score=hdbscan.validity.validity_index(X,labels,metric='minkowski',per_cluster_scores=True)
        dbcv_score= [0,np.array([0]*n_clusters_)]        ########## when DBCV can't be calculated
        ##### write summary
        f.write(str(len(X))+'   '+str(min_size)+'   '+str(min_samp)+'   '+str(n_clusters_)+\
                '   '+str(n_noise_)+'   '+str(max(cluster_persistence))+\
                    '   '+str(np.average(cluster_persistence))+'   '+str(max(plot_obj['bar_tops']))+\
                        '   '+str(max(hist_labels_new))+'   '+str(metrics.silhouette_score(X, labels))+\
                            '   '+str(metrics.calinski_harabasz_score(X, labels))+' '+str(metrics.davies_bouldin_score(X, labels))+\
                                '  '+str(dbcv_score[0])+'  '+str(sdbw_score)+'\n')
        
        ################## plot condensed tree
        figure(figsize=(40, 25), dpi=100)
        one=cond_tree.plot(leaf_separation=0.5, cmap='plasma', select_clusters=False, label_clusters=True, selection_palette=None, axis=None, colorbar=True, log_size=True, max_rectangles_per_icicle=1)
        plt.ylim((1000,1))
        plt.yscale('log')
        one.grid(True)
        cond_plot_fname=fname+'_cond_tree_india.png'
        plt.savefig(cond_plot_fname, bbox_inches='tight')

        f.close()           


        #########################################
        ############## Colormap
        ##############################
        import matplotlib
        cmap = plt.cm.get_cmap('turbo')
        norm = matplotlib.colors.Normalize(vmin=min(labels), vmax=max(labels))
        
        # #######################################
        # #### Print detail outputs for each materials
        # count=0
        # data_all=[]
        # for i in range(len(database_index)):
        #     name='2dm-'+ str(database_index[i])
        #     ind=data.index[data['ID'] == name][0]
        #     data_all.append(data.loc[ind].values)
        # data_all=np.array(data_all)
        # clubbed_data=np.transpose(np.vstack((np.transpose(data_all),labels,cluster_size,sublattice,dbcv_score[1][labels],probabilities,cluster_persistence[labels],outlier_score)))
        # Out=pandas.DataFrame(data=clubbed_data,columns=data.columns.to_list()+['cluster_index','cluster_size','sublattice_element','dbcv_cluster','probabilities','cluster_persistence','outlier_score'])
        # Out.to_csv(fname+'_detailed_output_india.csv')
        
        # ########################################
        # #### Print details of each clusters  only
        # clusters=[]
        # for j in range(len(unique_label)):
        #     if unique_label[j]==-1:
        #         nn=np.array([unique_label[j],counts[j],0.000000,0.00000])
        #     else: 
        #         nn=np.array([int(unique_label[j]),int(counts[j]),cluster_persistence[j-1],dbcv_score[1][j-1]])
        #     clusters.append(nn)
        # Out1=pandas.DataFrame(data=np.array(clusters),columns=['cluster_index','cluster_size','cluster_persistence','cluster_dbcv',])
        # Out1.to_csv(fname+'_cluster_detail_india.csv')    


        # #####################################
        # ###### get networkx tree
        # ##################################### 
        #Nx=cond_tree.to_networkx()
        #print(nx.is_tree(Nx))
        #print(nx.to_prufer_sequence(Nx))
        #nx.to_edgelist(Nx, "test.edgelist")
        #print(len(G.nodes("size")))
        #print(G.graph)
        #print(len(G.edges))
        #G1=G.nodes("size")
        #G1=G.hide_nodes()
        #G = nx.Graph()
        #print(G)
        #subax1 = plt.subplot(121)
        #options={'node_color':'blue','node_size':1,'width':1,'arrowstyle':'-|>','arrowsize':1}
        #nx.draw_networkx(G, with_labels=False,arrows=True, **options)
        #nx.draw(G, with_labels=False, font_weight='bold')
        #plt.savefig('nx_plot_graph.png', bbox_inches='tight')


        ################################## 
        ###### Pandas data
        ##################################
        panda_data=cond_tree.to_pandas()
        #print(G.number_of_nodes())
        #print(panda_data)
        selected_clusters=cond_tree._select_clusters()
        G1 = panda_data[panda_data['child_size'] > 1]
        #New_Nx=nx.from_pandas_edgelist(G1,'parent','child',['lambda_val', 'child_size'])
        #nx.write_edgelist(New_Nx,'New_edgelist', encoding = 'latin-1')
        ################################
        ################### To list from pandas
        len_G1=[]
        cluster_id=[]
        for ind1 in G1.index:
            len_G1.append(0.1)
            if G1.at[ind1,'child'] in selected_clusters:
                cluster_id.append(str(selected_clusters.index(G1.at[ind1,'child'])))
            else:
                cluster_id.append('-1')
        print(cluster_id)
        G1.insert(4, 'dist_G1', len_G1)
        G1.insert(5, 'cluster_id', cluster_id)
        G2=G1.copy()
        print(G2)
        del G1['cluster_id']
        del G1['lambda_val']
        del G1['child_size']
        g1_list=G1.values.tolist()
        ##############################
        ################ ETE treee from parent child relations
        from ete3 import Tree,TreeStyle,NodeStyle
        tree = Tree.from_parent_child_table(g1_list)
        #tree.write(format=9,outfile='new_tree.nw')
        print(G2)
        for node in tree.traverse():
            nstyle = NodeStyle()
            if node.is_leaf():
                index1=G2.index[G2['child'] == int(node.name)]
                node.name=G2.at[index1[0],'cluster_id']
                #nstyle = NodeStyle()
                #print(int(node.name))
                #print(matplotlib.colors.rgb2hex(cmap(norm(int(node.name)))))
                nstyle["fgcolor"] = str(matplotlib.colors.rgb2hex(cmap(norm(int(node.name)))))
                #nstyle['fgcolor']='#FF0000'
                nstyle["size"] = G2.at[index1[0],'child_size']/2
            else:
                nstyle["fgcolor"] ='black'
            node.set_style(nstyle)
        tree.write(format=1,outfile='new_tree.nw')
        #################################
        ################### Plot
        ts = TreeStyle()
        ts.mode='c'
        ts.arc_start = -180 # 0 degrees = 3 o'clock
        ts.arc_span = 360
        ts.scale = 40
        ts.show_leaf_name=True
        tree.show(tree_style=ts)
        

        # #####################################
        # ###### Plot sunburst chart
        # #####################################
        # print(G.size)
        # print(G1.size)
        # import math
        # import plotly.graph_objects as go
        # labels1=G['child'].astype(str).values.tolist()
        # parent1=G['parent'].astype(str).values.tolist()
        # valuess1=G['child_size'].values.tolist()
        # logvalues1 = [math.log(x) for x in valuess1]
        # fig =go.Figure(go.Sunburst(
        #         labels=labels1,
        #         parents=parent1,
        #         values=logvalues1,
        # ))
        # fig.update_layout(margin = dict(t=0, l=0, r=0, b=0))
        # fig.write_image("sunburst.png", width=600, height=350, scale=2)
        
        # #####################################
        # ###### Circular tree plot
        # ##################################
        # from ete3 import Tree, TreeStyle
        # t = Tree()
        # t.populate(30)
        # ts = TreeStyle()
        # ts.show_leaf_name = True
        # ts.mode = "c"
        # ts.arc_start = -180 # 0 degrees = 3 o'clock
        # ts.arc_span = 180
        # t.render("circular_tree.png", w=183, units="mm")
        
        
        ########################################
        ##### Plot condensed tree
        ###########################
        # create a colormap
        #colors = [(1, 0, 0), (0.5, 0.5, 0.5), (0, 0, 1)]  # R -> G -> B
        #n_bins = 500  # Discretizes the interpolation into bins
        #cmap_name = 'my_list'
        #cmap = LinearSegmentedColormap.from_list(cmap_name, colors, N=n_bins)
        
        #figure(figsize=(40, 20), dpi=400)
        #one=cond_tree.plot(leaf_separation=0.5, cmap='plasma', select_clusters=False, label_clusters=True, selection_palette=None, axis=None, colorbar=True, log_size=True, max_rectangles_per_icicle=1)
        #plt.ylim((1000,1))
        #plt.yscale('log')
        #one.grid(True)
        #cond_plot_fname='HDB_'+str(MS)+'_'+str(SS)+'.png'
        #plt.savefig(cond_plot_fname, bbox_inches='tight')
        
        #one.savefig(os.path.basename(filename_bands).split('.')[0] + '.bsdos.png',dpi=200)
        #one.close()





        # import plotly.express as px
        # fig =px.icicle(plot_obj)
        # fig.show()
        
        ###################################
        ######### icicle plot : lambda axis is from left to right
        # from matplotlib.patches import Rectangle
        # x_centers=np.array(plot_obj['bar_centers'])
        # lam_max=np.array(plot_obj['bar_tops'])
        # lam_min=np.array(plot_obj['bar_bottoms'])
        # x_width=np.array(plot_obj['bar_widths'])
        
        # fig, ax = plt.subplots()
        # for i in range(len(x_centers)):
        #     ax.add_patch(Rectangle((lam_min[i], x_centers[i]-(x_width[i]/2)), lam_max[i]-lam_min[i], x_width[i],color="red"))
        # plt.xlim((0.00002,10000))
        # plt.ylim((0,85000))
        # plt.xscale('log')
        # plt.show()
        
        ##################################
        ##### Pandas icicle plot
        # import pandas as pd
        # import plotly.express as px
        
        # count=0
        # label=[]
        # parents=[]
        # child_size=[]
        # for i in range(len(cond_tree_pandas)):
        #     if cond_tree_pandas.loc[i].child_size >= 1:
        #         label.append(str(int(cond_tree_pandas.loc[i].name)))
        #         parents.append(str(int(cond_tree_pandas.loc[i].parent)))
        #         child_size.append(int(cond_tree_pandas.loc[i].child_size))
                
        # df = pd.DataFrame(dict(parents=parents, label=label, child_size=child_size))
        # df["all"] = "all" # in order to have a single root node
        # print(df)
        # fig = px.icicle(df, path=['all', 'parents', 'label'], values='child_size')
        # fig.update_traces(root_color='lightgrey')
        # fig.update_layout(margin = dict(t=50, l=25, r=25, b=25))
        # fig.show()
        # fig.write_image("hdb_icicles.png")



        ###################################
        ######### tSNE visualization 3D 
        # tsne=TSNE(n_components=3, verbose=1, perplexity=50, n_iter=300)
        # ts= tsne.fit_transform(X)
        # fig = plt.figure(figsize=(12, 12))
        # ax = fig.add_subplot(projection='3d')
        # ########
        # ##### for different eps
        # # for i in np.arange(0.025,0.31,0.025):
        # #     eps=round(i, 3)
        # #     label=db.single_linkage_tree_.get_clusters(eps, min_cluster_size=3)
        # #     n_clusters_ = label.max()
        # #     n_noise_ = list(label).count(-1)
        # #     print(str(eps)+' '+str(len(labels))+' '+str(n_clusters_)+' '+str(n_noise_)+' '+str(metrics.silhouette_score(X, label)))
        # #     ax.scatter(ts[:,0], ts[:,1], ts[:,2], c=labels+1, cmap="hsv")
        # #     fname="t-SNE result_at_eps"+str(eps)
        # #     plt.title(fname)
        # #     plt.savefig(fname+'.png', bbox_inches='tight')
        # #     plt.show()
        # ###########
        # ###### for current minsize and minsamples
        # ax.scatter(ts[:,0], ts[:,1], ts[:,2], c=labels+1, cmap="hsv")
        # fname="t-SNE result_at_minsize_"+str(min_size)+"_minsamp_"+str(min_samp)
        # plt.title(fname)
        # plt.savefig(fname+'.png', bbox_inches='tight')
        # plt.show()

        ######################################
        ########## PCA, MDS, SE, LLE, Mod LLE,  tSNE etc 2D
        n_components=2
        n_neighbors=500
        #pca=decomposition.PCA(n_components=2)
        #LLE = partial(manifold.LocallyLinearEmbedding,n_neighbors=n_neighbors,n_components=n_components,eigen_solver="auto",)
        #lle = LLE(method="standard")
        #LTSA = LLE(method="ltsa")
        #H_LLE = LLE(method="hessian")
        #M_LLE = LLE(method="modified")
        #Iso_map = manifold.Isomap(n_neighbors=n_neighbors, n_components=n_components)
        #mds = manifold.MDS(n_components, max_iter=1000, n_init=1)
        #se = manifold.SpectralEmbedding(n_components=n_components, n_neighbors=n_neighbors)
        tsne = manifold.TSNE(n_components=n_components, early_exaggeration=12.0,init="pca",learning_rate=100, random_state=0,perplexity=30,n_iter=10000,verbose=2)
        objct= tsne.fit_transform(X)
        fig = plt.figure(figsize=(8,8))
        s=np.ones((len(labels),1))*5
        s[labels==-1]=0.2
        c=labels
        #c[labels==-1]=-5
        plt.scatter(objct[:,0], objct[:,1],s=s, c=c*5, cmap="turbo")
        #plt.scatter(objct[:,0], objct[:,1],s=s, c='k')
        #import matplotlib 
        for rep_id in cluster_rep_index:
            #print(rep_id)
            #cmap = plt.cm.get_cmap('turbo')
            #norm = matplotlib.colors.Normalize(vmin=min(labels), vmax=max(labels))
            col=cmap(norm(labels[rep_id]))
            #print(col)
            #plt.annotate(labels[rep_id],objct[rep_id,:]+np.random.uniform(low=-2, high=2, size=2),color='r',alpha=0.7, weight='normal', ha='center', va='center', size=10)
            plt.annotate(labels[rep_id],objct[rep_id,:]+[3.5,0],color=col,alpha=1, weight='normal', ha='center', va='center', size=14).draggable()
            
        ax = plt.gca()
        ax.axes.xaxis.set_visible(False)
        ax.axes.yaxis.set_visible(False)
        ax.axis('off')
        plt.rc('font', size=15)          # controls default text sizes
        plt.rc('figure', titlesize=18)  # fontsize of the figure title
        #plt.title('t-SNE 2D visualization of the fingerprint space')
        plt.show()
        plt.savefig(fname+'_tsne_new_india.svg', format = 'svg', dpi=300)
        plt.savefig(fname+'_tsne_new_india.png', bbox_inches='tight')
        # plt.show()
        plt.close(fig=fig)
