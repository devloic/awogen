# awogen_flutter_example

an example project targeting the flutter platform with awogen

- change configuration parameters in .env.awogen

| Key   |  description |
|----------|:------|
| PROJECTID=23214df25c5d141cd11e |create the id in your appwrite console |
| DATABASEID=3847980df24672dd26a4 |create the id your appwrite console |
| ENDPOINT=https://cloud.appwrite.io/v1 | appwrite cloud or selfhosted endpoint url |
| FLAVOR=dev | just a tag so you can check inside the code if it targets dev,prod,staging or so |
| APIKEY=37a801ee43ed75699159b... | create it in your appwrite console, needed for awogen to be able to create collections and attributes in your appwrite project |
| APPWRITE_USE_CLIENTSDK=true | set it to true if you want to include  appwrite flutter sdk |
| APPWRITE_USE_SERVERSDK=false | set it to true if you want to include appwrite server sdk |
| PPWRITE_OBFUSCATE=true | PROJECTID, DATABASEID, ENDPOINT, APIKEY will be obfuscated in dart classes (uses envied) |


Run commands below with [runme](https://runme.dev/) directly in this README.MD

[![Foo](https://badgen.net/static/Runme/install%20Runme&nbsp;vscode%20extension/5B3ADF)](vscode:extension/stateful.runme)

```sh
#add awogen_generator to your project
dart pub add --dev awogen_generator

#run awogen:install
dart run awogen_generator:install
# this will add envied_generator and build_runner to dev_dependencies
# and run the install setup
# you can also add the dependecies manually
# dart pub add --dev envied_generator
# dart pub add --dev build_runner:^2.3.3

```

```sh { background=false }
#generate classes and collections
dart run build_runner build -d
```

```sh { background=false interactive=true }
#build_runner has a caching mechanism
#you can delete the cache if it gets corrupted
dart run build_runner clean

```