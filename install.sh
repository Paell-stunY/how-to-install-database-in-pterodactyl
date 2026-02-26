#!/bin/bash

# ============================================================
#   🗄️  Pterodactyl - Auto Setup Database + phpMyAdmin
#   GitHub  : https://github.com/
#   Author  : Rielliona
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

banner() {
  echo -e "${CYAN}"
  echo "  ██████╗ ██╗███████╗██╗     ██╗     ██╗ ██████╗ ███╗   ██╗ █████╗ "
  echo "  ██╔══██╗██║██╔════╝██║     ██║     ██║██╔═══██╗████╗  ██║██╔══██╗"
  echo "  ██████╔╝██║█████╗  ██║     ██║     ██║██║   ██║██╔██╗ ██║███████║"
  echo "  ██╔══██╗██║██╔══╝  ██║     ██║     ██║██║   ██║██║╚██╗██║██╔══██║"
  echo "  ██║  ██║██║███████╗███████╗███████╗██║╚██████╔╝██║ ╚████║██║  ██║"
  echo "  ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝"
  echo -e "${NC}"
  echo -e "${BOLD}  🗄️  Pterodactyl Auto Setup - Database + phpMyAdmin${NC}"
  echo -e "  ──────────────────────────────────────────────────────"
  echo ""
}

log_info()    { echo -e "  ${BLUE}[INFO]${NC}  $1"; }
log_success() { echo -e "  ${GREEN}[✓]${NC}    $1"; }
log_warn()    { echo -e "  ${YELLOW}[!]${NC}    $1"; }
log_error()   { echo -e "  ${RED}[✗]${NC}    $1"; }
log_step()    { echo -e "\n  ${BOLD}${CYAN}━━ $1${NC}"; }

# ── Root check ──────────────────────────────────────────────
check_root() {
  if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root!"
    echo -e "  Try: ${YELLOW}sudo bash setup-db-pma.sh${NC}"
    exit 1
  fi
}

# ── Dependency check ────────────────────────────────────────
check_deps() {
  log_step "Checking dependencies..."
  for cmd in mysql wget unzip curl; do
    if command -v $cmd &>/dev/null; then
      log_success "$cmd found"
    else
      log_error "$cmd not found! Please install it before continuing."
      exit 1
    fi
  done
}

# ── Input credentials ───────────────────────────────────────
get_credentials() {
  log_step "Database Configuration"
  echo ""

  read -p "  Enter MySQL root password          : " -s MYSQL_ROOT_PASS
  echo ""

  if ! mysql -u root -p"$MYSQL_ROOT_PASS" -e "SELECT 1;" &>/dev/null; then
    log_error "Wrong MySQL root password or MySQL is not running!"
    exit 1
  fi
  log_success "MySQL connection successful"
  echo ""

  while true; do
    read -p "  Enter username for database        : " DB_USER
    [[ -z "$DB_USER" ]] && log_warn "Username cannot be empty!" || break
  done

  while true; do
    read -p "  Enter password for database        : " -s DB_PASS
    echo ""
    read -p "  Confirm password                   : " -s DB_PASS_CONFIRM
    echo ""
    if [[ "$DB_PASS" != "$DB_PASS_CONFIRM" ]]; then
      log_warn "Passwords do not match, try again!"
    elif [[ -z "$DB_PASS" ]]; then
      log_warn "Password cannot be empty!"
    else
      break
    fi
  done

  while true; do
    read -p "  Enter name for database            : " DB_NAME
    [[ -z "$DB_NAME" ]] && log_warn "Database name cannot be empty!" || break
  done

  echo ""

  while true; do
    read -p "  Enter your domain pterodactyl (e.g: domain.com): " DOMAIN
    [[ -z "$DOMAIN" ]] && log_warn "Domain cannot be empty!" || break
  done
}

# ── Create MySQL database & user ────────────────────────────
create_mysql_database() {
  log_step "Creating Database & User"

  mysql -u root -p"$MYSQL_ROOT_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

  if [[ $? -eq 0 ]]; then
    log_success "Database '${DB_NAME}' created successfully!"
    log_success "User '${DB_USER}' created and granted access!"
  else
    log_error "Failed to create database or user!"
    exit 1
  fi
}

# ── Install phpMyAdmin ───────────────────────────────────────
install_phpmyadmin() {
  log_step "Installing phpMyAdmin"

  PMA_DIR="/var/www/pterodactyl/public"

  if [[ ! -d "$PMA_DIR" ]]; then
    log_error "Pterodactyl directory not found: $PMA_DIR"
    log_warn "Make sure Pterodactyl Panel is already installed!"
    exit 1
  fi

  if [[ -d "$PMA_DIR/pma" ]]; then
    log_warn "Old pma folder found, removing..."
    rm -rf "$PMA_DIR/pma"
  fi

  log_info "Detecting latest phpMyAdmin version..."
  PHPMYADMIN_VERSION=$(curl --silent https://www.phpmyadmin.net/downloads/ \
    | grep "btn btn-success download_popup" \
    | sed -n 's/.*href="\([^"]*\).*/\1/p' \
    | tr '/' '\n' \
    | grep -E '^.*[0-9]+\.[0-9]+\.[0-9]+$')

  if [[ -z "$PHPMYADMIN_VERSION" ]]; then
    log_error "Failed to detect phpMyAdmin version!"
    exit 1
  fi

  log_success "Latest version: phpMyAdmin $PHPMYADMIN_VERSION"
  log_info "Downloading phpMyAdmin..."

  cd "$PMA_DIR" || exit 1

  wget -q --show-progress \
    "https://files.phpmyadmin.net/phpMyAdmin/$PHPMYADMIN_VERSION/phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.zip" \
    -O phpmyadmin.zip

  if [[ $? -ne 0 ]]; then
    log_error "Failed to download phpMyAdmin!"
    exit 1
  fi

  log_info "Extracting files..."
  unzip -q phpmyadmin.zip
  rm -f phpmyadmin.zip
  mv "phpMyAdmin-$PHPMYADMIN_VERSION-all-languages" pma

  chown -R www-data:www-data "$PMA_DIR/pma" 2>/dev/null || \
  chown -R nginx:nginx "$PMA_DIR/pma" 2>/dev/null

  log_success "phpMyAdmin successfully installed at $PMA_DIR/pma"
}

# ── Summary ──────────────────────────────────────────────────
show_summary() {
  echo ""
  echo -e "  ${GREEN}${BOLD}╔════════════════════════════════════════════════╗${NC}"
  echo -e "  ${GREEN}${BOLD}║         ✅  INSTALLATION COMPLETE!             ║${NC}"
  echo -e "  ${GREEN}${BOLD}╚════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "  ${BOLD}📋 Access Information:${NC}"
  echo -e "  ──────────────────────────────────────────────────"
  echo -e "  🌐 phpMyAdmin URL : ${CYAN}https://${DOMAIN}/pma${NC}"
  echo -e "  🗄️  Database Name  : ${CYAN}${DB_NAME}${NC}"
  echo -e "  👤 DB Username    : ${CYAN}${DB_USER}${NC}"
  echo -e "  🔑 DB Password    : ${CYAN}(password you entered)${NC}"
  echo ""
  echo -e "  ${YELLOW}⚠️  Security Tips:${NC}"
  echo -e "  • Rename the /pma folder to something less obvious"
  echo -e "  • Restrict phpMyAdmin access via IP whitelist"
  echo -e "  • Always use HTTPS (SSL) for panel access"
  echo ""
}

# ── Main ─────────────────────────────────────────────────────
main() {
  clear
  banner
  check_root
  check_deps
  get_credentials
  create_mysql_database
  install_phpmyadmin
  show_summary
}

main
