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

