#!/bin/sh
export CLOUDSDK_CORE_PROJECT=repcore-prod;

BUILD_ID='7a5e47a6-5388-4314-aa83-0a7563ea9b6c';

echo "buildId,status" > out.va

function checkBuildStatus() {
	buildId=$1
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
			elif [[ $x == *FAILURE ]];
			then
				"$buildId,SUCCESS" >> out.va
			fi
			break;
		fi		
	done <<< $output
}

checkBuildStatus $BUILD_ID;
