# Clustering module

Density based hierarchical algorithm HDBSCAN is used as first layer of unsupervised clustering mechanism.

T-SNE is used to find global neighbourhood relation among HDBSCAN entries in reduced embedded space to further classify the clusters into isostructural groups.

This code does the following tasks:
1. Reads the fingerprints from three CSV files generated at the last step. 
2. Removes any duplicates present in the fingerprints by introducing miniscule random noise.
3. Uses HDBSCAN to classify the fingerprints.
4. Calculate DBCV and S_Dbw score.
5. Uses t-SNE with HDBSCAN output
6. Create condensed tree plot
7. Create phylogenetic tree plot



![HDBSCAN_244_DOS_minsize_7_minsamp_7_cond_tree](https://user-images.githubusercontent.com/106304435/175698919-c512ab7b-032d-43df-a4ab-5fbc1a601215.png)

![HDBSCAN_244_DOS_minsize_7_minsamp_7_tsne](https://user-images.githubusercontent.com/106304435/175698941-1f2863ce-340b-40d7-9489-d5d7299f9b11.png)
