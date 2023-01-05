# Get resource ID

aws apigateway get-resources --rest-api-id $API

# test invoke-method

$ aws apigateway test-invoke-method --rest-api-id $API \
--resource-id $RESOURCE --http-method POST --path-with-query-string "" \
--body file://create-item.json

