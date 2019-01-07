## Clean-up outdated branches in local repositories  
1. git checkout develop
2. git pull
3. git remote prune origin 
4. git branch -vv | grep 'origin/.*: gone]'
5. git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -d
