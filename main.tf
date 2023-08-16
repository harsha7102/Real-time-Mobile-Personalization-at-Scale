# resource "confluent_environment" "Customer_success" {
#   display_name = "Customer_success"

#   lifecycle {
#     prevent_destroy = true
#   }
# }


resource "confluent_kafka_cluster" "basic" {
  display_name = "Customer_success"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "ap-south-1"
  basic {}

  environment {
    id = var.confluent_env
  }

  lifecycle {
    prevent_destroy = true
  }
}

# resource "confluent_api_key" "app-manager-kafka-api-key" {
#   display_name = "app-manager-kafka-api-key"
#   description  = "Kafka API Key that is owned by 'app-manager' "
#   owner {
#     id          = confluent_service_account.app-manager.id
#     api_version = confluent_service_account.app-manager.api_version
#     kind        = confluent_service_account.app-manager.kind
#    }

#   managed_resource {
#     id          = confluent_kafka_cluster.basic.id
#     api_version = confluent_kafka_cluster.basic.api_version
#     kind        = confluent_kafka_cluster.basic.kind

#     environment {
#       id = var.confluent_env
#     }
#   }

#   lifecycle {
#     prevent_destroy = true
#   }
# }


resource "confluent_kafka_topic" "Users" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  topic_name         = "Users"
  rest_endpoint      = confluent_kafka_cluster.basic.rest_endpoint
  credentials {
    key    = var.cloud_api_key
    secret = var.cloud_api_secret
  }
}

resource "confluent_kafka_topic" "Content" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  topic_name         = "Content"
  rest_endpoint      = confluent_kafka_cluster.basic.rest_endpoint
  credentials {
    key    = var.cloud_api_key
    secret = var.cloud_api_secret
  }
}

resource "confluent_kafka_topic" "Active_Users" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  topic_name         = "Active_Users"
  rest_endpoint      = confluent_kafka_cluster.basic.rest_endpoint
  credentials {
    key    = var.cloud_api_key
    secret = var.cloud_api_secret
  }
}

resource "confluent_kafka_topic" "Clicks" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  topic_name         = "Clicks"
  rest_endpoint      = confluent_kafka_cluster.basic.rest_endpoint
  credentials {
    key    = var.cloud_api_key
    secret = var.cloud_api_secret
  }
}

resource "confluent_connector" "source" {
  environment {
    id = var.confluent_env
  }
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSourceConnector_0"
    "kafka.auth.mode"          = "KAFKA_API_KEY"
    "kafka.api.key"            = var.cloud_api_key
    "kafka.api.secret"         = var.cloud_api_secret
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
    id = var.confluent_env
  }
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSourceConnector_1"
    "kafka.auth.mode"          = "KAFKA_API_KEY"
    "kafka.api.key"            = var.cloud_api_key
    "kafka.api.secret"         = var.cloud_api_secret
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
    id = var.confluent_env
  }
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSourceConnector_2"
    "kafka.auth.mode"          = "KAFKA_API_KEY"
    "kafka.api.key"            = var.cloud_api_key
    "kafka.api.secret"         = var.cloud_api_secret
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
    id = var.confluent_env
  }
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSourceConnector_3"
    "kafka.auth.mode"          = "KAFKA_API_KEY"
    "kafka.api.key"            = var.cloud_api_key
    "kafka.api.secret"         = var.cloud_api_secret
    "kafka.topic"              = confluent_kafka_topic.Content.topic_name
    "output.data.format"       = "JSON"
    "quickstart"               = "Purchases"
    "tasks.max"                = "1"
  }



  lifecycle {
    prevent_destroy = true
  }
}