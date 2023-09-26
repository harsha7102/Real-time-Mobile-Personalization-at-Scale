resource "confluent_environment" "Customer_success" {
  display_name = "Customer_success"
  
  lifecycle {
    prevent_destroy = true
  }
}


resource "confluent_kafka_cluster" "basic" {
  display_name = "Customer_success"
  availability = "SINGLE_ZONE"
  cloud        = "GCP"
  region       = "asia-south1"
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

resource "confluentcloud_kafka_connector" "postgres_cdc_source" {
  name = "postgres-cdc-source"

  config = {
    "connector.class"            = "io.debezium.connector.postgresql.PostgresConnector",
    "topics"                      = "your-kafka-topic-here",
    "database.hostname"          = "your-postgres-hostname-here",
    "database.port"              = "your-postgres-port-here",
    "database.user"              = "your-postgres-username-here",
    "database.password"          = "your-postgres-password-here",
    "database.dbname"            = "your-postgres-dbname-here",
    "database.server.name"       = "your-postgres-server-name-here",
    "value.converter"            = "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable" = "false",
    "key.converter"              = "org.apache.kafka.connect.storage.StringConverter",
    "key.converter.schemas.enable" = "false"
  }
}



  lifecycle {
    prevent_destroy = true
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

resource "confluentcloud_kafka_connector" "bigquery_sink" {
  name = "bigquery-sink"

  config = {
    "connector.class"             = "com.wepay.kafka.connect.bigquery.BigQuerySinkConnector",
    "topics"                      = "your-kafka-topic-here",
    "auto.create.topics.enable"   = "false",
    "project"                     = "your-bigquery-project-here",
    "datasets"                    = "your-bigquery-dataset-here",
    "keyfile"                     = "your-bigquery-keyfile-here",
    "keyfile.password"            = "your-bigquery-keyfile-password-here",
    "autoCreateTables"            = "true",
    "autoUpdateSchemas"           = "true",
    "allowNewBigQueryFields"      = "true",
    "allowBigQueryRequiredFieldRelaxation" = "true",
    "bigQueryRetryPolicy"         = "retryTransientErrors",
    "bigQueryRetryWait"           = "60000",
    "bigQueryRetryLimit"          = "10",
    "bufferSize"                  = "1000000",
    "maxWriteSize"                = "1000000",
    "key.converter"               = "org.apache.kafka.connect.storage.StringConverter",
    "value.converter"             = "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable" = "false",
    "transforms"                  = "unwrap",
    "transforms.unwrap.type"      = "io.debezium.transforms.ExtractNewRecordState",
    "transforms.unwrap.drop.tombstones" = "false"
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