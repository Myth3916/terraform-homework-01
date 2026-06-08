terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Настройка провайдера Docker для работы с удалённой ВМ через SSH
provider "docker" {
  host = "ssh://ubuntu@62.84.118.4"
}

# Генерация пароля для root
resource "random_password" "root_password" {
  length      = 16
  special     = false
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
}

# Генерация пароля для пользователя wordpress
resource "random_password" "user_password" {
  length      = 16
  special     = false
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
}

# Скачивание образа MySQL 8
resource "docker_image" "mysql" {
  name         = "mysql:8"
  keep_locally = false
}

# Запуск контейнера MySQL
resource "docker_container" "mysql" {
  image = docker_image.mysql.image_id
  name  = "mysql-db"

  ports {
    internal = 3306
    external = 3306
    ip       = "127.0.0.1"
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${random_password.root_password.result}",
    "MYSQL_DATABASE=wordpress",
    "MYSQL_USER=wordpress",
    "MYSQL_PASSWORD=${random_password.user_password.result}",
    "MYSQL_ROOT_HOST=%"
  ]
}

# Вывод сгенерированных паролей
output "root_password" {
  value     = random_password.root_password.result
  sensitive = true
}

output "user_password" {
  value     = random_password.user_password.result
  sensitive = true
}