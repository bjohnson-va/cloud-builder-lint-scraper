#!/bin/sh
export CLOUDSDK_CORE_PROJECT=repcore-prod;

#if [[ -z "$1" ]]; then
#	echo "No file provided"
#	echo "Usage:\n\trun.sh file-containing-build-ids"
#	exit -1;
#fi

buildIds=$(gcloud builds list --format="get(ID)" --page-size=20)

BUILD_ID='7a5e47a6-5388-4314-aa83-0a7563ea9b6c';

echo "buildId,status" > out.va

function checkBuildStatus() {
	buildId=$1


	echo "Checking status of build $buildId"
	output=$(gcloud builds describe $buildId --format="flattened(steps[].id,steps[].status)")

	isLintNext=false

	while read x; do
		if [[ $x == *ng-lint ]]; then
			isLintNext=true;
			continue;
		fi
		if [[ $isLintNext = true ]]; then
			if [[ $x == *SUCCESS ]]; then
				echo "$buildId,SUCCESS" >> out.va
				return;
			elif [[ $x == *FAILURE ]];
			then
				echo "$buildId,FAILURE" >> out.va
				return
			fi
			return;
		fi		
	done << EOF
	$output
EOF
echo "$buildId,???" >> out.va
}

while IFS= read line;
do
	if [[ $line == build_id ]]; then
		continue;
	fi
  	checkBuildStatus $line
done << EOF
	$buildIds
EOF
