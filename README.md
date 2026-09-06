# Andalan Tools

Aplikasi utilitas dokumen dan pengolahan berkas lokal untuk iOS. Dirancang dengan pendekatan offline-first, mengutamakan privasi penuh, kecepatan pemrosesan langsung di perangkat, dan estetika minimalis berbasis palet Everforest.

---

## Tentang Proyek (About)

Andalan Tools adalah kumpulan alat utilitas digital untuk iPhone dan iPad yang menggantikan ketergantungan pada layanan cloud pihak ketiga untuk manipulasi berkas harian. Seluruh proses komputasi—mulai dari penggabungan PDF, kompresi, ekstraksi teks, konversi format dokumen Word, hingga pembersihan metadata foto—berjalan sepenuhnya di dalam memori lokal perangkat tanpa koneksi internet.

Proyek ini dibangun di atas Flutter dan arsitektur Dart yang bersih, menerapkan prinsip desain Swiss Typography yang fungsional, dan dilindungi oleh brankas penyimpanan lokal dengan autentikasi biometrik Face ID / Touch ID.

---

## Latar Belakang & Motivasi

### Kebutuhan Dasar Dokumen Digital
Pengelolaan berkas digital adalah kebutuhan rutin yang dihadapi hampir semua orang:
- Menggabungkan beberapa dokumen PDF surat lamaran, kontrak kerja, atau formulir pendaftaran menjadi satu berkas berurutan.
- Memindai nota fisik, lembar administrasi, atau kartu identitas lewat kamera ponsel menjadi PDF yang rapi.
- Mengecilkan ukuran PDF yang membengkak agar dapat lolos batas lampiran email atau portal instansi.
- Membersihkan informasi lokasi GPS (EXIF metadata) pada foto dokumen pribadi sebelum dikirimkan ke pihak eksternal.
- Membaca dan mengonversi berkas Microsoft Word (.docx) ke PDF saat sedang bepergian tanpa perangkat laptop.

### Masalah Ekosistem Aplikasi Mobile
Di App Store, sebagian besar aplikasi utilitas pengolah dokumen memiliki pola yang merugikan pengguna:
1. Skema Monetisasi Agresif: Fitur mendasar seperti menggabungkan dua berkas PDF kerap dikunci di balik skema langganan mingguan bernilai tinggi (misalnya Rp79.000 per minggu).
2. Risiko Keamanan & Privasi Data: Banyak aplikasi gratisan secara diam-diam mengunggah berkas pengguna ke server antah-berantah untuk diproses secara remote. Berkas tersebut sering kali mencakup dokumen sangat sensitif seperti KTP, paspor, mutasi bank, dan perjanjian hukum.
3. Antarmuka Distraktif: Aplikasi dijejali banner iklan video, prompt ulasan berulang, tombol pembelian palsu, dan elemen visual mencolok yang memperlambat alur kerja.

### Solusi yang Dibangun
Sebagai pengguna harian sistem operasi Linux (Arch / CachyOS) yang menggunakan iPhone sehari-hari tanpa kepemilikan komputer Mac, pembuat memutuskan membangun solusi yang independen dan beretika.

Andalan Tools hadir dengan tiga prinsip fundamental:
- 100% Pemrosesan di Perangkat (Local-First): Berkas tidak pernah diunggah ke server mana pun. Nol telemetri, nol pelacak analitik pihak ketiga.
- Terbuka dan Bebas Akses: Seluruh fungsi tersedia penuh tanpa batasan paywall, watermark, atau iklan.
- Estetika Tenang & Presisi: Mengadopsi palet warna Everforest (Warm Canvas, Deep Evergreen, Muted Sage) dan interaksi elastis bawaan iOS tanpa ornamen visual yang tidak perlu.

---

## Fitur Utama

Aplikasi menyediakan tujuh alat pemrosesan dokumen inti dan satu brankas berkas berkeamanan biometrik:

| Alat | Fungsi |
| :--- | :--- |
| Image to PDF | Memindai dokumen dari kamera atau galeri, melakukan pemotongan presisi, dan menyusun banyak foto menjadi dokumen PDF tunggal. |
| PDF Merger | Menggabungkan beberapa dokumen PDF menjadi satu kesatuan dengan pengaturan urutan halaman berbasis drag-and-drop. |
| Kunci & Proteksi PDF | Mengunci dokumen PDF menggunakan enkripsi standar industri AES-256 bit dengan kata sandi langsung di perangkat. |
| Kompresi PDF & Pembersih EXIF | Memperkecil ukuran berkas PDF serta menghapus metadata sensitif (geotag GPS, model kamera, waktu pengambilan) dari foto. |
| PDF Editor & OCR | Membaca dokumen PDF, mengekstrak teks secara offline menggunakan OCR lokal, menyusun ulang, serta menghapus halaman tertentu. |
| Konversi Format Gambar | Melakukan konversi format gambar instan antara PNG, JPG, WebP, dan HEIC tanpa penurunan kualitas yang tidak terkontrol. |
| Docx to PDF | Mengonversi dokumen naskah Microsoft Word (.docx) langsung ke PDF dengan mempertahankan struktur teks, tabel, dan gambar. |
| Brankas Dokumen | Menyimpan riwayat berkas hasil olahan dalam penyimpanan privat terisolasi yang dilindungi autentikasi Face ID, Touch ID, atau Passcode. |

---

## Filosofi Desain

- Palet Everforest: Menggunakan nada organik yang menenangkan mata—latar kanvas lembut (#FAF9F5), tipografi grafit pekat (#232A2E), teks sekunder abu sage (#7A8478), dan aksen daun pinus (#2D4B3E).
- Lambang Vektor Dokumen: Logo bilah atas digambar secara geometris (CustomPainter murni) membentuk dua lembar dokumen bertingkat dengan potongan sudut diagonal (optical notch) dan garis editorial halus.
- Fisika Gerak iOS: Seluruh kartu dan tombol interaktif menggunakan respons pegas mikro (IosBouncyCard) dan getaran umpan balik haptik (HapticFeedback) saat disentuh.

---

## Instalasi & Pemasangan

### Metode 1: Pasang Berkas Siap Pakai (Rekomendasi)
Unduh berkas instalasi dari tab Releases di repositori ini:
- Untuk iPhone (iOS): Unduh `AndalanTools.ipa` dan pasang menggunakan SideStore (rekomendasi tanpa kabel via Wi-Fi/VPN), AltStore, Sideloadly, atau TrollStore.
- Untuk Android: Unduh `AndalanTools.apk` langsung dari browser ponsel Anda, buka berkas tersebut, dan pilih Install.

### Metode 2: Kompilasi dari Source Code
Prasyarat: Flutter SDK versi 3.24 atau yang lebih baru.

```bash
# Kloning repositori
git clone https://github.com/DarulQutni-Q/AndalanTools.git
cd AndalanTools

# Ambil dependensi proyek
flutter pub get

# Bangun berkas IPA untuk iOS
flutter build ios --release --no-codesign

# Bangun berkas APK untuk Android
flutter build apk --release
```

Setiap push ke branch `main` secara otomatis memicu kompilasi multi-platform (iOS di runner macOS dan Android di runner Ubuntu) melalui alur kerja GitHub Actions (`.github/workflows/ios-build.yml`).

---

## Struktur Repositori

```text
lib/
├── core/
│   ├── theme/          # Palet warna Everforest dan konfigurasi tema aplikasi
│   ├── utils/          # Pengolah gambar, abstraksi berkas, dan generator PDF
│   └── widgets/        # Komponen UI iOS (AndalanLogo, IosHeaderVaultPill, IosBouncyCard)
├── features/
│   ├── compress_and_clean/ # Layanan kompresi PDF dan pembersihan EXIF metadata
│   ├── docx_converter/     # Parser naskah Word (.docx) ke format PDF
│   ├── home/               # Layar beranda 7 alat dokumen dan akses Brankas
│   ├── image_converter/    # Konversi format gambar (HEIC, PNG, JPG, WebP)
│   ├── image_to_pdf/       # Pemindai kamera, crop berkas, dan penyusun PDF
│   ├── pdf_editor/         # Penampil PDF, ekstraksi OCR lokal, dan pengelola halaman
│   ├── pdf_lock/           # Enkripsi dokumen PDF bersandi AES-256
│   ├── pdf_merger/         # Penggabung multi-berkas PDF
│   └── vault/              # Brankas berkas lokal dengan proteksi biometrik
└── main.dart
```

---

## Privasi & Keamanan

- Nol Telemetri: Tidak memuat SDK pelacakan pihak ketiga apa pun.
- Nol Akses Jaringan: Aplikasi tidak meminta maupun menggunakan izin akses internet untuk pemrosesan dokumen.
- Pembersihan Data Sementara: Berkas kerja temporer segera dihapus dari disk setelah proses konversi selesai.
- Enkripsi Hardware: Autentikasi brankas terintegrasi langsung dengan Secure Enclave perangkat melalui API LocalAuthentication iOS.

---

## Lisensi

Didistribusikan di bawah lisensi terbuka [MIT License](LICENSE). Bebas digunakan, dipelajari, dan dikembangkan kembali untuk keperluan personal maupun komersial.
