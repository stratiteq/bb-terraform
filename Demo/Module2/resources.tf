############
# Resources
############
resource "azurerm_resource_group" "rg" {
    name        = "${var.resourceGroupName}${var.environmentSuffix}"
    location    = "${var.location}"
}

resource "azurerm_app_service_plan" "appPlan" {
  name                = "${var.applicationName}${var.environmentSuffix}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  sku {
    tier = "Basic"
    size = "B1"
  }
 }

resource "azurerm_application_insights" "appInsights" {
  name = "${var.applicationName}${var.environmentSuffix}"
  location = "${azurerm_resource_group.rg.location}"
  application_type = "Web"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_app_service" "appService" {
  name                = "${var.applicationName}${var.environmentSuffix}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  app_service_plan_id = "${azurerm_app_service_plan.appPlan.id}"

  site_config {
      always_on = true
      dotnet_framework_version = "v4.0"
  }

  app_settings {
      "AppInsightsKey" = "${azurerm_application_insights.appInsights.instrumentation_key}"
  }

  connection_string {
      name = "TheOrderDatabase"
      type = "SQLServer"
      value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}
