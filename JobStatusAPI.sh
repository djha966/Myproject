#!/bin/bash

# Variables
JENKINS_URL="http://your-jenkins-server"
USER="your-username"
API_TOKEN="your-api-token"

# Fetch the list of jobs
jobs=$(curl -s "$JENKINS_URL/api/json?tree=jobs[name]" --user "$USER:$API_TOKEN" | jq -r '.jobs[].name')

# Check if we successfully fetched jobs
if [ -z "$jobs" ]; then
    echo "Failed to fetch jobs or no jobs found."
    exit 1
fi

# Loop through each job to get its status
echo "Job Statuses:"
for job in $jobs; do
    # Get the last build number
    build_number=$(curl -s "$JENKINS_URL/job/$job/api/json" --user "$USER:$API_TOKEN" | jq -r '.lastBuild.number')

    # If there is no last build, skip this job
    if [ "$build_number" == "null" ]; then
        echo "Job: $job - No builds found"
        continue
    fi

    # Get the build status
    build_status=$(curl -s "$JENKINS_URL/job/$job/$build_number/api/json" --user "$USER:$API_TOKEN" | jq -r '.result')

    # Print the job status
    echo "Job: $job - Last Build Status: $build_status"
done
