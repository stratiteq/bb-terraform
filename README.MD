# Terraform
Terraform är ett verktyg för att bygga, versionhantera och adminsistrera infrastruktur säkert och effektivt. Terraform har stöd för de vanligaste och mest populära service providers men även för custom lösningar.

Terraform använder konfigurationsfiler som beskriver de komponenter som behövs för att köra en separat applikation eller ett helt datacenter.

Terraform genererar först en exekveringsplan som beskriver vad som kommer att göras för att nå det önskade tillståndet och utför sedan denna plan för att bygga den beskrivna infrastrukturen (apply). När konfigurationen efterhand ändras kan Terraform avgöra vad som ändrats och skapa stegvisa exekveringsplaner som kan tillämpas genom state.
 
Terraform beskriver hur man jobbar med Infrastructure as Code där infrastrukturen beskrivs med en konfigurations syntax för att skapa ett "blueprint" över ditt datacenter som sedan kan versionshanteras i GIT etc.
Du kan med andra ord hantera din infrastruktur i ditt repository precis som vilken kod som helst.

Terraform är utvecklat i GoLang...

## Installera terraform
Börja med att ladda ner binärfiler för ditt operativsystem på https://www.terraform.io/downloads.html
Packa upp filen och lägg den där du vill ha den, eg. c:\program files\terraform

### Mac och Linux
Lägg till din installationsfolder i $Path . För hjälp se: https://stackoverflow.com/questions/14637979/how-to-permanently-set-path-on-linux-unix

### Windows
Öppna dina environment variables och lägg till installationsfolder i %PATH%. För hjälp se: https://stackoverflow.com/questions/1618280/where-can-i-set-path-to-make-exe-on-windows

### Windows subsystem for linux (Ubuntu)
Kör nedanstående rader, notera att versionen kan ha uppdaterats så gå in och kolla senaste version....
`
wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
unzip terraform.zip
chmod 700 terraform
sudo mv terraform /usr/local/bin/terraform
`

Följ sedan anvisning ovan för Mac och Linux

## Språket
Hashicorp som levererar Terraform har även ett stort utbud av andra produkter, därför har man tagit fram Hashicorp Configuration Language (HCL) som kan användas generellt. Målet med språket är att det ska vara enkelt och lättläsligt och då även att du lär dig ett språk som fungerar med Hashicorps produktflora. Syntaxen påminner mycket om Yaml.

### Providers
En provider används för att interagera med en IaaS eller PaaS tjänst, exempelvis Azure som vi fokuserar på i denna brownbagen. En lista över alla officiella Terraform providers finns här: https://www.terraform.io/docs/providers/

### Resources
En resurs är en av de komponenter som ska ingå i infrastrukturen, exempelvis en Web App (azurerm_app_service). Varje service har ett eget set av HCL meta-parametrar.
När en resurs skapats kan du senare i dina .tf filer referera till resursen i din kod.

### Modules
Moduler används för att skapa återanvändningsbara resurser eller block av resurser. 
Modules är utanför scope för denna brownbag.

### Interpolation
Används för att bl a. referera till variabler inom din kodstruktur.
Eg. "${var.<mitt variabelnamn>}"

### Functions
HCL har ett stort utbud av inbyggda funktioner för att exempelvis hantera checksummor, kryptera, söka och ersätta mm.
Du hittar de officiella funktionerna här: https://www.terraform.io/docs/configuration/interpolation.html#supported-built-in-functions

## Commands
### terraform init
Används för att initiera och skapa en working directory (.terraform) där de providers som finns specificerade i .tf filerna laddas hem. Detta är det första kommandot som körs.

### terraform plan
Skapar en exekverings plan som presenteras med de resurser som ska läggas till, uppdateras eller tas bort. Denna använder state filen för att hålla "track" på ändringar.
Notera att du kan ange argumentet -out för att spara din plan, denna kan då köras vid ett senare tillfälle.

### terraform apply
Används för att applicera ändringarna för att uppnå det state som skiljer mellan nuvarande state och konfiguration. Eller för att applicera en sparad exekverings plan.

Notera att här finns ett flertal sätt att hantera variabler som definierats i dina tf filer. Detta kan göras genom bland annat .tfvars fil eller genom att "skjuta in" variablerna med namn. Eg. terraform apply -var "rgName=tfTest"

### terraform destroy
Används för att riva den befintliga infrastrukturen.

## State
Terraform måste lagra state för att hålla koll på vad som deployats och vad som ska läggas till. Detta görs hela vägen ända ner på appsettings, tags etc.
State lagras default i din folder i filen terraform.tfstate men kan även lagras externt, exempelvis i ett Azure storage account (BLOB storage).

## .tf filer
Alla .tf filer kommer att laddas in för användning i alfabetisk ordning.
Terraforms konfiguration är deklarativ och så referenser till resurser mm. spelar ingen roll.

Notera att du kan exkludera en fil genom att ändra filändelsen till .tf.ignore

# Referenser
https://www.terraform.io
https://www.linode.com/docs/applications/configuration-management/introduction-to-hcl/
https://www.terraform.io/docs/providers/azurerm/

https://app.pluralsight.com/library/courses/terraform-getting-started

# Brownbagen...
Målet med brownbagen är att genom 3 moduler börja med att skapa en enkel Web App.

## Modul 1
- Skapa en .tf fil med all information i samma fil. 
- Sätt variablers värde i filen direkt.
- kör `terraform plan` och se vad som förväntas skapas
- kör `terraform apply`och se vad som skapas i Azure
- kör `terraform destroy`för att ta bort resurser

## Modul 2
- skapa en ny fil "providers.tf" och flytta providers från modul 1
- kör `terraform init` för att initiera terraform och ladda hem provider mm.
- skapa en ny fil "variables.tf" och flytta variabler från modul 1
- skapa en ny fil "resources.tf" och flytta resources från modul 1
- Lägg till en Application Insights resurs
`resource "azurerm_application_insights" "appInsights" {
  name = "${var.applicationName}${var.environmentSuffix}"
  location = "${azurerm_resource_group.rg.location}"
  application_type = "Web"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}`
- Lägg till instrumentation key från application insights som appsetting i web applikationenen
`app_settings {
      "AppInsightsKey" = "${azurerm_application_insights.appInsights.instrumentation_key}"
  }`
- kör `terraform destroy`för att ta bort resurser

## Modul 3
Variabler som inte har ett värde (default...) måste tilldelas vid plan och apply (om inte en sparad plan körs). Detta kan göras på flera sätt, bland annat genom variabel-fil eller genom att "skjuta in" variablerna vid exekvering. I denna modul testar vi båda sätten.

- Skapa en ny fil "terraform.tfvars" och skapa följande variabler
`applicationName="myTerraformApp"`
`resourceGroupName="terraform-demo"`
- Skapa exekveringsplan med följande kommando, du ska nu bara behöva ange environmentSuffix (DEV, TEST etc.)
`terraform plan -var-file="terraform.tfvars"`
- Skapa resurser med följande kommando för att vid exekvering sätta environmentSuffix
`terraform apply -var-file="terraform.tfvars" -var "environmentSuffix=-dev"`
- kör `terraform destroy`för att ta bort resurser
