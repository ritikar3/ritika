name: Deploy SafeHer Infrastructure

on:
  workflow_dispatch:

env:
  AWS_REGION: us-east-1
  STACK_NAME: SafeHer-Infrastructure
  TEMPLATE_FILE: SafeHerStack.yaml

jobs:
  deploy:
    name: Deploy CloudFormation Stack
    runs-on: ubuntu-latest

    permissions:
      contents: read

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Verify Repository Structure
        run: |
          echo "Repository Contents"
          ls -la
          echo ""
          echo "Recursive Listing"
          ls -R

      - name: Validate CloudFormation Template
        run: |
          aws cloudformation validate-template \
            --template-body file://${{ env.TEMPLATE_FILE }}

      - name: Deploy SafeHer Infrastructure
        run: |
          aws cloudformation deploy \
            --stack-name ${{ env.STACK_NAME }} \
            --template-file ${{ env.TEMPLATE_FILE }} \
            --capabilities CAPABILITY_NAMED_IAM \
            --no-fail-on-empty-changeset

      - name: Show Stack Status
        run: |
          aws cloudformation describe-stacks \
            --stack-name ${{ env.STACK_NAME }} \
            --query "Stacks[0].[StackName,StackStatus]" \
            --output table

      - name: Display Stack Outputs
        run: |
          aws cloudformation describe-stacks \
            --stack-name ${{ env.STACK_NAME }} \
            --query "Stacks[0].Outputs" \
            --output table
