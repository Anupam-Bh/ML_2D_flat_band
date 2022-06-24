# Prediction and visualization of segmented band-structures

This code requires the trained NN model, json data file generated at the previous step and processed band-structure images (not-segmented).

This code performs the following tasks:

1. Divides the band-strucutre images vertically into 4 energy bandwidths and horizontally at high symmetry points. 
2. Uses trained NN model to predict flatness for each segment.
3. 
