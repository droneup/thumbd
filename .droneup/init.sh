#!/bin/bash
echo "Initializing"
[ -z "$ENVKEY" ] && echo "ENVKEY wasn't provided at run time, please include -e ENVKEY=\"details\" to docker!" && exit 1 || echo " -- Merge Environment variables"
eval $(envkey-source $ENVKEY) && eval "$@"
