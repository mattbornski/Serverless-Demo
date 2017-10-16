#!/bin/bash

echo " - checking IAM user"
aws iam get-user || exit 1

MICROSERVICES=( greetings insults )
for SERVICE in ${MICROSERVICES[@]} ; do
    pushd $SERVICE

    # Do not proceed unless we have a certificate for the custom domain
    # Attempting to proceed without this will cause a really bad mess that you have to unwind before retrying or complete in a tedious manual way.
    DOMAIN=`cat serverless.yml | grep domainName | cut -d: -f2 | cut -d# -f1 | tr -d ' \t\n\r\f'`
    echo " - verifying existence of ACM certificate for $DOMAIN"
    aws acm list-certificates --region us-east-1 --output text | grep $DOMAIN | cut -f3 | grep "\b$DOMAIN\b" || exit 1

    # Create custom domain using the available certificate
    # TODO This is noisy if it already exists which is the common case
    echo " - ensuring API gateway domain, Cloudfront distro, and Route53 entry to map $DOMAIN to your lambda functions"
    serverless create_domain

    # Deploy new/changed code
    echo " - deploying lambda functions"
    serverless deploy -v

    popd
done
