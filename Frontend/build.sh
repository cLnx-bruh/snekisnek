if [ -z "$1" ]
  then
    echo "No environment provided: example build.sh prod"
    exit 1
fi

rm -rf build
cp -r src build
rm build/environments/env.js

envFile=build/environments/env-$1.js

if !(test -f "$envFile")
    then
      echo "No env file '$envFile' found"
      exit 1
fi

mv $envFile build/environments/env.js

echo Build successfull!!