#!/usr/bin/env bash

pip install -r requirements.txt -t deploy
cp -R src deploy
cd deploy
zip -r api_backend.zip *
hash=`openssl md5 api_backend.zip | awk '{print $2}'`
echo "api_backend.zip: hash = $hash"
filename="${hash}.zip"
s3_keyname="api_backend/${filename}"
mv api_backend.zip $filename
aws s3 cp $filename  s3://hero-lambda-deploy/api_backend/

cd ..
aws cloudformation package \
    --template-file template_heroes.yaml \
    --s3-bucket lambda-deploy \
    --output-template-file packaged-heroes-template.yaml

aws cloudformation deploy \
    --template-file packaged-heroes-template.yaml \
    --stack-name hero-lambda  \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides CodeKey=${s3_keyname}

rm -r deploy/
