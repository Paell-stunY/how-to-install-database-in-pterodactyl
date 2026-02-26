# 🗄️ Database Setup on Pterodactyl + phpMyAdmin

Panduan lengkap untuk membuat user database MySQL dan menginstall phpMyAdmin di Pterodactyl Panel.

---

## 📋 Prerequisites

- Pterodactyl Panel sudah terinstall
- Akses root ke server
- MySQL/MariaDB sudah berjalan

---

## 🛠️ Step 1 — Buat User Database MySQL

Masuk ke MySQL sebagai root:

```bash
mysql -u root -p
```

Pilih database MySQL:

```sql
use mysql;
```

Buat user baru (ganti dengan kredensial kamu):

```sql
CREATE USER 'username_kamu'@'%' IDENTIFIED BY 'password_kamu';
```

Berikan semua hak akses:

```sql
GRANT ALL PRIVILEGES ON *.* TO 'username_kamu'@'%' WITH GRANT OPTION;
```

Flush privileges dan keluar:

```sql
FLUSH PRIVILEGES;
exit
```

> ⚠️ **Catatan:** Ganti `username_kamu` dan `password_kamu` dengan username dan password yang kamu inginkan. Jangan gunakan karakter spesial yang tidak di-escape.

---

## 🌐 Step 2 — Install phpMyAdmin

Jalankan command berikut untuk menginstall phpMyAdmin secara otomatis ke direktori Pterodactyl:

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

Command di atas akan:
1. Mendeteksi versi phpMyAdmin terbaru secara otomatis
2. Mendownload phpMyAdmin ke direktori Pterodactyl
3. Mengekstrak dan membersihkan file ZIP
4. Memindahkan ke folder `pma`

---

## ✅ Step 3 — Akses phpMyAdmin

Setelah instalasi selesai, buka browser dan akses:

```
https://domainmu.com/pma
```

Login menggunakan username dan password yang sudah kamu buat di Step 1.

---

## 🔒 Tips Keamanan

- Gunakan password yang kuat dan unik
- Pertimbangkan untuk membatasi akses phpMyAdmin hanya dari IP tertentu
- Ganti nama folder `pma` dengan nama lain untuk keamanan ekstra
- Aktifkan autentikasi dua faktor jika memungkinkan

---

## 🐛 Troubleshooting

| Masalah | Solusi |
|--------|--------|
| Tidak bisa login MySQL | Pastikan password root benar dan MySQL berjalan |
| phpMyAdmin tidak muncul | Cek apakah Nginx/Apache sudah reload setelah instalasi |
| Error permission | Jalankan `chown -R www-data:www-data /var/www/pterodactyl/public/pma` |
| Versi tidak terdeteksi | Cek koneksi internet server dan ulangi command export |

---

## 📄 License

MIT License - bebas digunakan dan dimodifikasi.

---

<div align="center">
  Made with ❤️ for Pterodactyl Users
</div>
