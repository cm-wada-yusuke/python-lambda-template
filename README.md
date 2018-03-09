Python Lambda Template: A sample repository that develops Lambda Function
===

Initialization
- -

`` `bash
cd python-lambda-template
python - m venv.
source bin / activate.fish
pip install -r requirements.txt
`` `

Intellij Settings
- -

1. Project Structures> Python> Create your SDK with your Python
2. Add SDK classpath: `/ paty / to / python / lib / python 3.6`
3. Project Structures> Modules> Attatch src and test directory as `Sources` and` Tests`
4. install requirements.txt on Intellij

Unit Test
- -
Using pytest.

`` `bash
python -m pytest
`` `

Integration Test
- -

Using:

* [AWS SAM Local] (https://github.com/awslabs/aws-sam-local)
* [LocalStack (Docker)] (https://hub.docker.com/r/localstack/localstack/)
* [Bats - Bash Automated Testing System] (https://github.com/sstephenson/bats)

`` `Bash
# Startup LocalStack
docker-compose up-d

# Execute SAM Local
sam local invoke \
--docker-network a27c0476cb8e \
-t template_heroes.yaml \
--event test / functions / heroes / examples / get_payload.json \
- env ​​- vars environments / sam - local.json GetHeroes
`` `

The test by Bats executes the above contents and compares the output.

`` `Bash
bats test / functions / heroes / integration.bats
`` `

Deploy
- -

Task:

1. Zip sources and libraries.
2. Upload to S3.
3. Create Cloud Formation stack.
4. CloudFormation Deploy.

Before deploy, you should set your AccessKey for your AWS account.

`` `bash
./deploy.sh
`` `

CI / CD on AWS CodeBuild
- -

### Create S3 bucket for deoloy.

`` `Bash
aws s3 mb s3: // hero-lambda-deploy --profile your-profile
`` `

### Create CodeBuild project and build.

* Your CloudFormation stack will be created.
* Your Lambda Function will be deployed.
