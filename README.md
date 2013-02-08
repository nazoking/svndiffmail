SvnDiffMail
======================
Creates a commit report

set your repositorys hook script

```bash:hooks/post-commit
#/bin/bash
REPOS="$1"
REV="$2"

REDMINE="http://redmine.local/redmine"
PROJECT="myproject"
REDMINE_KEY="EEIzOgMLfYV1BLmHqimR"
MAILTO="xxxx@example.com"
NAME="COMMIT-myproject"
SVNLOOK="/usr/bin/svnlook"

curl "$REDMINE/fetch_changesets?key=$REDMINE_KEY&id=$PROJECT" &

perl /home/kita/svndiffmail/svnmail.pl -d $REPOS -rev $REV -to $MAILTO -sendmail /usr/sbin/sendmail -redmine $REDMINE/projects/$PROJECT -name $NAME -svnlook $SVNLOOK
```
