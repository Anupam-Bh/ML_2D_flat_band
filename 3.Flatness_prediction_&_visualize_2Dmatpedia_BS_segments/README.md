# Prediction and visualization of segmented band-structures

This code requires the trained NN model and processed band-structure images from 2Dmatpedia(not-segmented).

This code performs the following tasks:

1. Divides the band-strucutre images vertically into 4 energy bandwidths and horizontally at high symmetry points. 
2. Uses trained NN model to predict flatness for each segment.
3. Saves the predictions in a file 'Overall_prediction_ML_1_6500_DeepNN_10_10_2022'.
4. Visualize the positive predictions as red boxes on the band-structures.  



![AA](https://user-images.githubusercontent.com/106304435/202852539-280f1630-9ddc-443f-8d27-71dc0011aeb9.png)
