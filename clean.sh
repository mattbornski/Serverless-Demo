#!/bin/bash

echo " - checking IAM user"
aws iam get-user || exit 1

pushd greetings

# Serverless domain manager plugin doesn't do cleanup terribly well, we need to help
REGION=us-east-1
DOMAIN=serverless-demo.bornski.io

while : ; do
    BASE_PATHS=( $(aws apigateway get-base-path-mappings --domain-name $DOMAIN --region $REGION --query 'items[*].basePath' --output text) )
    if [ ${#BASE_PATHS[@]} -eq 0 ]; then
        break
    fi
    for BASE_PATH in $BASE_PATHS ; do
        aws apigateway delete-base-path-mapping --domain-name $DOMAIN --base-path "$BASE_PATH" --region $REGION
    done
done

aws apigateway delete-domain-name --domain $DOMAIN --region $REGION

HOSTED_ZONE_ID=
TARGET_DOMAIN_IS_ENTIRE_HOSTED_ZONE=0
DOMAIN_SEGMENT=$DOMAIN
while : ; do
    echo "looking for hosted zone for $DOMAIN_SEGMENT"
    QUERY='HostedZones[?Name==`'$DOMAIN_SEGMENT'.`].Id'
    HOSTED_ZONE_ID=$( aws route53 list-hosted-zones-by-name --dns-name $DOMAIN_SEGMENT --query $QUERY --output text )
    echo "found $HOSTED_ZONE_ID"
    if [ ${#HOSTED_ZONE_ID} -eq 0 ] ; then
        # Target domain is either not found or is not the entire hosted zone
        TARGET_DOMAIN_IS_ENTIRE_HOSTED_ZONE=1
        BLD=$( echo $DOMAIN_SEGMENT | cut -d. -f1 )
        # basename works on suffixes
        DOMAIN_SEGMENT=$( basename $(echo $DOMAIN_SEGMENT | rev) $( echo "$BLD." | rev ) | rev )
        if [ $BLD = $DOMAIN_SEGMENT ] ; then
            # Can't find it
            break;
        fi
        if [ ${#DOMAIN_SEGMENT} -eq 0 ] ; then
            # Can't find it
            break;
        fi
    else
        # Found it
        break;
    fi
done
if [ $TARGET_DOMAIN_IS_ENTIRE_HOSTED_ZONE -eq 0 ] ; then
    # Too dangerous not gonna do it
    # aws route53 delete-hosted-zone --id "$HOSTED_ZONE_ID"
    :
else
    # Search for the appropriate record set
    QUERY='ResourceRecordSets[?Name==`'$DOMAIN'.`]|[0]'
    RECORD=$( aws route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --query $QUERY )
    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch '{"Changes":[{"Action":"DELETE","ResourceRecordSet":'"$RECORD"'}]}'
fi

serverless remove

popd