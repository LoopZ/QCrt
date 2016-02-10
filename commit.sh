#!/bin/sh

git add *.md *.sh LICENSE HISTORY TODO
git add *.ASM *.INC *.BAT

git add $(find -P DEMOS -type f)
git add $(find -P PASCAL -type f)

git commit -m "$*"
git push