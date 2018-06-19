Python Lambda Template: A sample repository that develops Lambda Function
===

Initialization
---

```bash
cd python-lambda-template
python - m venv.
source bin / activate.fish
pip install -r requirements.txt
```

Intellij Settings
---

1. Project Structures> Python> Create your SDK with your Python
2. Add SDK classpath: `/path/to/python/lib/python3.6`
3. Project Structures> Modules> Attatch src and test directory as `Sources` and` Tests`
4. install requirements.txt on Intellij

Unit Test
---

Using pytest.

```bash
make test-unit
```

Deploy
---

Using [AWS Serverless Application Model \(AWS SAM\)](https://github.com/awslabs/serverless-application-model).

Your task:

1. Edit `Makevars` for your environment.
1. Create AWS SAM template in `templates/` directory.
1. Create Lambda handler in `src/functions/handlers/` directory.  

The name of the following `${resource_name}` has to be matched:

* `templates/template_${resource_name}.yaml`
* `src/functions/handlers/${resource_name}/example_handler.py`
* Make task: `make deploy-${resource_name}`

Before deploy, you should set your AccessKey and Secret for your AWS account. Deploy example: 

```bash
make deploy-heroes env=test account_id=9999999999999 
```

CI / CD on AWS CodeBuild
---

### Create S3 bucket for deoloy.

```Bash
aws s3 mb s3://hero-lambda-deploy --profile your-profile
```

### Create CodeBuild project and build.

* Your CloudFormation stack will be created.
* Your Lambda Function will be deployed.
