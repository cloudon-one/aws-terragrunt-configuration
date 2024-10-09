#!/bin/bash

# Set the default region
export AWS_DEFAULT_REGION="eu-west-1"

# Set the output file name
output_file="api_gateway_apis.yaml"

# Clear the output file
> "$output_file"

# Get all API Gateway REST APIs
apis=$(aws apigateway get-rest-apis --query "items[*].[id,name]" --output text)

# Iterate through each API
while read -r api_id api_name; do
    echo "Processing API: $api_name"
    
    # Get API details
    api_info=$(aws apigateway get-rest-api --rest-api-id "$api_id")
    
    # Extract description and endpoint type
    description=$(echo "$api_info" | jq -r '.description // "No description provided"')
    endpoint_type=$(echo "$api_info" | jq -r '.endpointConfiguration.types[0] // "EDGE"')
    
    # Write API information to YAML file
    cat << EOF >> "$output_file"
- name: "$api_name"
  description: "$description"
  protocol: "REST"
  endpoint_type: "$endpoint_type"

EOF
done <<< "$apis"

# Get all API Gateway HTTP APIs
http_apis=$(aws apigatewayv2 get-apis --query "Items[*].[ApiId,Name]" --output text)

# Iterate through each HTTP API
while read -r api_id api_name; do
    echo "Processing HTTP API: $api_name"
    
    # Get API details
    api_info=$(aws apigatewayv2 get-api --api-id "$api_id")
    
    # Extract description and protocol
    description=$(echo "$api_info" | jq -r '.Description // "No description provided"')
    protocol=$(echo "$api_info" | jq -r '.ProtocolType')
    
    # Write API information to YAML file
    cat << EOF >> "$output_file"
- name: "$api_name"
  description: "$description"
  protocol: "$protocol"
  endpoint_type: "REGIONAL"

EOF
done <<< "$http_apis"

echo "Export completed. Results saved to $output_file"