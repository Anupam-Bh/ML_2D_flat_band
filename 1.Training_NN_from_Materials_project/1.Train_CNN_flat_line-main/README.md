# Train_NN_flat_line
Train a Feedforward NN model to identify flat horizontal lines in an image file using Matlab Patternnet.

All MAT files are generated using the matlab code in the https://github.com/AnupamBiitd/Create_NN_input repo. 
Files with tr1,tr2 and tr3 in the names signify creation of NN input for same bandstructure 3 times. It was done to reduce human error while selecting a flatband segment. 

Skewness in the input data may be controlled by removing some negative examples in the 'skewness_reduction' block.

The output gives out two MAT files:

Final_out_1_5000_skewed.mat > NN model with training parameters and performance 

data_1_5000_skewed.mat > Trainset,Testset, Train-target, Test-target
