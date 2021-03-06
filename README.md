ps-git-pivotal
--------------
PowerShell script to implement a git feature branch workflow integrated with [PivotalTracker][1], based on [git-pivotal][2].
You will need the git command in your path.

#Usage
Inside your git repository run the following commands. The script will ask for some config values in the first run, your PivotalTracker API token [(you can find it in your profile page)][5] and the project id.

    Start-Story
    
This command will list the top 5 stories in your PivotalTracker backlog and ask for a story id to start working on. After you choose an id a branch will be created and the story on pivotal will change to started.
After that you can do your current work and commits as always.

    Stop-Story
    
After you´re done run this command to merge the current branch into master, mark the story as finished in PivotalTracker and delete the created feature branch. 

#Installing via PsGet
If you have [PsGet][4] just do

    install-module ps-git-pivotal

#Installing manually

Grab a version of the script [ps-git-pivotal.psm1][3] and put inside the PowerShell modules path within the ps-git-pivotal folder. You can check the path with the PSModulePath environment variable.

    $env:PSModulePath
    
As always you can fork and clone the repository inside the PowerShell modules path and it should also work.

[1]: https://www.pivotaltracker.com/
[2]: https://github.com/trydionel/git-pivotal
[3]: https://github.com/marciotoshio/ps-git-pivotal/raw/master/ps-git-pivotal.psm1
[4]: http://psget.net/
[5]: https://www.pivotaltracker.com/profile
