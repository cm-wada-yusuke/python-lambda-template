#!/usr/bin/env bash

pip install -r requirements.txt -t deploy
cp -R src deploy
cd deploy
zip -r api_backend.zip *
hash=`md5 -q api_backend.zip`
echo "api_backend.zip: hash = $hash"
filename="${hash}.zip"
s3_keyname="api_backend/${filename}"
mv api_backend.zip $filename
aws s3 cp $filename  s3://hero-lambda-deploy/api_backend/ --profile cm-wada

cd ..
aws cloudformation package \
    --template-file template_heroes.yaml \
    --s3-bucket lambda-deploy \
    --output-template-file packaged-heroes-template.yaml --profile cm-wada

aws cloudformation deploy \
    --template-file packaged-heroes-template.yaml \
    --stack-name hero-lambda  \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides CodeKey=${s3_keyname} --profile cm-wada

rm -r deploy/
