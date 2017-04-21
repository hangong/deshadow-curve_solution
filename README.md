# User-Assisted Shadow Removal
This repository contains the code for the paper
"[User-Assisted Shadow Removal](http://dx.doi.org/10.1016/j.imavis.2017.04.001)", Image and Vision Computing 2017.

This is a shadow removal solution by intensity curve fitting. We also provide tools for fixing exposure mismatch in shadow-free ground truth data.

Copyright &copy; 2017 Han Gong (gong@fedoraproject.org)<br />
University of Bath and University of East Anglia

This code is published under the GNU Lesser General Public License (LGPL) 3.

![alt text](http://www2.cmp.uea.ac.uk/~ybb15eau/ivc2017-shadow.jpg "Pipeline")

## REQUIREMENT
This code was tested on MATLAB 2016b x64, Ubuntu 16.04. The other versions of MATLAB may work but the results may not be identical.

## NOTICE
If you would like to incorporate your own automatic shadow detection algorithm, simply replace the variable 'smsk' in deshadow.m with your own binary shadow mask image.

## Usage
code/make.m: execute this script before you start, this will compile a C++ accelerated part (for curve fitting).

code/main.m: the driver for batch shadow removal. Please see main.m or execute doc main in MATLAB terminal

code/getinput.m: the driver for obtaining the user input for image I.

## Evaluation
evaluation/evalua.m: the script for running benchmark.
evaluation/mk.mat (mk.cat): the shadow category definition file.
evaluation/eval: all the *cached shadow removal results* of ours and the compared methods in the paper.

## Ground Truth Exposure Fixture
gt/gt_adj.m: the script for fixing ground truth exposure mismatch issues. The all amended ground truth are outputted in 'gt_fix_pool'.

## Shadow Removal Dataset and Online Benchmark for Variable Scene Categories
This work was tested on a rectified shadow removal dataset release by Guo et al.. We provide the tool for fixing previous issues in exposure mismatch and all ground truth data are open. Meanwhile, to encourage the open comparison of single image shadow removal in community, we also provide an [online benchmark site](http://cs.bath.ac.uk/~hg299/shadow_eval/eval.php) and a dataset. Our quantitatively verified high quality dataset contains a wide range of ground truth data (214 test cases in total). Each case is rated according to 4 attributes, which are texture, brokenness, colourfulness and softness, in 3 perceptual degrees from weak to strong. The code provided here is also compatible with this dataset (change the path in 'dataset.m' to adapt to this dataset).
