resource "confluent_environment" "Customer_success" {
  display_name = "Customer_success"

  lifecycle {
    prevent_destroy = true
  }
}


resource "confluent_kafka_cluster" "basic" {
  display_name = "Customer_success"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "ap-south-1"
  basic {}

  environment {
    id = confluent_environment.Customer_success.id
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_service_account" "tf_pce" {
  display_name = "tf_pce"
  description  = "Service account"
}

resource "confluent_role_binding" "terraform_user-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.tf_pce.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.basic.rbac_crn
}


resource "confluent_api_key" "app-manager-kafka-api-key" {
  display_name = "app-manager-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-manager' "
  owner {
    id          = confluent_service_account.tf_pce.id
    api_version = confluent_service_account.tf_pce.api_version
    kind        = confluent_service_account.tf_pce.kind
   }

  managed_resource {
    id          = confluent_kafka_cluster.basic.id
    api_version = confluent_kafka_cluster.basic.api_version
    kind        = confluent_kafka_cluster.basic.kind

    environment {
      id = confluent_environment.Customer_success.id
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "confluent_kafka_topic" "Users" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  topic_name         = "Users"
  rest_endpoint      = confluent_kafka_cluster.basic.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "Content" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  topic_name         = "Content"
  rest_endpoint      = confluent_kafka_cluster.basic.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "Active_Users" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  topic_name         = "Active_Users"
  rest_endpoint      = confluent_kafka_cluster.basic.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "Clicks" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  topic_name         = "Clicks"
  rest_endpoint      = confluent_kafka_cluster.basic.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_connector" "source" {
  environment {
    id = confluent_environment.Customer_success.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSourceConnector_0"
    "kafka.auth.mode"          = "KAFKA_API_KEY"
    "kafka.api.key"            = confluent_api_key.app-manager-kafka-api-key.id
    "kafka.api.secret"         = confluent_api_key.app-manager-kafka-api-key.secret
    "kafka.topic"              = confluent_kafka_topic.Users.topic_name
    "output.data.format"       = "JSON"
    "quickstart"               = "USERS"
    "tasks.max"                = "1"
  }



  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_connector" "source1" {
  environment {
    id = confluent_environment.Customer_success.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSourceConnector_1"
    "kafka.auth.mode"          = "KAFKA_API_KEY"
    "kafka.api.key"            = confluent_api_key.app-manager-kafka-api-key.id
    "kafka.api.secret"         = confluent_api_key.app-manager-kafka-api-key.secret
    "kafka.topic"              = confluent_kafka_topic.Active_Users.topic_name
    "output.data.format"       = "JSON"
    "quickstart"               = "Users"
    "tasks.max"                = "1"
  }



  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_connector" "source2" {
  environment {
    id = confluent_environment.Customer_success.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSourceConnector_2"
    "kafka.auth.mode"          = "KAFKA_API_KEY"
    "kafka.api.key"            = confluent_api_key.app-manager-kafka-api-key.id
    "kafka.api.secret"         = confluent_api_key.app-manager-kafka-api-key.secret
    "kafka.topic"              = confluent_kafka_topic.Clicks.topic_name
    "output.data.format"       = "JSON"
    "quickstart"               = "Users"
    "tasks.max"                = "1"
  }



  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_connector" "source3" {
  environment {
    id = confluent_environment.Customer_success.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSourceConnector_3"
    "kafka.auth.mode"          = "KAFKA_API_KEY"
    "kafka.api.key"            = confluent_api_key.app-manager-kafka-api-key.id
    "kafka.api.secret"         = confluent_api_key.app-manager-kafka-api-key.secret
    "kafka.topic"              = confluent_kafka_topic.Content.topic_name
    "output.data.format"       = "JSON"
    "quickstart"               = "Purchases"
    "tasks.max"                = "1"
  }



  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_ksql_cluster" "pce_enrich" {
  display_name = "pce_enrich"
  csu          = 4
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  credential_identity {
    id = confluent_service_account.tf_pce.id
  }
  environment {
   id = confluent_environment.Customer_success.id
  }
  


  lifecycle {
    prevent_destroy = true
  }

}