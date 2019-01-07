## Clean-up outdated branches in local repositories  
git checkout develop
git pull
git remote prune origin 
git branch -vv | grep 'origin/.*: gone]'
git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -d
