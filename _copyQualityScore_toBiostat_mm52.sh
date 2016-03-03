#!/bin/bash

## This bash script is for copying plots and data produced by Chengyue's python scripts, for 
## the quality score project, for mm52

ChrNum=$1
Frag=$2

chr="chr$ChrNum"
Chr="Chr$ChrNum"

FolderPlot=/aspen/nandi/mm52-all7341/Project_QualityScore/Data/human/$Chr/refFrag_$Frag
FolderData=/aspen/nandi/mm52-all7341/Project_QualityScore/Plots/human/$Chr/refFrag_$Frag

scp -r $FolderData snandi@adhara.biostat.wisc.edu:/z/Proj/newtongroup/snandi/mm52-all7341/Project_QualityScore/$chr/.
scp -r $FolderPlot snandi@adhara.biostat.wisc.edu:/z/Proj/newtongroup/snandi/mm52-all7341/Project_QualityScore/$chr/.

## Usage:
## This should be run on lmcg computers
## ./_copyQualityScore_toBiostat.sh 13 7491 #for copying data of chr 13, refFrag 7491


