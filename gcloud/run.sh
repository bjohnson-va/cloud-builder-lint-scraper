#!/bin/sh
export CLOUDSDK_CORE_PROJECT=repcore-prod;

if [[ -z "$1" ]]; then
	echo "Please provide a number of builds to analyze."
	echo -e "Usage:\n\trun.sh <num>"
	exit -1;
fi
num=$1;
buildIds=$(gcloud builds list --format="get(ID)" --page-size=$num --limit=$num)

echo "buildId,status" > out.va
echo "Build failures:" > failures.va

function recordError() {
	buildId=$1

	echo "Recording lint failures for $buildId";

	echo $buildId >> failures.va;
	output=$(gcloud builds log $buildId | grep '"ng-lint": ERROR:');
	output=grep -v "_generated" | echo "$output";
	echo "$output" >> failures.va;
}

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
				echo "$buildId,FAILURE" >> out.va;
				recordError $buildId;
				return;
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
