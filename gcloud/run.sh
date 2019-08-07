#!/bin/sh
export CLOUDSDK_CORE_PROJECT=repcore-prod;

BUILD_ID='7a5e47a6-5388-4314-aa83-0a7563ea9b6c';

desc=$(gcloud builds describe $BUILD_ID --format="flattened(steps[].id,steps[].status)")
printf $desc
