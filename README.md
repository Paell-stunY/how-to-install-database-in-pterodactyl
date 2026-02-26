# 🗄️ Database Setup on Pterodactyl + phpMyAdmin

A complete guide to create a MySQL database user and install phpMyAdmin on Pterodactyl Panel.

---

## 📋 Prerequisites

- Pterodactyl Panel is already installed
- Root access to the server
- MySQL/MariaDB is running

---

## ⚡ Quick Install — One Command (Recommended)

Don't want to do it manually? Just run the script below and follow the prompts:

```bash
bash <(curl -s https://raw.githubusercontent.com/your-repo/main/setup-db-pma.sh)
```

Or download and run it manually:

```bash
wget https://raw.githubusercontent.com/your-repo/main/setup-db-pma.sh
bash setup-db-pma.sh
```

The script will automatically:
- ✅ Create a new MySQL user with your chosen credentials
- ✅ Grant full privileges to the user
- ✅ Detect & install the latest version of phpMyAdmin
- ✅ Set correct file permissions

> ⚠️ **Note:** Must be run as `root` or with `sudo`.

---

## 🛠️ Manual Setup

Prefer to do it step by step? Follow the guide below.

### Step 1 — Create MySQL Database User

Login to MySQL as root:

```bash
mysql -u root -p
```

Select the MySQL database:

```sql
use mysql;
```

Create a new user (replace with your credentials):

```sql
CREATE USER 'your_username'@'%' IDENTIFIED BY 'your_password';
```

Grant all privileges:

```sql
GRANT ALL PRIVILEGES ON *.* TO 'your_username'@'%' WITH GRANT OPTION;
```

Flush privileges and exit:

```sql
FLUSH PRIVILEGES;
exit
```

> ⚠️ Replace `your_username` and `your_password` with your desired credentials. Avoid unescaped special characters.

---

### Step 2 — Install phpMyAdmin

Run the following command to automatically install phpMyAdmin into the Pterodactyl directory:

```bash
export PHPMYADMIN_VERSION=$(curl --silent https://www.phpmyadmin.net/downloads/ | grep "btn btn-success download_popup" | sed -n 's/.*href="\([^"]*\).*/\1/p' | tr '/' '\n' | grep -E '^.*[0-9]+\.[0-9]+\.[0-9]+$')
```

```bash
cd /var/www/pterodactyl/public && \
wget https://files.phpmyadmin.net/phpMyAdmin/$PHPMYADMIN_VERSION/phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.zip && \
unzip phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.zip && \
rm phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.zip && \
mv phpMyAdmin-$PHPMYADMIN_VERSION-all-languages pma
```

---

### Step 3 — Access phpMyAdmin

Once installation is complete, open your browser and go to:

```
https://yourdomain.com/pma
```

Login using the username and password you created in Step 1.

---

## 🔒 Security Tips

- Use a strong and unique password
- Consider restricting phpMyAdmin access to specific IPs only
- Rename the `pma` folder to something less obvious
- Enable two-factor authentication if possible

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Cannot login to MySQL | Make sure root password is correct and MySQL is running |
| phpMyAdmin not showing | Check if Nginx/Apache was reloaded after installation |
| Permission error | Run `chown -R www-data:www-data /var/www/pterodactyl/public/pma` |
| Version not detected | Check server internet connection and re-run the export command |

---

## 📄 License

MIT License — free to use and modify.

---

<div align="center">
  Made with ❤️ by Rielliona
</div>
