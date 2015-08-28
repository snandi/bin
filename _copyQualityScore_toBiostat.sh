#!/bin/bash

## This bash script is for copying plots and data produced by Chengyue's python scripts, for 
## the quality score project

Frag=$1

FolderPlot=/exports/aspen/cwu/Project_QualityScore/Plots/MF/refFrag_$Frag
FolderData=/exports/aspen/cwu/Project_QualityScore/Data/MF/refFrag_$Frag

scp -r $FolderData snandi@adhara.biostat.wisc.edu:/z/Proj/newtongroup/snandi/MF_cap348/Project_QualityScore/.
scp -r $FolderPlot snandi@adhara.biostat.wisc.edu:/z/Proj/newtongroup/snandi/MF_cap348/Project_QualityScore/.


