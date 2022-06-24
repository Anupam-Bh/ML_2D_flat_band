# Compound Flatness calculation

Input: 
1. json data file created at second module
2. Prediction file 'Overall_prediction_ML_1_6500' produced at the 3rd module

It performs following tasks:
1. Calculates compound flatness for each compound.
2. Reads which energy band-width has the most desirable flatband.
3. Identifies radioactive compounds and compounds with valence f-electrons.
4. Plots the Flat bands on 2D visualization for plane-flat/line-flat identification.
5. Makes a scatter plot of all materials with space groups in the X axis and general stoichiometry in the Y axis.
6. Saves all data in 'All_mat_new_test.csv'.
