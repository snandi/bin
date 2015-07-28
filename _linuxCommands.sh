*] To change the prompt on the shell, to display the current directory, do:
   $ PS1='\h:$( pwd )\$ '
   It will only change for the current terminal, as the .bashrc and .bash_profile files are not writable.

*] To merge 2 pdf files and create a new one:
   pdftk File1.pdf File2.pdf cat output OutputFile.pdf

*] To rotate the entire pdf file 90 degrees clockwise:
   pdftk Input.pdf cat 1-endE output Output.pdf
   
   To rotate the entire pdf file 180 degrees clockwise:
   pdftk Input.pdf cat 1-endS output Output.pdf		## E: 90 degrees, S: 180 degrees

   To rotate a few pages (1 - p) of the pdf file 180 degrees clockwise and the rest as is:
   pdftk Input.pdf cat 1-pS (p+1)-end output Output.pdf

   To extract pages from a pdf file (e.g., extract pages 3, 4 and 5 into a new pdf):
   pdftk input.pdf cat 3-5 output final.pdf

   To remove pages from a PDF file (e.g., remove page 3 and create a new pdf without the page):
   pdftk input.pdf cat 1-2 4-end output final.pdf

   To insert File 2 between pages 2 and 3 of File1:
   pdftk File1 cat 1-2 output Temp1; pdftk File2 cat 3-4 output Temp2; pdftk Temp1 File2 Temp2 cat output FinalOutput.pdf; rm Temp*
   
#######################################################################################################
*] GIT commands
   (a) Add a connection to your friend’s version of the github repository, if you haven’t already:
       Go to ~/allez/, then type
       git remote add atbroman git://github.com/atbroman/allez
   (b) Pull his/her changes:
       git pull atbroman master
   (c) Push them back to your github repository:
       git push
   
   To start using git, use Karl Bromans introductory slides. 
   After doing git-init in an already existing folder, set up the github repository. 
   Run the following command: ssh-keygen -t rsa -C "nandi@stat.wisc.edu"
   Then add the key from the file .ssh/id_rsa.pub to the github settings (SSH keys)
   Run: git remote add origin https://github.com/snandi/RScripts_Header.git, but this step did not work on lmcg. So, 
   Run: git remote rm origin, then run
   Run: git remote add origin git@github.com:snandi/RScripts_Header.git
   Before doing git push -u origin master, run:
   eval "$(ssh-agent -s)"
   ssh-add
   git push -u origin master

   To clone an existing repository on github:
   git clone git@github.com:snandi/RScripts_Header RScripts

   To Collaborate
   --------------
   (a) git log: Display the entire commit history using the default formatting. If the output takes 
   up more than one screen, you can use Space to scroll and q to exit.
   (b) git log --oneline: Condense each commit to a single line. This is useful for getting a high-level 
   overview of the project history.
   (c) git log <file>: Only display commits that include the specified file. This is an easy way to 
   see the history of a particular file.
   (d) 

#######################################################################################################

*] To spell check in a terminal:
   aspell -t -c LitReview.tex

*] To find the number of words in a pdf document:
   pdftotext filename.pdf - | wc -w

*] To change R/W permissions for a folder, its subfolders and all their files, do:
   chmod 700 -R folder

############################################ awk commands #############################################
*] To print first column (or any column) of a text file, using awk:
   awk '{print $1}' filename

   To print columns 1 and 4 of a text file with a space between them, using awk:
   awk '{print $1 " " $4}' filename > output

   To search for a pattern in column 1 and print the whole row for those successful searches
   awk '$1 == "pattern" {print $0}' filename

   To search for a pattern in column 1 and print some of the columns for those successful searches
   awk '$1 == "pattern" {print $1 " " $4}' filename

#######################################################################################################

############################################ sed commands #############################################
*] To delete rows from a file satisfying a particular pattern, for example "NANDI"
   sed '/NANDI/d' filename.txt

#######################################################################################################

*] To grep multiple strings in a file:
   grep 'String1\|String2\|String3' filename

   To grep, case insensitive:
   grep -i 'String' filename

*] To check which users have access to a folder on AFS:
   fs listacl . or fs listacl /folderpath

*] To provide access to a particular folder on AFS:
   fs setacl -dir /afs/cs.wisc.edu/u/n/a/nandi/Stat/Stat_Quals/ -acl huling rl

*] To convert a jpg file to pdf:
   convert file.jpg file.pdf

*] To sort the folders/files in a directory by their sizes:
   du -hs * | sort -h

*] To sync local and remote folder contents:
   rsync -av nandi@desk00.stat.wisc.edu:Courses/BMI576_Fall2014/ BMI576_Fall2014  ## To sync contents from Stat folder to LMCG folder
   rsync -av BMI576_Fall2014/ nandi@desk00.stat.wisc.edu:Courses/BMI576_Fall2014  ## To sync contents from LMCG folder to Stat folder

*] To count the number of words in a pdf document:
   pdftotext document.pdf -enc UTF-8 - | wc -m

*] To check if a linux computer is 32 bit or 64 bit:
   a) file /sbin/init
   b) uname -a 
   To check the number of processors:
   a) cat /proc/cpu

*] To install a .deb package on ubuntu:
   sudo dpkg -i DEB_PACKAGE
   For example if the package file is called askubuntu_2.0.deb then you should do 
   sudo dpkg -i askubuntu_2.0.deb. 
   If dpkg reports an error due to dependency problems, you can run 
   sudo apt-get install -f 
   to download the missing dependencies and configure everything. 
   
   REMOVE A PACKAGE
   sudo dpkg -r PACKAGE_NAME

*] Synergy configuration file
   #####################################
   section: screens
   boltzmann:
   doty:
   end

   section: aliases
   doty:
   192.168.0.101
   end

   section: links
   boltzmann:
   left = doty
   doty:
   right = boltzmann
   end

   section: options
   screenSaverSync = false
   end
########################################

#######################################################################################################
*] To run R programs from command line:
   R CMD BATCH RScript.R > RScript.Rout # The .Rout is optional.

   To run R programs from command line, with arguments:
   R CMD BATCH '--args a=1 b=c(2,5,6)' RScript.R RScript.out &
   # For an example, see ~/Project_CurveReg/RScripts_CurveReg/RScript09-01_Mflorum_Registration.R
   Need to include the following code chunk:
   Args <- (commandArgs(TRUE))
   for(i in 1:length(Args)) eval(parse(text = Args[[i]]))

   To run it remotely from and continue running it even after logging out of server:
   nohup R CMD BATCH RScript.R &
   Then type "exit" to exit the terminal

*] Install R packages from .tar.gz file after adding NAMESPACE
   According to the R documentation for writing extensions, all packages destined for version 3.0.0 and 
   later must contain a NAMESPACE file. If you download an R package that gives you the above error, 
   here is what you should try: 

   1. Untar the package:
   tar -xvf the_package.tar.gz

   2. Add a NAMESPACE file with the line exportPattern( "." ):
   cd the_package
   echo 'exportPattern( "." )' > NAMESPACE
   cd ..
   
   3. Re-tar the package:
   tar -zcf the_package.tar.gz the_package
   
   4. Try and install it again.
   R CMD INSTALL the_package.tar.gz

#######################################################################################################
*] To print only unique rows from one file into another:
   sort -u file1 > file2

*] To see full paths of commands in top:
   top -c -u nandi

*] To list only empty subdirectories in a particular directory:
   find . -type d -empty

*] To dynamically watch a file/folder being populated by some script:
   watch ls -lht             # watch the folder
   tail -f filename          # dynamically watch the file being populated
   less +F filename          # dynamically watch the file being populated

########################################
*] To ssh/rcp/rsync without password prompting:

   Lets say you want to copy between two hosts host_A and host_B. host_A is the host where you would run the scp, ssh or rsyn command, irrespective of the direction of the file copy! On host_A, run this command as the user that runs scp/ssh/rsync

   ssh-keygen -t rsa

   This will prompt for a passphrase. Just press the enter key. It will then generate an identification (private key) and a public key. Do not ever share the private key with anyone! ssh-keygen shows where it saved the public key. This is by default ~/.ssh/id_rsa.pub: Your public key has been saved in <your_home_dir>/.ssh/id_rsa.pub
   
   Transfer the id_rsa.pub file to host_B by either ftp, scp, rsync or any other method. 
   On host_B, login as the remote user which you plan to use when you run scp, ssh or rsync on host_src. Copy the contents of id_rsa.pub from host_A to ~/.ssh/authorized_keys on host_B 
   chmod 700 ~/.ssh/authorized_keys

   All set!

########################################
