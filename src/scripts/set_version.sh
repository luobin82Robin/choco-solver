#!/bin/bash
#Script to notify the website about a release
function guess() {
    v=$1
    if [[ $v == *-SNAPSHOT ]]; then
        echo "&{v%%-SNAPSHOT}"
    else
        echo "${v%.*}.$((${v##*.}+1))-SNAPSHOT"
    fi
}

function sedInPlace() {
	if [ $(uname) = "Darwin" ]; then
		sed -i '' "$1" $2
	else
		sed -i'' "$1" $2
	fi
}

REPO_URL="http://www.emn.fr/z-info/choco-repo/mvn/repository/choco"

if [ $1 == "--next" ]; then
    VERSION=$(guess $2)
else
    VERSION=$1
fi
echo "New version is ${VERSION}"
#Update the poms
mvn versions:set -DnewVersion=${VERSION} -DgenerateBackupPoms=false

DAT=`LANG=en_US.utf8 date +"%Y-%m"`
YEAR=`LANG=en_US.utf8 date +"%Y"`
d=`LANG=en_US.utf8 date +"%d %b %Y"`

## The README.md
# Update of the version number for maven usage

sedInPlace "s%Current stable version is .*.%Current stable version is $VERSION ($d).%"  README.md
sedInPlace "s%<version>.*</version>%<version>$VERSION</version>%"  README.md
sedInPlace "s%Choco3 is distributed.*.%Choco3 is distributed under BSD licence \(Copyright \(c\) 1999-$YEAR, Ecole des Mines de Nantes).%"  README.md
snapshot=0
echo $VERSION | grep "\-SNAPSHOT$" > /dev/null && snapshot=1

if [ $snapshot = 0 ]; then
    # Update the bundle and the apidoc location
    sedInPlace "s%$REPO_URL.*choco\-solver.*%$REPO_URL/choco\-solver/$VERSION/choco\-solver\-$VERSION\-jar\-with\-dependencies\.jar%" README.md
else
    # Update the bundle and the apidoc location
    sedInPlace "s%$REPO_URL.*choco\-solver.*%$REPO_URL/choco\-solver/$VERSION/choco\-solver\-$VERSION\-jar\-with\-dependencies\.jar%" README.md
fi


## The configuration file
sedInPlace "s%WELCOME_TITLE=.*%WELCOME_TITLE=** Choco $VERSION \($DAT\) : Constraint Programming Solver, Copyleft \(c\) 2010-$YEAR%"  choco-solver/src/main/resources/configuration.properties

## The CHANGES.md
# replace the 'NEXT MILESTONE' version by VERSION
REGEX="s%NEXT MILESTONE*%${VERSION} - ${d}%"
sedInPlace "${REGEX}" CHANGES.md
# add a new empty line in CHANGES.md
sedInPlace '5 i\
\
NEXT MILESTONE\
-------------------\
\
' CHANGES.md
