#!/bin/bash
sourceRepo=$1
sourceRepoName=$2
destRepo=$3
git clone --mirror ${sourceRepo}
cd ${sourceRepoName}
git remote rm origin
git remote add origin ${destRepo}
git remote set-url origin ${destRepo}
git push -f --mirror ${destRepo}
