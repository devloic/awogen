# awogen_flutter_example

an example project targeting the flutter platform with awogen

- change configuration parameters in .env.awogen (see .env.awogen.example)  

### <u>for a flutter project you will need the appwrite client sdk, so set APPWRITE_USE_CLIENTSDK=true</u>

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

for awogen setup and build, please refer to the cli example. It is the same process:  

[awogen_cli_example](../awogen_cli_example/README.md)



