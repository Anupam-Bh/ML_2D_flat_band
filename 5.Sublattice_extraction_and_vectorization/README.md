# Sublattice extraction and vectorization

Inputs:
1. CSV file 'All_mat_new_test.csv'.
2. Density of states data downloaded from 2Dmatpedia.

This code does the following tasks:
1. Identifies energy band-width there flatband lies.
2. Identifies the element which is responsible for the flatband from element projected DOS.
3. Reads structure from db.json file from 2Dmatpedia.
4. Strips the lattice into its flatband elemental sublattice.
5. Calculates CrystalNNFingerprint module from matminer package to calculate 244 dimensional vector fingerprints.
6. Saves the fingerprints into '244_fingerprint_reduced_lattice_DOS_only_flatmaterials.json' file.

'244_fingerprint_reduced_lattice_DOS_only_flatmaterials.json' file need to be parsed into 3 csv files for the subsequent step.
1. 'input_flat_materials_244.csv'
2. 'input_indices_244.csv'
3. 'sublattice_element_244.csv'


