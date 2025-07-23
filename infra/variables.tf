# variables.tf
variable "location" {
  description = "Azure region"
  default     = "UK South"
}

variable "project_name" {
  description = "Base name for all resources"
  type        = string
  default     = "django-api"
}

variable "suffix" {
  description = "Static two‑byte hex suffix shared by all resource names (e.g. `a1b2`)"
  type        = string
}

# Database credentials
variable "db_admin_username" {
  description = "PostgreSQL admin user"
  type        = string
  default     = "djangoadmin"
}
variable "db_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

# Storage
variable "storage_container_name" {
  description = "Blob container for media"
  type        = string
  default     = "voice-recordings"
}

# Docker image
variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

# Django secrets & superuser
variable "secret_key" {
  description = "Django SECRET_KEY"
  type        = string
  sensitive   = true
}

variable "django_superuser_username" {
  description = "Initial Django superuser name"
  type        = string
}
variable "django_superuser_email" {
  description = "Initial Django superuser email"
  type        = string
}
variable "django_superuser_password" {
  description = "Initial Django superuser password"
  type        = string
  sensitive   = true
}

variable "allowed_hosts" {
  description = "Django ALLOWED_HOSTS suffix"
  type        = string
  default     = ".azurewebsites.net"
}

variable "debug" {
  description = "Django DEBUG (0 or 1)"
  type        = string
  default     = "0"
}

# Sentry
variable "sentry_dsn" {
  description = "Your Sentry project DSN"
  type        = string
  sensitive   = true
}
