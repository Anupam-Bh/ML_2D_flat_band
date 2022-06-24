# Prediction and visualization of segmented band-structures

This code requires the trained NN model and processed band-structure images (not-segmented).

This code performs the following tasks:

1. Divides the band-strucutre images vertically into 4 energy bandwidths and horizontally at high symmetry points. 
2. Uses trained NN model to predict flatness for each segment.
3. Saves the predictions in a file 'Overall_prediction_ML_1_6500'.
4. Visualize the positive predictions as red boxes on the band-structures.  


![fig](https://user-images.githubusercontent.com/106304435/175519068-5567b1f9-6841-4fe9-a647-8e444823e98f.png)
