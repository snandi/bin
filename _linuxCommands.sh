1. To change the prompt on the shell, to display the current directory, do:
   $ PS1='\h:$( pwd )\$ '
   It will only change for the current terminal, as the .bashrc and .bash_profile files are not writable.

2. To merge 2 pdf files and create a new one:
   pdftk File1.pdf File2.pdf cat output OutputFile.pdf

3. To rotate the entire pdf file 90 degrees clockwise:
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
4. GIT commands
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

#######################################################################################################

5. To spell check in a terminal:
   aspell -t -c LitReview.tex

6. To change R/W permissions for a folder, its subfolders and all their files, do:
   chmod 700 -R folder

7. To print first column (or any column) of a text file, using awk:
   awk '{print $1}' filename

   To print columns 1 and 4 of a text file with a space between them, using awk:
   awk '{print $1 " " $4}' filename > output

8. To delete rows from a file satisfying a particular pattern, for example "NANDI"
   sed '/NANDI/d' filename.txt

9. To grep multiple strings in a file:
   grep 'String1\|String2\|String3' filename

10. To check which users have access to a folder on AFS:
    fs listacl . or fs listacl /folderpath

11. To provide access to a particular folder on AFS:
    fs setacl -dir /afs/cs.wisc.edu/u/n/a/nandi/Stat/Stat_Quals/ -acl huling rl

12. To convert a jpg file to pdf:
    convert file.jpg file.pdf

13. To sort the folders/files in a directory by their sizes:
    du -hs * | sort -h

14. To sync local and remote folder contents:
    rsync -av nandi@desk00.stat.wisc.edu:Courses/BMI576_Fall2014/ BMI576_Fall2014  ## To sync contents from Stat folder to LMCG folder
    rsync -av BMI576_Fall2014/ nandi@desk00.stat.wisc.edu:Courses/BMI576_Fall2014  ## To sync contents from LMCG folder to Stat folder

15. To count the number of words in a pdf document:
    pdftotext document.pdf -enc UTF-8 - | wc -m

16. To check if a linux computer is 32 bit or 64 bit:
    a) file /sbin/init
    b) uname -a 

17. To install a .deb package on ubuntu:
    sudo dpkg -i DEB_PACKAGE
    For example if the package file is called askubuntu_2.0.deb then you should do 
    sudo dpkg -i askubuntu_2.0.deb. 
    If dpkg reports an error due to dependency problems, you can run 
    sudo apt-get install -f 
    to download the missing dependencies and configure everything. 
    
    REMOVE A PACKAGE
    sudo dpkg -r PACKAGE_NAME

18. synergy configuration file
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
    #####################################

19. To run R programs from command line:
    R CMD BATCH RScript.R > RScript.Rout # The .Rout is optional.

    To run it remotely from and continue running it even after logging out of server:
    nohup R CMD BATCH RScript.R &
    Then type "exit" to exit the terminal

20. To print only unique rows from one file into another:
    sort -u file1 > file2


