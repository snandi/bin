#!/bin/sh
## This script scans through the SeedsForPower.txt file and creates pairwise Seeds folders

FILE=$1
RunID=$2
FilePath=/z/Proj/newtongroup/snandi/Simulation_Registration/$RunID/

while read line; 
do
    linearray=( $line )
    Seed1=${linearray[0]}
    Seed2=${linearray[1]}
    NewFolder=$FilePath"Seed"$Seed1"_Seed"$Seed2
    echo $NewFolder
    mkdir $NewFolder
    File1=$FilePath"Seed"$Seed1"/SimData_Seed"$Seed1".RData"
    File2=$FilePath"Seed"$Seed2"/SimData_Seed"$Seed2".RData"
    cp $File1 $NewFolder/.
    cp $File2 $NewFolder/.
done < $FILE

# for line in $(cat $FilePath)
# do

# done
