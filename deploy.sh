#!/usr/bin/env bash

. environments/common.sh

if [ -z $ENV ]; then
  echo "Set the environment name. Such as test, stg, and prd." 1>&2
  exit 1
fi

pip install -r requirements.txt -t deploy
cp -R src deploy
cd deploy
zip -r source.zip *
hash=`openssl md5 source.zip | awk '{print $2}'`
echo "source.zip: hash = $hash"
filename="${hash}.zip"
mv source.zip $filename

bucket=$DEPLOY_S3_BUCKET

for item in ${FUNCTION_GROUP[@]} ; do

    s3_keyname="${item}/${filename}"

    aws s3 cp $filename  s3://${bucket}/${item}/

    cp ../template_${item}.yaml ./
    aws cloudformation package \
        --template-file template_${item}.yaml \
        --s3-bucket ${bucket} \
        --output-template-file packaged-${item}.yaml

    aws cloudformation deploy \
        --template-file packaged-${item}.yaml \
        --stack-name ${ENV}-${item}-lambda  \
        --capabilities CAPABILITY_IAM \
        --parameter-overrides \
            Env=${ENV} \
            CodeKey=${s3_keyname}
done

cd ..
rm -r deploy/
